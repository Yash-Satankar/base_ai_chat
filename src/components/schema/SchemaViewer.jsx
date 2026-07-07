// src/components/schema/SchemaViewer.jsx

import { useState } from 'react'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism'

export default function SchemaViewer({ schema }) {
  const [expanded, setExpanded] = useState(false)
  const [copied,   setCopied]   = useState(false)

  if (!schema) return null

  // Clean markdown fences
  const cleanSql = schema
    .replace(/```sql\n?/gi, '')
    .replace(/```\n?/g, '')
    .trim()

  // Count tables
  const tableCount = (cleanSql.match(/CREATE TABLE/gi) || []).length

  const handleCopy = async () => {
    await navigator.clipboard.writeText(cleanSql)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const previewSql = expanded
    ? cleanSql
    : cleanSql.split('\n').slice(0, 20).join('\n') + '\n\n-- ...'

  return (
    <div className="w-full rounded-xl border border-slate-700
                    bg-slate-900 overflow-hidden">

      {/* Header */}
      <div className="flex items-center justify-between
                      px-4 py-2 bg-slate-800 border-b border-slate-700">
        <div className="flex items-center gap-2">
          <span className="text-xs text-slate-400">
            📄 Generated Schema
          </span>
          <span className="text-xs bg-slate-700 text-slate-300
                           px-2 py-0.5 rounded">
            {tableCount} tables
          </span>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            className="text-xs text-slate-400 hover:text-white
                       transition-colors px-2 py-1 rounded
                       hover:bg-slate-700"
          >
            {copied ? '✓ Copied' : 'Copy'}
          </button>
          <button
            onClick={() => setExpanded(!expanded)}
            className="text-xs text-slate-400 hover:text-white
                       transition-colors px-2 py-1 rounded
                       hover:bg-slate-700"
          >
            {expanded ? 'Collapse' : 'Expand'}
          </button>
        </div>
      </div>

      {/* SQL content */}
      <div className={`overflow-auto transition-all duration-300
                       ${expanded ? 'max-h-[600px]' : 'max-h-64'}`}>
        <SyntaxHighlighter
          language="sql"
          style={vscDarkPlus}
          customStyle={{
            margin: 0,
            background: 'transparent',
            fontSize: '11px',
            lineHeight: '1.5',
          }}
          showLineNumbers
          lineNumberStyle={{ color: '#334155', fontSize: '10px' }}
        >
          {previewSql}
        </SyntaxHighlighter>
      </div>

      {/* Expand footer */}
      {!expanded && (
        <div
          onClick={() => setExpanded(true)}
          className="px-4 py-2 text-center text-xs text-blue-400
                     hover:text-blue-300 cursor-pointer bg-slate-800/50
                     border-t border-slate-700 hover:bg-slate-800
                     transition-colors"
        >
          Show full schema ↓
        </div>
      )}
    </div>
  )
}