// src/components/chat/InputBar.jsx

import React, { useState, useRef, useEffect } from 'react'

export default function InputBar({
  onSend,
  disabled,
  stage,
  placeholder,
}) {
  const [text, setText] = useState('')
  const textareaRef = useRef(null)

  // Auto-resize textarea smoothly
  useEffect(() => {
    const el = textareaRef.current
    if (!el) return
    el.style.height = 'auto'
    el.style.height = Math.min(el.scrollHeight, 160) + 'px'
  }, [text])

  const handleSend = () => {
    const trimmed = text.trim()
    if (!trimmed || disabled) return
    onSend(trimmed)
    setText('')
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  const handleQuickReply = (reply) => {
    onSend(reply)
  }

  // Stage-specific quick replies
  const quickOptions = (() => {
    switch (stage) {
      case 'clarifying':
        return [
          { label: '✨ Generate Blueprint', value: 'Generate Blueprint' },
          { label: '🔄 Start over', value: 'Start over' },
        ]
      case 'blueprint':
        return [
          { label: '✅ YES — Confirm & Generate', value: 'YES' },
          { label: '✏️ Edit specifications', value: 'EDIT ' },
          { label: '➕ Add custom module', value: 'ADD ' },
          { label: '🔄 Start over', value: 'Start over' },
        ]
      case 'complete':
        return [
          { label: '📥 Download SQL DDL', value: 'Download files' },
          { label: '🔍 Explain schema table', value: 'Explain ' },
          { label: '🔄 Start new design', value: 'Start over' },
        ]
      default:
        return []
    }
  })()

  const getPlaceholder = () => {
    if (placeholder) return placeholder
    const map = {
      idle:       'Select or create a project to start...',
      initial:    'Describe your project (e.g. "A multi-tenant B2B billing engine with subscription tiers")',
      clarifying: 'Answer any questions above, or click "Generate Blueprint"...',
      blueprint:  'Type YES to confirm architecture, or describe modifications...',
      generating: 'AI Engine generating schema and building PDF specs...',
      complete:   'Ask to explain tables, download SQL/PDF deliverables, or refine requirements...',
    }
    return map[stage] || 'Type your message...'
  }

  return (
    <div className="border-t border-slate-800/80 bg-[#090d16]/90 backdrop-blur-xl px-4 py-3.5 space-y-2.5 shadow-2xl">
      {/* Quick reply pills */}
      {quickOptions.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {quickOptions.map((opt, i) => (
            <button
              key={i}
              onClick={() => {
                if (opt.value.endsWith(' ')) {
                  setText(opt.value)
                  textareaRef.current?.focus()
                } else {
                  handleQuickReply(opt.value)
                }
              }}
              disabled={disabled}
              className="text-xs px-3.5 py-1.5 rounded-full border border-slate-700/80 bg-slate-800/40 text-slate-300 hover:border-indigo-500/50 hover:text-white hover:bg-indigo-500/10 transition-all disabled:opacity-40 disabled:cursor-not-allowed font-medium shadow-xs"
            >
              {opt.label}
            </button>
          ))}
        </div>
      )}

      {/* Helper hint for clarifying round */}
      {stage === 'clarifying' && (
        <p className="text-[11px] text-slate-500 font-medium">
          💡 Provide high-level requirements — SchemaAI handles normalization, soft deletes, and index constraints.
        </p>
      )}

      {/* Input container */}
      <div className="flex items-end gap-3">
        <div className="flex-1 relative">
          <textarea
            ref={textareaRef}
            value={text}
            onChange={e => setText(e.target.value)}
            onKeyDown={handleKeyDown}
            disabled={disabled}
            placeholder={getPlaceholder()}
            rows={1}
            className="w-full bg-slate-900/90 border border-slate-800 rounded-2xl px-4 py-3 text-sm text-slate-100 placeholder-slate-500 resize-none focus:outline-none focus:border-indigo-500/60 focus:ring-2 focus:ring-indigo-500/20 disabled:opacity-50 disabled:cursor-not-allowed transition-all scrollbar-thin shadow-inner"
            style={{ minHeight: '50px' }}
          />
        </div>

        {/* Action Button */}
        <button
          onClick={handleSend}
          disabled={disabled || !text.trim()}
          className="w-12 h-12 rounded-2xl flex items-center justify-center bg-gradient-to-tr from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white disabled:opacity-40 disabled:cursor-not-allowed transition-all duration-200 shrink-0 shadow-lg shadow-indigo-600/20 hover:scale-105 active:scale-95"
          title="Send message (Enter)"
        >
          {disabled ? (
            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
          ) : (
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
            </svg>
          )}
        </button>
      </div>

      <div className="flex justify-between items-center px-1 text-[11px] text-slate-500">
        <span>Press <kbd className="px-1.5 py-0.5 bg-slate-800 rounded border border-slate-700 text-slate-400 font-mono text-[10px]">Enter</kbd> to send</span>
        <span><kbd className="px-1.5 py-0.5 bg-slate-800 rounded border border-slate-700 text-slate-400 font-mono text-[10px]">Shift + Enter</kbd> for line break</span>
      </div>
    </div>
  )
}