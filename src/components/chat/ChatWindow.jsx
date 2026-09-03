// src/components/chat/ChatWindow.jsx
import React from 'react'
import MessageBubble from './MessageBubble'
import Icon from '../ui/Icon'
import Logo from '../ui/Logo'

const SUGGESTIONS = [
  {
    icon: '☁️',
    text: 'A multi-tenant B2B billing engine with usage-based tiers and Stripe payouts',
  },
  {
    icon: '🏥',
    text: 'Hospital patient records with admissions, visit history, prescriptions and lab results',
  },
  {
    icon: '🚚',
    text: 'A logistics platform: shipments, routes, driver rosters and delivery scan events',
  },
  {
    icon: '🛒',
    text: 'A marketplace with vendors, orders, inventory, payouts and dispute handling',
  },
]

export default function ChatWindow({ messages, messagesEndRef, sessionId, onQuickStart }) {
  const empty = messages.length === 0

  return (
    <div className="scroll-thin flex-1 overflow-y-auto">
      <div className="mx-auto max-w-3xl px-4 py-8 sm:px-6">
        {empty ? (
          <Welcome onPick={onQuickStart} />
        ) : (
          <div className="space-y-7">
            {messages.map(m => (
              <MessageBubble key={m.id} message={m} sessionId={sessionId} />
            ))}
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>
    </div>
  )
}

function Welcome({ onPick }) {
  return (
    <div className="flex min-h-[62vh] flex-col items-center justify-center py-10 text-center animate-fade-in">
      <div className="relative mb-6">
        <div aria-hidden className="absolute -inset-6 rounded-full bg-accent/15 blur-2xl" />
        <Logo className="relative size-12" />
      </div>

      <h2 className="text-[22px] font-semibold tracking-tight text-ink">What are we building?</h2>
      <p className="mt-2 max-w-md text-[14px] leading-relaxed text-ink-muted">
        Describe your system in plain English. I&apos;ll ask what I need, then design the schema.
      </p>

      <div className="mt-8 grid w-full grid-cols-1 gap-2.5 text-left sm:grid-cols-2">
        {SUGGESTIONS.map((s, i) => (
          <button
            key={i}
            onClick={() => onPick && onPick(s.text)}
            className="group flex items-start gap-3 rounded-xl border border-line bg-bg-raised p-3.5 text-[13px] leading-relaxed text-ink-muted shadow-inset-hl transition-[border-color,background-color] duration-150 hover:border-line-strong hover:bg-white/[0.02] hover:text-ink"
          >
            <span className="mt-px text-[15px]">{s.icon}</span>
            <span className="flex-1">{s.text}</span>
            <Icon
              name="arrow-up-right"
              className="mt-0.5 size-3.5 shrink-0 text-ink-faint opacity-0 transition-opacity group-hover:opacity-100"
            />
          </button>
        ))}
      </div>
    </div>
  )
}
