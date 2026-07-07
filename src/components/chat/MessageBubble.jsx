// src/components/chat/MessageBubble.jsx

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
    <div className={`flex items-start gap-3 chat-message
                     ${isUser ? 'flex-row-reverse' : ''}`}>

      {/* Avatar */}
      <div className={`w-8 h-8 rounded-full flex items-center justify-center
                       text-xs font-bold shrink-0
                       ${isUser
                         ? 'bg-slate-600 text-slate-200'
                         : 'bg-gradient-to-br from-blue-500 to-purple-600 text-white'
                       }`}>
        {isUser ? 'You' : '🤖'}
      </div>

      {/* Bubble */}
      <div className={`max-w-[80%] space-y-3 ${isUser ? 'items-end' : 'items-start'}`}>

        {/* Text content */}
        <div className={`rounded-2xl px-4 py-3 text-sm leading-relaxed
                         ${isUser
                           ? 'bg-blue-600 text-white rounded-tr-sm'
                           : isError
                             ? 'bg-red-500/10 border border-red-500/30 text-red-300 rounded-tl-sm'
                             : 'bg-slate-800 border border-slate-700 text-slate-200 rounded-tl-sm'
                         }`}>
          <MessageContent content={message.content} />
        </div>

        {/* Blueprint card if present */}
        {message.blueprint && (
          <BlueprintCard blueprint={message.blueprint} />
        )}

        {/* Schema viewer if present */}
        {message.schema && (
          <SchemaViewer schema={message.schema} />
        )}

        {/* Validation score if present */}
        {message.validation && (
          <ValidationScore validation={message.validation} />
        )}

        {/* Download buttons if complete */}
        {message.download_urls && sessionId && (
          <DownloadButtons sessionId={sessionId} />
        )}

        {/* Understanding confidence bar (from clarifying rounds) */}
        {message.understanding_confidence !== undefined && !isUser && (
          <UnderstandingBadge confidence={message.understanding_confidence} />
        )}

        {/* Timestamp */}
        <p className={`text-xs text-slate-500 px-1
                       ${isUser ? 'text-right' : 'text-left'}`}>
          {formatTimestamp(message.timestamp)}
        </p>
      </div>
    </div>
  )
}


// ── Understanding confidence badge ───────────────────────────────
function UnderstandingBadge({ confidence }) {
  const pct = Math.min(100, Math.max(0, confidence))
  const color = pct >= 85 ? 'bg-green-500' : pct >= 60 ? 'bg-blue-500' : pct >= 40 ? 'bg-yellow-500' : 'bg-slate-500'
  const label = pct >= 85 ? 'Ready to design!' : pct >= 60 ? 'Getting clearer' : pct >= 40 ? 'Building context' : 'Just getting started'

  return (
    <div className="flex items-center gap-2 px-1 mt-1">
      <div className="flex-1 h-1 bg-slate-700 rounded-full overflow-hidden">
        <div
          className={`h-full rounded-full transition-all duration-700 ${color}`}
          style={{ width: `${pct}%` }}
        />
      </div>
      <span className="text-[10px] text-slate-500 whitespace-nowrap">{pct}% — {label}</span>
    </div>
  )
}


// ── Render markdown-like formatting ─────────────────────────────
function MessageContent({ content }) {
  if (!content) return null

  // Split by newlines and render with basic markdown
  const lines = content.split('\n')

  return (
    <div className="space-y-1">
      {lines.map((line, i) => {
        // Bold: **text**
        const formatted = line.replace(
          /\*\*(.*?)\*\*/g,
          '<strong>$1</strong>'
        )
        // Italic: _text_ or *text*
        const withItalic = formatted.replace(
          /(?<![*_])([_*])(?![*_\s])(.*?)(?<![*_\s])\1(?![*_])/g,
          '<em>$2</em>'
        )
        // Inline code: `text`
        const withCode = withItalic.replace(
          /`([^`]+)`/g,
          '<code class="bg-slate-900 px-1 py-0.5 rounded text-blue-300 text-xs font-mono">$1</code>'
        )
        // Horizontal rule
        if (line.trim() === '---') {
          return <hr key={i} className="border-slate-600 my-2" />
        }
        // Empty line
        if (!line.trim()) {
          return <br key={i} />
        }
        // Numbered question lines (e.g. **1.** some question)
        if (/^\*\*\d+\.\*\*/.test(line.trim())) {
          return (
            <div
              key={i}
              dangerouslySetInnerHTML={{ __html: withCode }}
              className="bg-slate-700/50 border border-slate-600/50 rounded-lg px-3 py-2 mt-1 leading-relaxed"
            />
          )
        }

        return (
          <p
            key={i}
            dangerouslySetInnerHTML={{ __html: withCode }}
            className="leading-relaxed"
          />
        )
      })}
    </div>
  )
}