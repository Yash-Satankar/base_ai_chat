// src/components/ui/GenerationProgress.jsx
import React, { useState, useEffect, useRef } from 'react'
import Icon from './Icon'
import Spinner from './Spinner'

export default function GenerationProgress({ jobStatus, progress }) {
  const [elapsed, setElapsed] = useState(0)
  const [log, setLog] = useState([])
  const prevDone = useRef(0)
  const startRef = useRef(Date.now())
  const logEnd = useRef(null)

  useEffect(() => {
    if (jobStatus !== 'generating' && jobStatus !== 'queued') return
    startRef.current = Date.now()
    const t = setInterval(() => setElapsed(Math.floor((Date.now() - startRef.current) / 1000)), 1000)
    return () => clearInterval(t)
  }, [jobStatus])

  useEffect(() => {
    if (!progress?.current_module) return
    if (progress.modules_done > prevDone.current) {
      prevDone.current = progress.modules_done
      setLog(l => [...l, { id: Date.now(), name: progress.current_module, done: progress.modules_done, total: progress.modules_total }])
      setTimeout(() => logEnd.current?.scrollIntoView({ behavior: 'smooth' }), 60)
    }
  }, [progress?.modules_done, progress?.current_module])

  const mPct = progress ? pct(progress.modules_done, progress.modules_total) : 0
  const tPct = progress ? pct(progress.tables_done, progress.tables_planned) : 0

  const isQueued = jobStatus === 'queued'
  const isGen = jobStatus === 'generating'
  const isDone = jobStatus === 'done'
  const isFail = jobStatus === 'failed'

  return (
    <div className="space-y-3.5">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2 text-[13px] font-medium text-ink">
          {(isQueued || isGen) && <Spinner size="xs" />}
          {isDone && <Icon name="circle-check" className="size-4 text-ok" />}
          {isFail && <Icon name="x" className="size-4 text-danger" strokeWidth={2} />}
          {isQueued && 'Starting up…'}
          {isGen && 'Generating schema'}
          {isDone && 'Schema complete'}
          {isFail && 'Generation stopped'}
        </div>
        {(isQueued || isGen) && (
          <span className="rounded-md border border-line bg-white/[0.03] px-1.5 py-0.5 font-mono text-[11px] tabular-nums text-ink-muted">
            {fmt(elapsed)}
          </span>
        )}
      </div>

      <Meter label="Modules" done={progress?.modules_done ?? 0} total={progress?.modules_total} pct={mPct} live={isGen || isQueued} />
      <Meter label="Tables" done={progress?.tables_done ?? 0} total={progress?.tables_planned} pct={tPct} live={isGen || isQueued} />

      {isGen && progress?.current_module && (
        <div className="flex items-center gap-2 rounded-lg border border-accent-line bg-accent-bg px-2.5 py-1.5">
          <span className="size-1.5 shrink-0 animate-pulse rounded-full bg-accent-hi" />
          <span className="truncate text-[12px] text-accent-hi">{progress.current_module}</span>
        </div>
      )}

      {log.length > 0 && (
        <div>
          <p className="label mb-1.5">Completed</p>
          <div className="scroll-thin max-h-32 space-y-1 overflow-y-auto">
            {log.map(e => (
              <div key={e.id} className="flex items-center gap-2 rounded-md bg-white/[0.02] px-2 py-1 text-[12px] text-ink-muted">
                <Icon name="check" className="size-3 shrink-0 text-ok" strokeWidth={2.4} />
                <span className="truncate">{e.name}</span>
                <span className="ml-auto font-mono text-[10.5px] text-ink-faint">{e.done}/{e.total}</span>
              </div>
            ))}
            <div ref={logEnd} />
          </div>
        </div>
      )}
    </div>
  )
}

function Meter({ label, done, total, pct, live }) {
  return (
    <div className="space-y-1">
      <div className="flex justify-between text-[11.5px] text-ink-dim">
        <span>{label}</span>
        <span className="font-mono tabular-nums text-ink-muted">{done} / {total ?? '—'}</span>
      </div>
      <div className="relative h-1.5 overflow-hidden rounded-full bg-white/[0.06]">
        <div
          className="h-full rounded-full bg-accent transition-[width] duration-700 ease-out"
          style={{ width: `${Math.max(pct, pct > 0 ? 4 : 0)}%` }}
        />
        {live && pct < 100 && (
          <div className="absolute inset-y-0 w-1/3 animate-marquee bg-gradient-to-r from-transparent via-white/15 to-transparent" />
        )}
      </div>
    </div>
  )
}

const pct = (a, b) => Math.round((Number(a || 0) / Math.max(Number(b || 0), 1)) * 100)
const fmt = s => (s >= 60 ? `${Math.floor(s / 60)}m ${String(s % 60).padStart(2, '0')}s` : `${s}s`)
