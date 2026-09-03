// src/components/chat/TypingIndicator.jsx
import React from 'react'
import Logo from '../ui/Logo'

export default function TypingIndicator() {
  return (
    <div className="flex gap-3 anim-msg">
      <Logo className="size-7 shrink-0" />
      <div className="flex h-7 items-center gap-1.5">
        {[0, 1, 2].map(i => (
          <span
            key={i}
            className="typing-dot size-1.5 rounded-full bg-ink-dim"
            style={{ animationDelay: `${i * 0.16}s` }}
          />
        ))}
      </div>
    </div>
  )
}
