// src/components/chat/ChatWindow.jsx

import React from 'react'
import MessageBubble from './MessageBubble'

export default function ChatWindow({ messages, messagesEndRef, sessionId, onQuickStart }) {
  return (
    <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-6 space-y-5 scrollbar-thin">
      {messages.length === 0 && <EmptyState onQuickStart={onQuickStart} />}

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

function EmptyState({ onQuickStart }) {
  const SUGGESTIONS = [
    { title: 'Multi-Tenant SaaS', desc: 'B2B subscription billing, roles, organization isolation' },
    { title: 'Fintech Payment Ledger', desc: 'Double-entry ledger, transaction logs, audit trails' },
    { title: 'Healthcare EHR', desc: 'HIPAA compliance, patient charts, consent logs' },
    { title: 'E-Commerce Marketplace', desc: 'Orders, inventory matrix, GST invoice splits' },
  ]

  return (
    <div className="flex flex-col items-center justify-center min-h-[70vh] text-center py-12 px-4 max-w-2xl mx-auto">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-indigo-600/20 to-purple-600/20 border border-indigo-500/30 flex items-center justify-center text-3xl mb-6 shadow-lg shadow-indigo-500/10">
        ⚡
      </div>
      <h3 className="text-xl font-bold text-white mb-2 tracking-tight">
        BaseAI Enterprise Workbench
      </h3>
      <p className="text-slate-400 text-sm mb-8 leading-relaxed max-w-md">
        Describe your project requirements below to generate a production-ready MySQL database schema enforced by 109 architectural rules.
      </p>

      <div className="w-full grid grid-cols-1 sm:grid-cols-2 gap-3 text-left">
        {SUGGESTIONS.map((item, idx) => (
          <button
            key={idx}
            onClick={() => onQuickStart && onQuickStart(`Build a ${item.title} database with ${item.desc}`)}
            className="glass-card p-4 rounded-xl border border-slate-800 hover:border-indigo-500/40 transition-all text-left group"
          >
            <div className="font-semibold text-xs text-indigo-300 group-hover:text-indigo-200 mb-1 flex items-center justify-between">
              <span>{item.title}</span>
              <span className="opacity-0 group-hover:opacity-100 transition-opacity">→</span>
            </div>
            <p className="text-slate-400 text-[11px] leading-normal font-normal">
              {item.desc}
            </p>
          </button>
        ))}
      </div>
    </div>
  )
}