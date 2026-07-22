// src/components/ui/GenerationProgress.jsx

import React, { useState, useEffect, useRef } from 'react'

export default function GenerationProgress({ jobStatus, progress, jobId }) {
  const [elapsed, setElapsed] = useState(0)
  const [moduleLog, setModuleLog] = useState([])
  const prevModuleDone = useRef(0)
  const startRef = useRef(Date.now())
  const logEndRef = useRef(null)

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
          id: Date.now(),
          name: progress.current_module,
          done: progress.modules_done,
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

  const isQueued = jobStatus === 'queued'
  const isGenerating = jobStatus === 'generating'
  const isDone = jobStatus === 'done'
  const isFailed = jobStatus === 'failed'

  return (
    <div className="space-y-4">
      {/* Phase status header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <PhaseDot status={jobStatus} />
          <span className="text-xs font-bold text-white">
            {isQueued && 'Initializing Engine...'}
            {isGenerating && 'Synthesizing Architecture...'}
            {isDone && '✅ Schema Complete'}
            {isFailed && '❌ Generation Interrupted'}
          </span>
        </div>
        {(isQueued || isGenerating) && (
          <span className="text-xs text-indigo-300 font-mono font-medium tabular-nums bg-indigo-500/10 border border-indigo-500/20 px-2 py-0.5 rounded-md">
            {formatTime(elapsed)}
          </span>
        )}
      </div>

      {/* Module progress bar */}
      <div className="space-y-1.5">
        <div className="flex justify-between text-[11px] font-semibold text-slate-400">
          <span>Target Modules</span>
          <span className="font-mono tabular-nums text-slate-300">
            {progress?.modules_done ?? 0} / {progress?.modules_total ?? '…'}
          </span>
        </div>
        <ProgressBar pct={modulePct} color="bg-indigo-500" animated={isGenerating || isQueued} />
      </div>

      {/* Table counter */}
      <div className="space-y-1.5">
        <div className="flex justify-between text-[11px] font-semibold text-slate-400">
          <span>Planned Tables</span>
          <span className="font-mono tabular-nums text-slate-300">
            {progress?.tables_done ?? 0} / {progress?.tables_planned ?? '…'}
          </span>
        </div>
        <ProgressBar pct={tablePct} color="bg-purple-500" animated={isGenerating || isQueued} />
      </div>

      {/* Current active module */}
      {isGenerating && progress?.current_module && (
        <div className="flex items-center gap-2 px-3 py-2 rounded-xl bg-slate-900/80 border border-indigo-500/30">
          <span className="w-2 h-2 rounded-full bg-indigo-400 animate-pulse shrink-0" />
          <span className="text-xs font-semibold text-indigo-200 truncate">
            Active: {progress.current_module}
          </span>
        </div>
      )}

      {/* Module execution log */}
      {moduleLog.length > 0 && (
        <div className="space-y-1 pt-1">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Completed Modules</p>
          <div className="max-h-32 overflow-y-auto space-y-1 scrollbar-thin">
            {moduleLog.map(entry => (
              <div
                key={entry.id}
                className="flex items-center gap-2 text-xs text-slate-300 py-1 px-2 rounded-lg bg-slate-900/40 border border-slate-800"
              >
                <span className="text-emerald-400 font-bold">✓</span>
                <span className="truncate font-medium">{entry.name}</span>
                <span className="ml-auto text-slate-500 font-mono text-[11px]">
                  {entry.done}/{entry.total}
                </span>
              </div>
            ))}
            <div ref={logEndRef} />
          </div>
        </div>
      )}
    </div>
  )
}

function PhaseDot({ status }) {
  const colors = {
    queued:     'bg-amber-400 animate-pulse',
    generating: 'bg-indigo-400 animate-pulse',
    done:       'bg-emerald-400',
    failed:     'bg-rose-400',
  }
  return (
    <span
      className={`w-2.5 h-2.5 rounded-full shrink-0 ${colors[status] ?? 'bg-slate-500'}`}
    />
  )
}

function ProgressBar({ pct, color, animated }) {
  return (
    <div className="h-2 bg-slate-900 rounded-full overflow-hidden border border-slate-800">
      <div
        className={`h-full rounded-full transition-all duration-700 ease-out ${color} ${
          animated && pct < 100 ? 'relative overflow-hidden animate-shimmer' : ''
        }`}
        style={{ width: `${Math.max(pct, pct > 0 ? 4 : 0)}%` }}
      />
    </div>
  )
}

function formatTime(seconds) {
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return m > 0 ? `${m}m ${String(s).padStart(2, '0')}s` : `${s}s`
}
