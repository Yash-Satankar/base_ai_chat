// src/components/blueprint/ModuleTable.jsx
import React, { useState } from 'react'
import Icon from '../ui/Icon'

export default function ModuleTable({ module, index }) {
  const [open, setOpen] = useState(true)
  const count = module.tables?.length || 0

  return (
    <div className="px-4 py-3">
      <button onClick={() => setOpen(o => !o)} className="flex w-full items-center gap-2 text-left">
        <span className="grid size-[18px] shrink-0 place-items-center rounded-md border border-accent-line bg-accent-bg font-mono text-[10px] text-accent-hi">
          {index}
        </span>
        <span className="text-[13px] font-medium text-ink">{module.name}</span>
        <span className="min-w-0 flex-1 truncate text-[12px] text-ink-dim">{module.description}</span>
        <span className="shrink-0 text-[11px] text-ink-faint">{count}</span>
        <Icon name="chevron-down" className={`size-3.5 shrink-0 text-ink-faint transition-transform ${open ? '' : '-rotate-90'}`} />
      </button>

      {open && count > 0 && (
        <div className="mt-2 ml-6 space-y-1 border-l border-line pl-3">
          {module.tables.map((t, i) => (
            <div key={i} className="flex items-baseline gap-2 text-[12px]">
              <code className="shrink-0 font-mono text-accent-hi">{t.name}</code>
              <span className="truncate text-ink-dim">{t.purpose}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
