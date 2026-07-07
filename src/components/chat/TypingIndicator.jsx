// src/components/chat/TypingIndicator.jsx

export default function TypingIndicator() {
  return (
    <div className="flex items-start gap-3 chat-message">
      {/* Avatar */}
      <div className="w-8 h-8 rounded-full bg-gradient-to-br
                      from-blue-500 to-purple-600
                      flex items-center justify-center
                      text-white text-xs font-bold shrink-0">
        AI
      </div>

      {/* Dots */}
      <div className="bg-slate-800 border border-slate-700
                      rounded-2xl rounded-tl-sm px-4 py-3">
        <div className="flex gap-1.5 items-center h-4">
          {[0, 1, 2].map(i => (
            <div
              key={i}
              className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce"
              style={{ animationDelay: `${i * 0.15}s` }}
            />
          ))}
        </div>
      </div>
    </div>
  )
}