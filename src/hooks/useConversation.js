// src/hooks/useConversation.js

import { useState, useCallback, useRef } from 'react'
import { conversationApi } from '../api/client'
import useJobPoller from './useJobPoller'

export const STAGES = {
  IDLE:        'idle',
  INITIAL:     'initial',
  CLARIFYING:  'clarifying',
  BLUEPRINT:   'blueprint',
  CONFIRMED:   'confirmed',
  GENERATING:  'generating',
  FIXING:      'fixing',
  COMPLETE:    'complete',
}

export default function useConversation() {
  const [sessionId,   setSessionId]   = useState(null)
  const [messages,    setMessages]    = useState([])
  const [stage,       setStage]       = useState(STAGES.IDLE)
  const [blueprint,   setBlueprint]   = useState(null)
  const [schema,      setSchema]      = useState(null)
  const [validation,  setValidation]  = useState(null)
  const [metadata,    setMetadata]    = useState(null)
  const [genSummary,  setGenSummary]  = useState(null)
  const [isLoading,   setIsLoading]   = useState(false)
  const [error,       setError]       = useState(null)

  const messagesEndRef = useRef(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  const addMessage = useCallback((role, content, extras = {}) => {
    setMessages(prev => [
      ...prev,
      {
        id:        Date.now() + Math.random(),
        role,
        content,
        timestamp: new Date().toISOString(),
        ...extras,
      }
    ])
    setTimeout(scrollToBottom, 100)
  }, [])

  // ── Job poller — fires when stage === 'generating' ────────────
  const { jobId, jobStatus, progress, isPolling, submitAndPoll, cancel } =
    useJobPoller({
      onComplete: useCallback((result) => {
        if (!result) return

        // Unpack the completed schema result.
        // NOTE (default API contract): `metadata` (L1-L7, provider/model,
        // rule IDs) is NOT included and `validation` is the lean form
        // { score, passed, grade, summary } with no per-rule issue list.
        // The full payload is only returned to a staff `X-Debug: true`
        // request. Every read below is guarded accordingly.
        const { schema: sql, validation: val, metadata: meta, generation_summary } = result

        if (sql)                setSchema(sql)
        if (val)                setValidation(val)
        if (meta)               setMetadata(meta)
        if (generation_summary) setGenSummary(generation_summary)

        setStage(STAGES.COMPLETE)
        setIsLoading(false)

        // Build summary message
        const tableCount = generation_summary?.tables_generated ?? val?.tables_found?.length ?? '?'
        const pct        = generation_summary?.completeness_pct ?? 100
        const score      = val?.score ?? '?'
        const grade      = val?.grade ?? ''
        const incomplete = generation_summary && !generation_summary.is_complete
          ? `\n⚠️ ${generation_summary.modules_failed} module(s) had errors — schema is ${pct}% complete.`
          : ''

        addMessage('assistant',
          `✅ Schema generated!\n\n` +
          `📊 **${tableCount} tables** across ${generation_summary?.modules_generated ?? '?'} modules\n` +
          `🏆 Quality score: **${score}/100** (Grade ${grade})${incomplete}\n\n` +
          `You can download the SQL file or ask me to explain any table.`,
          {
            schema: sql,
            validation: val,
            metadata: meta,
            generation_summary,
            action: 'schema_complete',
            download_urls: {
              sql: conversationApi.downloadSql(sessionId),
              pdf: conversationApi.downloadPdf(sessionId),
            }
          }
        )
      }, [addMessage]),

      onError: useCallback((errMsg) => {
        setStage(STAGES.CONFIRMED)   // let user retry
        setIsLoading(false)
        setError(errMsg)
        addMessage('assistant', `❌ Generation failed: ${errMsg}`, { isError: true })
      }, [addMessage]),
    })

  // ── Start a new session ──────────────────────────────────────
  const startSession = useCallback(async (projectId = null) => {
    setIsLoading(true)
    setError(null)

    try {
      const data = await conversationApi.start(projectId)
      setSessionId(data.session_id)
      setStage(data.stage)
      setMessages([])
      setBlueprint(null)
      setSchema(null)
      setValidation(null)
      setMetadata(null)
      setGenSummary(null)

      addMessage('assistant', data.message)
      return data.session_id
    } catch (err) {
      setError(err.message)
    } finally {
      setIsLoading(false)
    }
  }, [addMessage])

  // ── Load saved version ───────────────────────────────────────
  const loadExistingVersion = useCallback((version) => {
    cancel()
    setSessionId(`project_ver_${version.id}`)
    setStage(version.status === 'complete' ? STAGES.COMPLETE : STAGES.BLUEPRINT)
    setBlueprint(version.blueprint)
    setSchema(version.schema_sql)
    setValidation(version.validation_report)
    setMetadata({
      primary_domain: version.domain,
      scale: version.scale,
      gst_required: version.gst_required,
      modules_generated: version.modules_count,
      total_rules_applied: version.rules_applied_count,
    })
    
    setMessages([
      {
        id: 'loaded-ver-header',
        role: 'assistant',
        content: `📂 **Loaded saved architecture (Version v${version.version_number})**\n\nYou can review the structured blueprint, generated SQL schemas, and quality validation report in the right panel.`
      }
    ])
  }, [cancel])


  // ── Send a message ───────────────────────────────────────────
  const sendMessage = useCallback(async (text) => {
    if (!sessionId || !text.trim() || isLoading) return

    addMessage('user', text)
    setIsLoading(true)
    setError(null)

    // Show typing indicator
    const typingId = Date.now()
    setMessages(prev => [
      ...prev,
      { id: typingId, role: 'typing', content: '' }
    ])

    let isGeneratingTriggered = false

    try {
      const data = await conversationApi.message(sessionId, text)

      // Remove typing indicator
      setMessages(prev => prev.filter(m => m.id !== typingId))

      // NOTE: /conversation/message never returns a 5xx for an engine
      // failure anymore. On a backend hiccup it replies 200 with an
      // in-persona `message`, the preserved `stage`, and `success: false`.
      // We render that message as a normal assistant turn (no error
      // styling) and simply don't advance any optimistic state.
      // "unknown" is the sentinel stage from the last-resort handler —
      // never overwrite a real stage with it.
      if (data.stage && data.stage !== 'unknown') setStage(data.stage)
      if (data.blueprint) setBlueprint(data.blueprint)

      // ── Generation triggered by the conversation API ──────────
      // The conversation backend signals that the user confirmed and
      // generation should begin.  We submit a job and start polling.
      if (data.stage === STAGES.GENERATING && data.requirement) {
        isGeneratingTriggered = true
        addMessage('assistant', data.message || '🚀 Starting schema generation…', {
          action: 'generation_started',
        })
        // setIsLoading stays true — controlled by onComplete/onError
        submitAndPoll(
          data.requirement,
          data.blueprint   || blueprint,
          data.additional_context ?? null,
          sessionId,
        )
        return
      }

      // ── Normal conversation turn ──────────────────────────────
      // `metadata` / `validation` are not part of the default
      // /conversation/message contract (staff debug view only) — these
      // guards make their absence a no-op rather than a break.
      if (data.schema)     setSchema(data.schema)
      if (data.validation) setValidation(data.validation)
      if (data.metadata)   setMetadata(data.metadata)

      addMessage('assistant', data.message, {
        blueprint:                data.blueprint,
        schema:                   data.schema,
        validation:               data.validation,
        metadata:                 data.metadata,
        download_urls:            data.download_urls,
        detected_domain:          data.detected_domain,
        action:                   data.action,
        stage:                    data.stage,
        understanding_confidence: data.understanding_confidence,
        clarification_round:      data.clarification_round,
      })

    } catch (err) {
      setMessages(prev => prev.filter(m => m.id !== typingId))
      const errorMsg = err.message || 'Something went wrong. Please try again.'
      setError(errorMsg)
      addMessage('assistant', `❌ ${errorMsg}`, { isError: true })
    } finally {
      // Only clear loading if we're NOT waiting for a job to finish
      if (!isGeneratingTriggered) {
        setIsLoading(false)
      }
    }
  }, [sessionId, isLoading, blueprint, addMessage, submitAndPoll])

  // ── Reset ────────────────────────────────────────────────────
  const reset = useCallback(() => {
    cancel()
    setSessionId(null)
    setMessages([])
    setStage(STAGES.IDLE)
    setBlueprint(null)
    setSchema(null)
    setValidation(null)
    setMetadata(null)
    setGenSummary(null)
    setError(null)
    setIsLoading(false)
  }, [cancel])

  return {
    sessionId,
    messages,
    stage,
    blueprint,
    schema,
    validation,
    metadata,
    genSummary,
    isLoading,
    error,
    messagesEndRef,
    startSession,
    loadExistingVersion,
    sendMessage,
    reset,
    // Job polling state — passed to UI components
    jobId,
    jobStatus,
    progress,
    isPolling,
  }
}