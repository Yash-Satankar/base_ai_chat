// src/components/chat/MessageBubble.jsx
import React from 'react'
import { formatTimestamp } from '../../utils/formatters'
import BlueprintCard from '../blueprint/BlueprintCard'
import ValidationScore from '../schema/ValidationScore'
import DownloadButtons from '../schema/DownloadButtons'
import SchemaViewer from '../schema/SchemaViewer'
import TypingIndicator from './TypingIndicator'
import Logo from '../ui/Logo'

export default function MessageBubble({ message, sessionId }) {
  if (message.role === 'typing') return <TypingIndicator />

  const isUser = message.role === 'user'
  const isError = message.isError

  if (isUser) {
    return (
      <div className="group flex flex-col items-end anim-msg">
        <div className="max-w-[80%] rounded-2xl rounded-br-md border border-line bg-white/[0.05] px-4 py-2.5 text-[14px] leading-relaxed text-ink">
          {message.content}
        </div>
        <Time ts={message.timestamp} align="right" />
      </div>
    )
  }

  return (
    <div className="group flex gap-3 anim-msg">
      <Logo className="size-7 shrink-0" />
      <div className="min-w-0 flex-1 space-y-3">
        <div
          className={`text-[14.5px] leading-relaxed ${
            isError ? 'text-danger' : 'text-ink'
          }`}
        >
          <MessageContent content={message.content} />
        </div>

        {message.blueprint && <BlueprintCard blueprint={message.blueprint} />}
        {message.schema && <SchemaViewer schema={message.schema} />}
        {message.validation && <ValidationScore validation={message.validation} />}
        {message.download_urls && sessionId && <DownloadButtons sessionId={sessionId} />}
        {message.understanding_confidence !== undefined && (
          <ConfidenceBar value={message.understanding_confidence} />
        )}

        <Time ts={message.timestamp} align="left" />
      </div>
    </div>
  )
}

function Time({ ts, align }) {
  if (!ts) return null
  return (
    <p
      className={`px-0.5 pt-1 text-[11px] text-ink-faint opacity-0 transition-opacity group-hover:opacity-100 ${
        align === 'right' ? 'text-right' : 'text-left'
      }`}
    >
      {formatTimestamp(ts)}
    </p>
  )
}

function ConfidenceBar({ value }) {
  const pct = Math.min(100, Math.max(0, value))
  const bar = pct >= 85 ? 'bg-ok' : pct >= 60 ? 'bg-accent' : pct >= 40 ? 'bg-warn' : 'bg-ink-faint'
  const label =
    pct >= 85 ? 'Ready to design' : pct >= 60 ? 'Getting clear' : pct >= 40 ? 'Filling in details' : 'Still learning'
  return (
    <div className="flex items-center gap-2.5">
      <div className="h-1 w-28 overflow-hidden rounded-full bg-white/[0.06]">
        <div className={`h-full rounded-full transition-[width] duration-700 ${bar}`} style={{ width: `${pct}%` }} />
      </div>
      <span className="text-[11.5px] text-ink-dim">{pct}% · {label}</span>
    </div>
  )
}

/* lightweight markdown — bold / italic / inline code / rules / numbered rows */
function MessageContent({ content }) {
  if (!content) return null
  const lines = content.split('\n')

  return (
    <div className="space-y-2">
      {lines.map((line, i) => {
        if (line.trim() === '---') return <hr key={i} className="my-3 border-line" />
        if (!line.trim()) return <div key={i} className="h-1" />

        const html = line
          .replace(/\*\*(.*?)\*\*/g, '<strong class="font-semibold text-ink">$1</strong>')
          .replace(/(?<![*_`])([_*])(?![*_\s])(.+?)(?<![*_\s])\1(?![*_])/g, '<em class="text-ink-muted">$2</em>')
          .replace(
            /`([^`]+)`/g,
            '<code class="rounded-[5px] border border-line bg-white/[0.04] px-1.5 py-0.5 font-mono text-[12.5px] text-accent-hi">$1</code>'
          )

        const numbered = /^\s*(?:\*\*)?\d+[.)](?:\*\*)?\s/.test(line)
        if (numbered) {
          return (
            <div
              key={i}
              dangerouslySetInnerHTML={{ __html: html }}
              className="rounded-lg border border-line bg-white/[0.02] px-3.5 py-2.5 text-[13.5px] text-ink-muted"
            />
          )
        }
        return <p key={i} dangerouslySetInnerHTML={{ __html: html }} />
      })}
    </div>
  )
}
