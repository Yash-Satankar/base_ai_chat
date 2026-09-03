// src/components/projects/ProjectsSidebar.jsx
import React, { useState, useEffect, useCallback } from 'react'
import { projectsApi } from '../../api/client'
import { useAuth } from '../../context/AuthContext'
import { domainIcon, scoreHex } from '../../utils/formatters'
import Icon from '../ui/Icon'
import Spinner from '../ui/Spinner'

export default function ProjectsSidebar({ currentSessionId, onSelectProject, onNewChat }) {
  const { isAuthenticated } = useAuth()
  const [projects, setProjects] = useState([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(false)
  const [expanded, setExpanded] = useState({})
  const [error, setError] = useState(null)

  const fetchProjects = useCallback(async () => {
    if (!isAuthenticated) return
    setLoading(true); setError(null)
    try {
      setProjects(await projectsApi.list())
    } catch {
      setError('Couldn\'t load projects')
    } finally {
      setLoading(false)
    }
  }, [isAuthenticated])

  useEffect(() => { fetchProjects() }, [fetchProjects])

  const filtered = projects.filter(
    p =>
      p.name?.toLowerCase().includes(search.toLowerCase()) ||
      p.domain?.toLowerCase().includes(search.toLowerCase())
  )

  if (!isAuthenticated) {
    return (
      <aside className="hidden w-60 shrink-0 flex-col border-r border-line bg-bg-raised p-5 md:flex">
        <div className="mt-4 flex flex-col items-center rounded-xl border border-line bg-bg-elevated p-5 text-center shadow-inset-hl">
          <div className="mb-3 grid size-9 place-items-center rounded-lg border border-line bg-white/[0.03] text-ink-faint">
            <Icon name="lock" className="size-[18px]" />
          </div>
          <p className="text-[13px] font-medium text-ink">Save your designs</p>
          <p className="mt-1 text-[11.5px] leading-relaxed text-ink-dim">
            Sign in to keep project history, versions and quality scores.
          </p>
        </div>
      </aside>
    )
  }

  return (
    <aside className="hidden w-60 shrink-0 flex-col border-r border-line bg-bg-raised md:flex">
      <div className="flex items-center justify-between px-3.5 pb-2 pt-3.5">
        <div className="flex items-center gap-1.5">
          <span className="label">Projects</span>
          {projects.length > 0 && (
            <span className="rounded-md bg-white/[0.05] px-1.5 text-[11px] font-medium text-ink-dim">
              {projects.length}
            </span>
          )}
        </div>
        <button
          onClick={onNewChat}
          title="New design"
          className="grid size-6 place-items-center rounded-md text-ink-dim transition-colors hover:bg-white/[0.06] hover:text-ink"
        >
          <Icon name="plus" className="size-3.5" strokeWidth={2} />
        </button>
      </div>

      {projects.length > 4 && (
        <div className="relative px-3 pb-2">
          <Icon name="search" className="pointer-events-none absolute left-5 top-1/2 size-3.5 -translate-y-1/2 text-ink-faint" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Filter…"
            className="w-full rounded-lg border border-line bg-bg-input py-1.5 pl-7 pr-2.5 text-[12.5px] text-ink placeholder:text-ink-faint focus:border-accent-line focus:outline-none"
          />
        </div>
      )}

      <div className="scroll-thin flex-1 overflow-y-auto px-2 pb-3">
        {loading && (
          <div className="flex items-center gap-2 px-2 py-4 text-[12px] text-ink-dim">
            <Spinner size="xs" /> Loading…
          </div>
        )}

        {error && (
          <div className="px-2 py-4 text-[12px] text-ink-dim">
            {error}{' '}
            <button onClick={fetchProjects} className="text-accent-hi underline">retry</button>
          </div>
        )}

        {!loading && !error && projects.length === 0 && (
          <div className="px-2 py-8 text-center">
            <p className="text-[12.5px] font-medium text-ink-muted">No projects yet</p>
            <p className="mt-1 text-[11px] text-ink-faint">Start a design to see it here.</p>
          </div>
        )}

        <ul className="space-y-0.5">
          {filtered.map(p => {
            const isOpen = !!expanded[p.id]
            return (
              <li key={p.id}>
                <button
                  onClick={() => setExpanded(s => ({ ...s, [p.id]: !s[p.id] }))}
                  className="group flex w-full items-center gap-2 rounded-lg px-2 py-2 text-left transition-colors hover:bg-white/[0.04]"
                >
                  <span className="text-[13px] leading-none">{domainIcon(p.domain)}</span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate text-[13px] text-ink">{p.name}</span>
                    <span className="mt-0.5 flex items-center gap-1.5 text-[11px] text-ink-faint">
                      {p.version_count} version{p.version_count !== 1 ? 's' : ''}
                      {p.latest_score != null && (
                        <>
                          <span className="text-ink-faint">·</span>
                          <span style={{ color: scoreHex(p.latest_score) }}>{p.latest_score}</span>
                        </>
                      )}
                    </span>
                  </span>
                  <Icon
                    name="chevron-right"
                    className={`size-3.5 shrink-0 text-ink-faint transition-transform ${isOpen ? 'rotate-90' : ''}`}
                  />
                </button>

                {isOpen && p.versions?.length > 0 && (
                  <ul className="mb-1 ml-4 border-l border-line pl-2">
                    {p.versions.map(v => (
                      <li key={v.id}>
                        <button
                          onClick={() => onSelectProject(p.id, v.version_number)}
                          className="flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left text-[11.5px] text-ink-dim transition-colors hover:bg-white/[0.04] hover:text-ink"
                        >
                          <span className="rounded bg-white/[0.05] px-1.5 py-px font-mono text-[10px] text-ink-muted">
                            v{v.version_number}
                          </span>
                          <span className="truncate">
                            {v.tables_count ? `${v.tables_count} tables` : v.status}
                          </span>
                          {v.validation_score != null && (
                            <span className="ml-auto" style={{ color: scoreHex(v.validation_score) }}>
                              {v.validation_score}
                            </span>
                          )}
                        </button>
                      </li>
                    ))}
                  </ul>
                )}
              </li>
            )
          })}
        </ul>
      </div>
    </aside>
  )
}
