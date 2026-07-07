// src/components/blueprint/ModuleTable.jsx

export default function ModuleTable({ module, index }) {
  return (
    <div className="px-4 py-3">
      {/* Module header */}
      <div className="flex items-center gap-2 mb-2">
        <span className="w-5 h-5 rounded bg-blue-600/30 text-blue-400
                         text-xs flex items-center justify-center font-bold">
          {index}
        </span>
        <span className="text-sm font-medium text-slate-200">
          {module.name}
        </span>
        <span className="text-xs text-slate-500">
          — {module.description}
        </span>
      </div>

      {/* Tables list */}
      <div className="ml-7 space-y-1">
        {module.tables?.map((table, i) => (
          <div key={i} className="flex items-start gap-2">
            <span className="text-slate-600 text-xs mt-0.5">•</span>
            <div>
              <code className="text-xs text-blue-300 font-mono">
                {table.name}
              </code>
              <span className="text-xs text-slate-500 ml-2">
                {table.purpose}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}