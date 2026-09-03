// src/components/schema/DownloadButtons.jsx
import React from 'react'
import { conversationApi } from '../../api/client'
import Icon from '../ui/Icon'

export default function DownloadButtons({ sessionId }) {
  if (!sessionId) return null

  const open = type => {
    const url = type === 'sql'
      ? conversationApi.downloadSql(sessionId)
      : conversationApi.downloadPdf(sessionId)
    window.open(url, '_blank')
  }

  return (
    <div className="grid grid-cols-2 gap-2">
      <Btn onClick={() => open('sql')} icon="file-code" label="schema.sql" sub="Run in MySQL" />
      <Btn onClick={() => open('pdf')} icon="file-text" label="docs.pdf" sub="Full documentation" />
    </div>
  )
}

function Btn({ onClick, icon, label, sub }) {
  return (
    <button
      onClick={onClick}
      className="group flex items-center gap-3 rounded-xl border border-line bg-bg-raised px-3 py-2.5 text-left shadow-inset-hl transition-[border-color,background-color] duration-150 hover:border-line-strong hover:bg-white/[0.02]"
    >
      <span className="grid size-8 shrink-0 place-items-center rounded-lg border border-line bg-white/[0.03] text-accent-hi">
        <Icon name={icon} className="size-[16px]" />
      </span>
      <span className="min-w-0">
        <span className="block truncate text-[12.5px] font-medium text-ink">{label}</span>
        <span className="block truncate text-[11px] text-ink-dim">{sub}</span>
      </span>
      <Icon name="download" className="ml-auto size-3.5 shrink-0 text-ink-faint transition-colors group-hover:text-ink-muted" />
    </button>
  )
}
