// src/hooks/useJobPoller.js
//
// Polls GET /planner/job/{jobId} every POLL_INTERVAL_MS until the job
// reaches a terminal state (done | failed), then fires onComplete/onError.
//
// Usage:
//   const { progress, jobId, isPolling, submitAndPoll } = useJobPoller({
//     onComplete: (result) => ...,
//     onError:    (errMsg) => ...,
//   })

import { useState, useRef, useCallback } from 'react'
import { plannerApi } from '../api/client'

const POLL_INTERVAL_MS  = 3000   // 3 seconds between polls
const MAX_POLLS         = 600    // 30 minutes max (600 × 3s)
const PROGRESS_RESET_MS = 60000  // reset poll counter if progress seen within 60s

export default function useJobPoller({ onComplete, onError }) {
  const [jobId,     setJobId]     = useState(null)
  const [isPolling, setIsPolling] = useState(false)
  const [progress,  setProgress]  = useState(null)
  const [jobStatus, setJobStatus] = useState(null)   // queued | generating | done | failed

  const timerRef       = useRef(null)
  const pollCount      = useRef(0)
  const activeJob      = useRef(null)
  const lastTablesRef  = useRef(0)   // track progress to avoid premature timeout
  const lastProgressTs = useRef(0)   // timestamp of last real progress

  // ── Stop polling ──────────────────────────────────────────────
  const stopPolling = useCallback(() => {
    if (timerRef.current) {
      clearTimeout(timerRef.current)
      timerRef.current = null
    }
    setIsPolling(false)
    pollCount.current    = 0
    lastTablesRef.current  = 0
    lastProgressTs.current = 0
  }, [])

  // ── Single poll tick ──────────────────────────────────────────
  const tick = useCallback(async (jid) => {
    if (activeJob.current !== jid) return   // job was superseded

    pollCount.current += 1

    // If the job is actively making progress, reset the poll counter so
    // a large (90+ table) schema never gets cut off mid-generation.
    const now = Date.now()
    if (pollCount.current > MAX_POLLS) {
      const timeSinceProgress = now - lastProgressTs.current
      if (timeSinceProgress < PROGRESS_RESET_MS) {
        // Still making progress — give it more time
        pollCount.current = Math.floor(MAX_POLLS * 0.8)
      } else {
        stopPolling()
        onError?.(
          'Generation timed out. The schema is very large — try splitting it into ' +
          'fewer modules or type "regenerate" to retry.'
        )
        return
      }
    }

    try {
      const data = await plannerApi.pollJob(jid)
      if (activeJob.current !== jid) return  // superseded during await

      setJobStatus(data.status)
      if (data.progress) {
        setProgress(data.progress)
        // Track whether the backend is actually making progress
        const tablesDone = data.progress?.tables_done ?? 0
        if (tablesDone > lastTablesRef.current) {
          lastTablesRef.current  = tablesDone
          lastProgressTs.current = Date.now()
        }
      }

      if (data.status === 'done') {
        stopPolling()
        onComplete?.(data.result)
        return
      }

      if (data.status === 'failed') {
        stopPolling()
        onError?.(data.error || 'Schema generation failed.')
        return
      }

      // Still running — schedule next tick
      timerRef.current = setTimeout(() => tick(jid), POLL_INTERVAL_MS)

    } catch (err) {
      // Network hiccup — keep polling, don't abort
      console.warn('[useJobPoller] poll error (will retry):', err.message)
      timerRef.current = setTimeout(() => tick(jid), POLL_INTERVAL_MS * 2)
    }
  }, [stopPolling, onComplete, onError])

  // ── Submit a new job and start polling ────────────────────────
  const submitAndPoll = useCallback(async (requirement, blueprint = null, additionalContext = null, sessionId = null, mode = 'schema') => {
    // Cancel any in-flight job
    stopPolling()
    activeJob.current = null

    setProgress(null)
    setJobStatus('queued')
    setIsPolling(true)
    setJobId(null)
    lastTablesRef.current  = 0
    lastProgressTs.current = Date.now()

    try {
      const data = await plannerApi.submitJob(requirement, blueprint, additionalContext, sessionId, mode)
      const newJobId = data.job_id
      setJobId(newJobId)
      activeJob.current = newJobId
      pollCount.current = 0

      // Start polling after a short delay (backend needs a moment to start)
      timerRef.current = setTimeout(() => tick(newJobId), 1500)

    } catch (err) {
      stopPolling()
      onError?.(err.message || 'Failed to submit generation job.')
    }
  }, [stopPolling, tick, onError])

  // ── Cancel (call on unmount or user abort) ─────────────────────
  const cancel = useCallback(() => {
    activeJob.current = null
    stopPolling()
    setProgress(null)
    setJobStatus(null)
    setJobId(null)
  }, [stopPolling])

  return {
    jobId,
    jobStatus,
    progress,
    isPolling,
    submitAndPoll,
    cancel,
  }
}
