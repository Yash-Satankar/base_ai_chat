// src/components/ui/GenerationProgress.jsx
//
// Shows a live animated progress panel during async schema generation.
// Receives `progress` from useJobPoller and renders:
//   - Animated phase heading
//   - Module progress bar (modules_done / modules_total)
//   - Table counter (tables_done / tables_planned)
//   - Scrolling log of completed modules
//   - Elapsed timer

import { useState, useEffect, useRef } from 'react'

// ── Main component ───────────────────────────────────────────────

export default function GenerationProgress({ jobStatus, progress, jobId }) {
  const [elapsed,      setElapsed]      = useState(0)
  const [moduleLog,    setModuleLog]    = useState([])
  const prevModuleDone = useRef(0)
  const startRef       = useRef(Date.now())
  const logEndRef      = useRef(null)

  // Elapsed timer — ticks every second while generating
  useEffect(() => {
    if (jobStatus !== 'generating' && jobStatus !== 'queued') return
    startRef.current = Date.now()
    const interval = setInterval(() => {
      setElapsed(Math.floor((Date.now() - startRef.current) / 1000))
    }, 1000)
    return () => clearInterval(interval)
  }, [jobStatus])

  // Append to module log when modules_done increases
  useEffect(() => {
    if (!progress?.current_module) return
    if (progress.modules_done > prevModuleDone.current) {
      prevModuleDone.current = progress.modules_done
      setModuleLog(prev => [
        ...prev,
        {
          id:    Date.now(),
          name:  progress.current_module,
          done:  progress.modules_done,
          total: progress.modules_total,
        }
      ])
      setTimeout(() => logEndRef.current?.scrollIntoView({ behavior: 'smooth' }), 80)
    }
  }, [progress?.modules_done, progress?.current_module])

  const modulePct = progress
    ? Math.round((progress.modules_done / Math.max(progress.modules_total, 1)) * 100)
    : 0

  const tablePct = progress
    ? Math.round((progress.tables_done / Math.max(progress.tables_planned, 1)) * 100)
    : 0

  const isQueued     = jobStatus === 'queued'
  const isGenerating = jobStatus === 'generating'
  const isDone       = jobStatus === 'done'
  const isFailed     = jobStatus === 'failed'

  return (
    <div className="space-y-4">

      {/* Phase badge */}
      <div className="flex items-center gap-2">
        <PhaseDot status={jobStatus} />
        <span className="text-xs font-semibold text-slate-300">
          {isQueued     && 'Queued — starting…'}
          {isGenerating && 'Generating schema'}
          {isDone       && '✅ Schema complete'}
          {isFailed     && '❌ Generation failed'}
        </span>
        {(isQueued || isGenerating) && (
          <span className="ml-auto text-xs text-slate-600 font-mono tabular-nums">
            {formatTime(elapsed)}
          </span>
        )}
      </div>

      {/* Module progress bar */}
      <div className="space-y-1.5">
        <div className="flex justify-between text-[11px] text-slate-500">
          <span>Modules</span>
          <span className="font-mono tabular-nums">
            {progress?.modules_done ?? 0} / {progress?.modules_total ?? '…'}
          </span>
        </div>
        <ProgressBar
          pct={modulePct}
          color="bg-violet-500"
          animated={isGenerating || isQueued}
        />
      </div>

      {/* Table counter */}
      <div className="space-y-1.5">
        <div className="flex justify-between text-[11px] text-slate-500">
          <span>Tables</span>
          <span className="font-mono tabular-nums">
            {progress?.tables_done ?? 0} / {progress?.tables_planned ?? '…'}
          </span>
        </div>
        <ProgressBar
          pct={tablePct}
          color="bg-blue-500"
          animated={isGenerating || isQueued}
        />
      </div>

      {/* Current module label */}
      {isGenerating && progress?.current_module && (
        <div className="flex items-center gap-2 px-2 py-1.5 rounded-md bg-slate-800/70 border border-slate-700/60">
          <span className="w-1.5 h-1.5 rounded-full bg-violet-400 animate-pulse flex-shrink-0" />
          <span className="text-[11px] text-slate-300 truncate">
            {progress.current_module}
          </span>
        </div>
      )}

      {/* Module log */}
      {moduleLog.length > 0 && (
        <div className="space-y-1">
          <p className="text-[10px] text-slate-600 uppercase tracking-wider">Completed</p>
          <div className="max-h-28 overflow-y-auto space-y-0.5 scrollbar-thin">
            {moduleLog.map(entry => (
              <div
                key={entry.id}
                className="flex items-center gap-1.5 text-[11px] text-slate-400 py-0.5"
              >
                <span className="text-green-500 flex-shrink-0">✓</span>
                <span className="truncate">{entry.name}</span>
                <span className="ml-auto text-slate-600 tabular-nums flex-shrink-0">
                  {entry.done}/{entry.total}
                </span>
              </div>
            ))}
            <div ref={logEndRef} />
          </div>
        </div>
      )}

      {/* Job ID hint */}
      {jobId && (
        <p className="text-[10px] text-slate-700 font-mono">
          Job {jobId.slice(0, 8)}…
        </p>
      )}
    </div>
  )
}


// ── Sub-components ───────────────────────────────────────────────

function PhaseDot({ status }) {
  const colors = {
    queued:     'bg-yellow-400 animate-pulse',
    generating: 'bg-violet-400 animate-pulse',
    done:       'bg-green-400',
    failed:     'bg-red-400',
  }
  return (
    <span
      className={`w-2 h-2 rounded-full flex-shrink-0 ${colors[status] ?? 'bg-slate-500'}`}
    />
  )
}

function ProgressBar({ pct, color, animated }) {
  return (
    <div className="h-1.5 bg-slate-800 rounded-full overflow-hidden">
      <div
        className={`h-full rounded-full transition-all duration-700 ease-out ${color}
          ${animated && pct < 100 ? 'relative after:absolute after:inset-0 after:bg-white/20 after:animate-shimmer' : ''}
        `}
        style={{ width: `${Math.max(pct, pct > 0 ? 4 : 0)}%` }}
      />
    </div>
  )
}

function formatTime(seconds) {
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return m > 0
    ? `${m}m ${String(s).padStart(2, '0')}s`
    : `${s}s`
}
