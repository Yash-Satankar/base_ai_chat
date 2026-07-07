// src/components/blueprint/BlueprintCard.jsx

import { formatDomain } from '../../utils/formatters'
import ModuleTable from './ModuleTable'

export default function BlueprintCard({ blueprint }) {
  if (!blueprint) return null

  const totalTables = blueprint.modules?.reduce(
    (sum, m) => sum + (m.tables?.length || 0), 0
  ) || 0

  return (
    <div className="w-full rounded-xl border border-blue-500/30
                    bg-slate-900/80 overflow-hidden">

      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600/20 to-purple-600/20
                      border-b border-slate-700 px-4 py-3">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-white text-sm">
              📦 {blueprint.project_name}
            </h3>
            <p className="text-xs text-slate-400 mt-0.5">
              {blueprint.description}
            </p>
          </div>
          <div className="text-right shrink-0 ml-4">
            <p className="text-xs text-slate-400">
              {totalTables} tables
            </p>
            <p className="text-xs text-slate-400">
              {blueprint.modules?.length || 0} modules
            </p>
          </div>
        </div>

        {/* Meta badges */}
        <div className="flex flex-wrap gap-2 mt-3">
          <MetaBadge label="Domain" value={formatDomain(blueprint.domain)} />
          <MetaBadge label="Scale" value={blueprint.scale?.toUpperCase()} />
          <MetaBadge
            label="GST"
            value={blueprint.gst_required ? '✓ Required' : '✗ Not required'}
            color={blueprint.gst_required ? 'green' : 'slate'}
          />
        </div>
      </div>

      {/* Modules */}
      <div className="divide-y divide-slate-800">
        {blueprint.modules?.map((module, i) => (
          <ModuleTable key={i} module={module} index={i + 1} />
        ))}
      </div>
    </div>
  )
}


function MetaBadge({ label, value, color = 'blue' }) {
  const colors = {
    blue:  'bg-blue-500/10 text-blue-300 border-blue-500/20',
    green: 'bg-green-500/10 text-green-300 border-green-500/20',
    slate: 'bg-slate-500/10 text-slate-400 border-slate-500/20',
  }
  return (
    <span className={`inline-flex items-center gap-1 px-2 py-0.5
                      rounded text-xs border ${colors[color]}`}>
      <span className="text-slate-500">{label}:</span>
      <span className="font-medium">{value}</span>
    </span>
  )
}