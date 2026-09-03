// src/components/chat/InputBar.jsx
import React, { useState, useRef, useEffect } from 'react'
import Icon from '../ui/Icon'
import Spinner from '../ui/Spinner'

const PLACEHOLDERS = {
  idle:       'Pick or start a design to begin…',
  initial:    'Describe your system — e.g. "A subscription billing engine with usage tiers"',
  clarifying: 'Answer the questions above, or say "Generate Blueprint"…',
  compiling:  'Designing the blueprint…',
  blueprint:  'Type YES to build the SQL, or describe a change…',
  generating: 'Generating your schema…',
  complete:   'Ask to explain a table, download files, or refine…',
}

const QUICK = {
  clarifying: [
    { label: 'Generate Blueprint', value: 'Generate Blueprint' },
    { label: 'Start over', value: 'Start over' },
  ],
  blueprint: [
    { label: 'YES — confirm & generate', value: 'YES' },
    { label: 'Edit…', value: 'EDIT ', fill: true },
    { label: 'Add module…', value: 'ADD ', fill: true },
    { label: 'Start over', value: 'Start over' },
  ],
  complete: [
    { label: 'Download files', value: 'Download files' },
    { label: 'Explain a table…', value: 'Explain ', fill: true },
    { label: 'Start new design', value: 'Start over' },
  ],
}

export default function InputBar({ onSend, disabled, stage, placeholder }) {
  const [text, setText] = useState('')
  const ref = useRef(null)

  useEffect(() => {
    const el = ref.current
    if (!el) return
    el.style.height = 'auto'
    el.style.height = Math.min(el.scrollHeight, 200) + 'px'
  }, [text])

  const send = () => {
    const t = text.trim()
    if (!t || disabled) return
    onSend(t)
    setText('')
  }

  const onKeyDown = e => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      send()
    }
  }

  const quick = QUICK[stage] || []
  const canSend = !!text.trim() && !disabled

  return (
    <div className="shrink-0 border-t border-line bg-bg/80 px-4 pb-4 pt-3 backdrop-blur-xl">
      <div className="mx-auto max-w-3xl">
        {quick.length > 0 && (
          <div className="mb-2.5 flex flex-wrap gap-1.5">
            {quick.map((q, i) => (
              <button
                key={i}
                disabled={disabled}
                onClick={() => {
                  if (q.fill) { setText(q.value); ref.current?.focus() }
                  else onSend(q.value)
                }}
                className="rounded-full border border-line bg-white/[0.03] px-3 py-1 text-[12px] text-ink-muted transition-colors hover:border-line-strong hover:text-ink disabled:opacity-40"
              >
                {q.label}
              </button>
            ))}
          </div>
        )}

        <div className="group flex items-end gap-2 rounded-2xl border border-line bg-bg-input px-3 py-2.5 shadow-inset-hl transition-[border-color,box-shadow] duration-150 focus-within:border-accent-line focus-within:shadow-[0_0_0_3px_theme(colors.accent.bg)]">
          <textarea
            ref={ref}
            rows={1}
            value={text}
            disabled={disabled}
            onChange={e => setText(e.target.value)}
            onKeyDown={onKeyDown}
            placeholder={placeholder || PLACEHOLDERS[stage] || 'Type a message…'}
            className="scroll-thin max-h-[200px] flex-1 resize-none bg-transparent py-1 text-[14px] leading-relaxed text-ink placeholder:text-ink-faint focus:outline-none disabled:opacity-50"
          />
          <button
            onClick={send}
            disabled={!canSend}
            title="Send (Enter)"
            className={`grid size-8 shrink-0 place-items-center rounded-lg transition-[background-color,color,opacity] duration-150 ${
              canSend
                ? 'bg-accent text-white hover:bg-accent-hi'
                : 'bg-white/[0.05] text-ink-faint'
            }`}
          >
            {disabled ? <Spinner size="xs" /> : <Icon name="arrow-up" className="size-4" strokeWidth={2} />}
          </button>
        </div>

        <div className="mt-1.5 flex justify-center gap-3 text-[11px] text-ink-faint">
          <span><kbd>Enter</kbd> to send</span>
          <span><kbd>Shift</kbd> + <kbd>Enter</kbd> for a new line</span>
        </div>
      </div>
    </div>
  )
}
