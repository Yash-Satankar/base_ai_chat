// src/components/schema/SchemaViewer.jsx
import React, { useState } from 'react'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism'
import Icon from '../ui/Icon'

export default function SchemaViewer({ schema }) {
  const [expanded, setExpanded] = useState(false)
  const [copied, setCopied] = useState(false)
  if (!schema) return null

  const sql = schema.replace(/```sql\n?/gi, '').replace(/```\n?/g, '').trim()
  const tables = (sql.match(/CREATE TABLE/gi) || []).length

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(sql)
      setCopied(true)
      setTimeout(() => setCopied(false), 1800)
    } catch (e) {
      console.error(e)
    }
  }

  const shown = expanded ? sql : sql.split('\n').slice(0, 22).join('\n') + '\n\n-- …'

  return (
    <div className="w-full overflow-hidden rounded-xl border border-line bg-bg-input shadow-inset-hl">
      <div className="flex items-center justify-between border-b border-line px-3.5 py-2">
        <div className="flex items-center gap-2">
          <span className="size-2 rounded-full bg-ok" />
          <span className="text-[12.5px] font-medium text-ink">MySQL schema</span>
          <span className="rounded-md border border-line bg-white/[0.03] px-1.5 py-px text-[10.5px] text-ink-muted">
            {tables} tables
          </span>
        </div>
        <div className="flex items-center gap-1">
          <button
            onClick={copy}
            className="inline-flex items-center gap-1.5 rounded-md px-2 py-1 text-[12px] text-ink-muted transition-colors hover:bg-white/[0.06] hover:text-ink"
          >
            <Icon name={copied ? 'check' : 'copy'} className="size-3.5" strokeWidth={copied ? 2.4 : 1.6} />
            {copied ? 'Copied' : 'Copy'}
          </button>
          <button
            onClick={() => setExpanded(e => !e)}
            className="rounded-md px-2 py-1 text-[12px] text-ink-muted transition-colors hover:bg-white/[0.06] hover:text-ink"
          >
            {expanded ? 'Collapse' : 'Expand'}
          </button>
        </div>
      </div>

      <div className={`scroll-thin overflow-auto transition-[max-height] duration-300 ${expanded ? 'max-h-[560px]' : 'max-h-64'}`}>
        <SyntaxHighlighter
          language="sql"
          style={vscDarkPlus}
          customStyle={{ margin: 0, padding: '0.9rem 1rem', background: 'transparent', fontSize: '11.5px', lineHeight: '1.6' }}
          codeTagProps={{ style: { fontFamily: '"JetBrains Mono", monospace' } }}
          showLineNumbers
          lineNumberStyle={{ color: '#3f3f46', fontSize: '10px', minWidth: '2em' }}
        >
          {shown}
        </SyntaxHighlighter>
      </div>

      {!expanded && (
        <button
          onClick={() => setExpanded(true)}
          className="flex w-full items-center justify-center gap-1.5 border-t border-line bg-white/[0.02] py-2 text-[12px] font-medium text-accent-hi transition-colors hover:bg-white/[0.04]"
        >
          View all {tables} tables
          <Icon name="chevron-down" className="size-3.5" />
        </button>
      )}
    </div>
  )
}
