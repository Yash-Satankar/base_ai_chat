// src/components/schema/SchemaViewer.jsx

import React, { useState } from 'react'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism'

export default function SchemaViewer({ schema }) {
  const [expanded, setExpanded] = useState(false)
  const [copied, setCopied] = useState(false)

  if (!schema) return null

  // Clean markdown code blocks
  const cleanSql = schema
    .replace(/```sql\n?/gi, '')
    .replace(/```\n?/g, '')
    .trim()

  const tableCount = (cleanSql.match(/CREATE TABLE/gi) || []).length

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(cleanSql)
      setCopied(true)
      setTimeout(() => setCopied(false), 2200)
    } catch (e) {
      console.error('Copy failed:', e)
    }
  }

  const previewSql = expanded
    ? cleanSql
    : cleanSql.split('\n').slice(0, 24).join('\n') + '\n\n-- ... [Expand to view full DDL schema]'

  return (
    <div className="w-full rounded-2xl border border-slate-800 bg-[#060911] overflow-hidden shadow-xl glass-panel">
      {/* Header Bar */}
      <div className="flex items-center justify-between px-4 py-2.5 bg-slate-900/90 border-b border-slate-800">
        <div className="flex items-center gap-2.5">
          <span className="w-2.5 h-2.5 rounded-full bg-emerald-400" />
          <span className="text-xs font-bold text-white tracking-wide">
            Generated MySQL Schema
          </span>
          <span className="text-[11px] font-semibold bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 px-2 py-0.5 rounded-md">
            {tableCount} Tables
          </span>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            className="text-xs font-semibold text-slate-300 hover:text-white transition-all px-3 py-1 rounded-lg bg-slate-800/80 hover:bg-indigo-600/30 border border-slate-700/80"
          >
            {copied ? '✓ Copied!' : 'Copy SQL'}
          </button>
          <button
            onClick={() => setExpanded(!expanded)}
            className="text-xs font-semibold text-slate-300 hover:text-white transition-all px-3 py-1 rounded-lg bg-slate-800/80 hover:bg-slate-700/80 border border-slate-700/80"
          >
            {expanded ? 'Collapse' : 'Expand'}
          </button>
        </div>
      </div>

      {/* Syntax Code Area */}
      <div className={`overflow-auto transition-all duration-300 scrollbar-thin ${expanded ? 'max-h-[600px]' : 'max-h-72'}`}>
        <SyntaxHighlighter
          language="sql"
          style={vscDarkPlus}
          customStyle={{
            margin: 0,
            padding: '1rem',
            background: 'transparent',
            fontSize: '11px',
            lineHeight: '1.6',
          }}
          showLineNumbers
          lineNumberStyle={{ color: '#334155', fontSize: '10px' }}
        >
          {previewSql}
        </SyntaxHighlighter>
      </div>

      {/* Footer Toggle */}
      {!expanded && (
        <button
          onClick={() => setExpanded(true)}
          className="w-full py-2.5 text-center text-xs font-semibold text-indigo-400 hover:text-indigo-300 bg-slate-900/60 border-t border-slate-800/80 hover:bg-slate-900 transition-colors flex items-center justify-center gap-1"
        >
          <span>View complete {tableCount} table schema DDL</span>
          <span>↓</span>
        </button>
      )}
    </div>
  )
}