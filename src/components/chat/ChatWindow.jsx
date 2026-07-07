// src/components/chat/ChatWindow.jsx

import MessageBubble from './MessageBubble'
import TypingIndicator from './TypingIndicator'

export default function ChatWindow({ messages, messagesEndRef, sessionId }) {
  return (
    <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4
                    scrollbar-thin">

      {messages.length === 0 && (
        <EmptyState />
      )}

      {messages.map(message => (
        <MessageBubble
          key={message.id}
          message={message}
          sessionId={sessionId}
        />
      ))}

      <div ref={messagesEndRef} />
    </div>
  )
}


function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center
                    h-full text-center py-20">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-br
                      from-blue-500/20 to-purple-500/20
                      border border-blue-500/20
                      flex items-center justify-center text-3xl mb-4">
        🗄️
      </div>
      <h3 className="text-slate-300 font-medium mb-2">
        AI Database Schema Generator
      </h3>
      <p className="text-slate-500 text-sm max-w-xs">
        Describe your project and I'll generate a production-quality
        MySQL schema with 109 real-world rules applied.
      </p>
    </div>
  )
}