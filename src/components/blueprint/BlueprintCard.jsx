// src/components/blueprint/BlueprintCard.jsx
import React from 'react'
import { formatDomain } from '../../utils/formatters'
import ModuleTable from './ModuleTable'
import Badge from '../ui/Badge'

export default function BlueprintCard({ blueprint }) {
  if (!blueprint) return null

  const tables = blueprint.modules?.reduce((s, m) => s + (m.tables?.length || 0), 0) || 0
  const modules = blueprint.modules?.length || 0

  return (
    <div className="w-full overflow-hidden rounded-xl border border-line bg-bg-raised shadow-inset-hl">
      <div className="border-b border-line px-4 py-3.5">
        <div className="flex items-start justify-between gap-4">
          <div className="min-w-0">
            <h3 className="text-[14px] font-semibold text-ink">{blueprint.project_name}</h3>
            {blueprint.description && (
              <p className="mt-0.5 text-[12.5px] leading-relaxed text-ink-dim">{blueprint.description}</p>
            )}
          </div>
          <div className="shrink-0 text-right text-[11.5px] text-ink-muted">
            <div><b className="font-semibold text-ink">{tables}</b> tables</div>
            <div><b className="font-semibold text-ink">{modules}</b> modules</div>
          </div>
        </div>

        <div className="mt-3 flex flex-wrap gap-1.5">
          <Badge variant="neutral">{formatDomain(blueprint.domain)}</Badge>
          {blueprint.scale && <Badge variant="neutral">{String(blueprint.scale).toUpperCase()}</Badge>}
          <Badge variant={blueprint.gst_required ? 'success' : 'neutral'}>
            {blueprint.gst_required ? 'GST required' : 'No GST'}
          </Badge>
        </div>
      </div>

      <div className="divide-y divide-line">
        {blueprint.modules?.map((m, i) => (
          <ModuleTable key={i} module={m} index={i + 1} />
        ))}
      </div>
    </div>
  )
}
