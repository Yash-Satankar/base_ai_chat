// src/components/chat/InputBar.jsx

import { useState, useRef, useEffect } from 'react'

export default function InputBar({
  onSend,
  disabled,
  stage,
  placeholder,
}) {
  const [text, setText] = useState('')
  const textareaRef = useRef(null)

  // Auto-resize textarea
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
          { label: '✅ Generate Blueprint', value: 'Generate Blueprint' },
          { label: '🔄 Start over', value: 'Start over' },
        ]
      case 'blueprint':
        return [
          { label: '✅ YES — looks good!', value: 'YES' },
          { label: '✏️ Edit something', value: 'EDIT ' },
          { label: '➕ Add a module', value: 'ADD ' },
          { label: '🔄 Start over', value: 'Start over' },
        ]
      case 'complete':
        return [
          { label: '📥 Download files', value: 'Download files' },
          { label: '❓ Explain a table', value: 'Explain ' },
          { label: '🔄 Start over', value: 'Start over' },
        ]
      default:
        return []
    }
  })()

  const getPlaceholder = () => {
    if (placeholder) return placeholder
    const map = {
      idle:       'Start a new session first...',
      initial:    'Describe the database you want to build — e.g. "an Airbnb-style rental platform"',
      clarifying: 'Answer the questions above, or type "Generate Blueprint" to proceed...',
      blueprint:  'Type YES to confirm, or describe any changes...',
      generating: 'Generating your schema...',
      complete:   'Ask me to explain a table, download files, or start a new project...',
    }
    return map[stage] || 'Type a message...'
  }

  return (
    <div className="border-t border-slate-800 bg-slate-900/95
                    backdrop-blur-sm px-4 py-3 space-y-2">

      {/* Quick replies */}
      {quickOptions.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {quickOptions.map((opt, i) => (
            <button
              key={i}
              onClick={() => {
                // If value ends with space (like 'EDIT ', 'ADD '), put it in the input box
                if (opt.value.endsWith(' ')) {
                  setText(opt.value)
                  textareaRef.current?.focus()
                } else {
                  handleQuickReply(opt.value)
                }
              }}
              disabled={disabled}
              className="text-xs px-3 py-1.5 rounded-full
                         border border-slate-700 text-slate-400
                         hover:border-blue-500/50 hover:text-blue-300
                         hover:bg-blue-500/5 transition-all
                         disabled:opacity-40 disabled:cursor-not-allowed
                         font-medium"
            >
              {opt.label}
            </button>
          ))}
        </div>
      )}

      {/* Context hint for clarifying stage */}
      {stage === 'clarifying' && (
        <p className="text-[11px] text-slate-600 leading-relaxed">
          💡 Answer as much as you know — the more detail, the better the schema. Skip anything that doesn't apply.
        </p>
      )}

      {/* Input row */}
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
            className="w-full bg-slate-800 border border-slate-700
                       rounded-xl px-4 py-3 text-sm text-slate-200
                       placeholder-slate-500 resize-none
                       focus:outline-none focus:border-blue-500/50
                       focus:ring-1 focus:ring-blue-500/20
                       disabled:opacity-50 disabled:cursor-not-allowed
                       transition-all scrollbar-thin"
            style={{ minHeight: '48px' }}
          />
        </div>

        {/* Send button */}
        <button
          onClick={handleSend}
          disabled={disabled || !text.trim()}
          className="w-11 h-11 rounded-xl flex items-center justify-center
                     bg-blue-600 hover:bg-blue-500 text-white
                     disabled:opacity-40 disabled:cursor-not-allowed
                     transition-all duration-200 shrink-0
                     hover:scale-105 active:scale-95"
        >
          {disabled ? (
            <div className="w-4 h-4 border-2 border-white/30
                            border-t-white rounded-full animate-spin" />
          ) : (
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24"
                 stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round"
                    strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
            </svg>
          )}
        </button>
      </div>

      <p className="text-xs text-slate-600 text-center">
        Press Enter to send · Shift+Enter for new line
      </p>
    </div>
  )
}