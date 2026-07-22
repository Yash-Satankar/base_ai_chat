// src/components/chat/MessageBubble.jsx

import React from 'react'
import { formatTimestamp } from '../../utils/formatters'
import BlueprintCard from '../blueprint/BlueprintCard'
import ValidationScore from '../schema/ValidationScore'
import DownloadButtons from '../schema/DownloadButtons'
import SchemaViewer from '../schema/SchemaViewer'
import TypingIndicator from './TypingIndicator'

export default function MessageBubble({ message, sessionId }) {
  if (message.role === 'typing') {
    return <TypingIndicator />
  }

  const isUser = message.role === 'user'
  const isError = message.isError

  return (
    <div className={`flex items-start gap-3.5 chat-message ${isUser ? 'flex-row-reverse' : ''}`}>
      {/* Avatar */}
      <div
        className={`w-9 h-9 rounded-xl flex items-center justify-center text-xs font-bold shrink-0 shadow-md transition-transform ${
          isUser
            ? 'bg-slate-800 text-slate-200 border border-slate-700'
            : 'bg-gradient-to-tr from-indigo-600 to-purple-600 text-white shadow-indigo-500/20'
        }`}
      >
        {isUser ? 'YOU' : 'AI'}
      </div>

      {/* Bubble Container */}
      <div className={`max-w-[82%] space-y-3.5 ${isUser ? 'items-end' : 'items-start'}`}>
        {/* Text content */}
        <div
          className={`rounded-2xl px-4.5 py-3.5 text-sm leading-relaxed shadow-sm ${
            isUser
              ? 'bg-gradient-to-r from-indigo-600 to-indigo-700 text-white rounded-tr-xs shadow-indigo-900/30'
              : isError
              ? 'bg-rose-500/10 border border-rose-500/30 text-rose-200 rounded-tl-xs'
              : 'glass-panel text-slate-100 border border-slate-800/90 rounded-tl-xs'
          }`}
        >
          <MessageContent content={message.content} />
        </div>

        {/* Blueprint card if present */}
        {message.blueprint && <BlueprintCard blueprint={message.blueprint} />}

        {/* Schema viewer if present */}
        {message.schema && <SchemaViewer schema={message.schema} />}

        {/* Validation score if present */}
        {message.validation && <ValidationScore validation={message.validation} />}

        {/* Download buttons if complete */}
        {message.download_urls && sessionId && <DownloadButtons sessionId={sessionId} />}

        {/* Understanding confidence bar */}
        {message.understanding_confidence !== undefined && !isUser && (
          <UnderstandingBadge confidence={message.understanding_confidence} />
        )}

        {/* Timestamp */}
        <p className={`text-[11px] text-slate-500 font-medium px-1.5 ${isUser ? 'text-right' : 'text-left'}`}>
          {formatTimestamp(message.timestamp)}
        </p>
      </div>
    </div>
  )
}

function UnderstandingBadge({ confidence }) {
  const pct = Math.min(100, Math.max(0, confidence))
  const color =
    pct >= 85 ? 'bg-emerald-500' : pct >= 60 ? 'bg-indigo-500' : pct >= 40 ? 'bg-amber-500' : 'bg-slate-600'
  const label =
    pct >= 85 ? 'Architecture Confirmed' : pct >= 60 ? 'Refining Details' : pct >= 40 ? 'Gathering Specs' : 'Analyzing Input'

  return (
    <div className="flex items-center gap-2.5 px-2 py-1 glass-card rounded-lg border border-slate-800">
      <div className="flex-1 h-1.5 bg-slate-800 rounded-full overflow-hidden">
        <div className={`h-full rounded-full transition-all duration-700 ${color}`} style={{ width: `${pct}%` }} />
      </div>
      <span className="text-[11px] font-semibold text-slate-400 whitespace-nowrap">
        {pct}% • {label}
      </span>
    </div>
  )
}

function MessageContent({ content }) {
  if (!content) return null

  const lines = content.split('\n')

  return (
    <div className="space-y-1.5">
      {lines.map((line, i) => {
        const formatted = line.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        const withItalic = formatted.replace(/(?<![*_])([_*])(?![*_\s])(.*?)(?<![*_\s])\1(?![*_])/g, '<em>$2</em>')
        const withCode = withItalic.replace(
          /`([^`]+)`/g,
          '<code class="bg-slate-900/80 border border-slate-700/60 px-1.5 py-0.5 rounded text-indigo-300 font-mono text-xs">$1</code>'
        )

        if (line.trim() === '---') {
          return <hr key={i} className="border-slate-700/80 my-3" />
        }

        if (!line.trim()) {
          return <div key={i} className="h-1.5" />
        }

        if (/^\*\*\d+\.\*\*/.test(line.trim())) {
          return (
            <div
              key={i}
              dangerouslySetInnerHTML={{ __html: withCode }}
              className="bg-slate-800/60 border border-slate-700/60 rounded-xl px-3.5 py-2.5 my-1.5 text-slate-200 shadow-inner"
            />
          )
        }

        return <p key={i} dangerouslySetInnerHTML={{ __html: withCode }} className="leading-relaxed" />
      })}
    </div>
  )
}