// src/pages/Chat.jsx
import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import ChatWindow from '../components/chat/ChatWindow'
import InputBar from '../components/chat/InputBar'
import useConversation from '../hooks/useConversation'
import { STAGE_STEPS, stageStepIndex } from '../utils/formatters'
import Spinner from '../components/ui/Spinner'
import Button from '../components/ui/Button'
import Icon from '../components/ui/Icon'
import GenerationProgress from '../components/ui/GenerationProgress'
import { useAuth } from '../context/AuthContext'
import AuthModal from '../components/auth/AuthModal'
import ProjectsSidebar from '../components/projects/ProjectsSidebar'
import Logo from '../components/ui/Logo'
import { projectsApi } from '../api/client'

export default function Chat() {
  const navigate = useNavigate()
  const { user, logout, isAuthenticated } = useAuth()
  const [starting, setStarting] = useState(true)
  const [showAuthModal, setShowAuthModal] = useState(false)
  const [sidebarKey, setSidebarKey] = useState(0)

  const {
    sessionId, messages, stage, blueprint, validation, metadata, genSummary,
    isLoading, messagesEndRef, startSession, loadExistingVersion, sendMessage,
    reset, jobId, jobStatus, progress, isPolling,
  } = useConversation()

  useEffect(() => {
    const init = async () => { await startSession(); setStarting(false) }
    init()
  }, [])

  useEffect(() => {
    if (stage === 'complete') setSidebarKey(p => p + 1)
  }, [stage])

  const handleNewSession = async () => {
    reset(); setStarting(true)
    await startSession()
    setStarting(false); setSidebarKey(p => p + 1)
  }

  const handleSelectProjectVersion = async (projectId, versionNumber) => {
    setStarting(true)
    try {
      const version = await projectsApi.getVersion(projectId, versionNumber)
      loadExistingVersion(version)
    } catch (err) {
      console.error('Failed to load version:', err)
    } finally {
      setStarting(false)
    }
  }

  const isGenerating = stage === 'generating' || isPolling
  const busy = isLoading || isPolling

  return (
    <div className="flex h-screen flex-col bg-bg text-ink">
      {/* ── Header ── */}
      <header className="z-30 flex shrink-0 items-center justify-between gap-4 border-b border-line bg-bg/80 px-4 py-2.5 backdrop-blur-xl sm:px-5">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/')}
            className="grid size-7 place-items-center rounded-lg text-ink-dim transition-colors hover:bg-white/[0.05] hover:text-ink"
            title="Home"
          >
            <Icon name="arrow-right" className="size-4 rotate-180" />
          </button>
          <span className="h-4 w-px bg-line" />
          <div className="flex items-center gap-2">
            <Logo className="size-6" />
            <span className="hidden text-[13.5px] font-semibold tracking-tight sm:inline">Workbench</span>
          </div>
        </div>

        <Stepper stage={stage} busy={busy} />

        <div className="flex items-center gap-2">
          <Button
            size="sm" variant="secondary" onClick={handleNewSession} disabled={busy}
            iconLeft={<Icon name="plus" className="size-3.5" />}
          >
            <span className="hidden sm:inline">New design</span>
          </Button>
          {isAuthenticated ? (
            <>
              <span className="hidden items-center gap-2 rounded-lg border border-line bg-white/[0.03] py-1 pl-1 pr-2.5 sm:flex">
                <span className="grid size-6 place-items-center rounded-md bg-accent-bg text-[11px] font-semibold text-accent-hi">
                  {(user?.displayName || '?').slice(0, 1).toUpperCase()}
                </span>
                <span className="max-w-[110px] truncate text-[12.5px] text-ink-muted">{user?.displayName}</span>
              </span>
              <Button size="sm" variant="ghost" onClick={logout} title="Sign out">
                <Icon name="log-out" className="size-4" />
              </Button>
            </>
          ) : (
            <Button size="sm" variant="primary" onClick={() => setShowAuthModal(true)}>Sign in</Button>
          )}
        </div>
      </header>

      {/* ── Workspace ── */}
      <div className="flex flex-1 overflow-hidden">
        <ProjectsSidebar
          key={sidebarKey}
          currentSessionId={sessionId}
          onSelectProject={handleSelectProjectVersion}
          onNewChat={handleNewSession}
        />

        <div className="flex flex-1 flex-col overflow-hidden">
          {starting ? (
            <div className="flex flex-1 flex-col items-center justify-center gap-3">
              <Spinner size="lg" />
              <p className="text-[13px] text-ink-dim">Opening your workbench…</p>
            </div>
          ) : (
            <ChatWindow
              messages={messages}
              messagesEndRef={messagesEndRef}
              sessionId={sessionId}
              onQuickStart={sendMessage}
            />
          )}
          <InputBar onSend={sendMessage} disabled={busy || starting} stage={stage} />
        </div>

        <aside className="hidden w-[320px] shrink-0 flex-col overflow-hidden border-l border-line bg-bg-raised lg:flex">
          <ContextPanel
            stage={stage} blueprint={blueprint} validation={validation}
            genSummary={genSummary} metadata={metadata}
            jobId={jobId} jobStatus={jobStatus} progress={progress} isGenerating={isGenerating}
          />
        </aside>
      </div>

      {showAuthModal && <AuthModal onClose={() => setShowAuthModal(false)} />}
    </div>
  )
}

/* ── Stepper ─────────────────────────────────────────────── */

function Stepper({ stage, busy }) {
  const current = stageStepIndex(stage)
  return (
    <div className="hidden items-center md:flex">
      {STAGE_STEPS.map((s, i) => {
        const done = i < current
        const active = i === current
        return (
          <React.Fragment key={s.key}>
            <div className="flex items-center gap-1.5">
              <span
                className={`grid size-[18px] place-items-center rounded-full border text-[10px] font-semibold transition-colors ${
                  done
                    ? 'border-accent-line bg-accent-bg text-accent-hi'
                    : active
                    ? 'border-accent bg-accent text-white'
                    : 'border-line bg-white/[0.02] text-ink-faint'
                }`}
              >
                {done ? <Icon name="check" className="size-2.5" strokeWidth={2.4} /> : i + 1}
              </span>
              <span
                className={`text-[12px] transition-colors ${
                  active ? 'font-medium text-ink' : done ? 'text-ink-muted' : 'text-ink-faint'
                }`}
              >
                {s.label}
              </span>
              {active && busy && <Spinner size="xs" className="ml-0.5" />}
            </div>
            {i < STAGE_STEPS.length - 1 && (
              <span className={`mx-2 h-px w-5 ${i < current ? 'bg-accent-line' : 'bg-line'}`} />
            )}
          </React.Fragment>
        )
      })}
    </div>
  )
}

/* ── Context panel ───────────────────────────────────────── */

function ContextPanel({ stage, blueprint, validation, genSummary, metadata, jobId, jobStatus, progress, isGenerating }) {
  const [tab, setTab] = useState('blueprint')

  const sim = metadata?.simulation_report
  const genome = metadata?.genome
  const recs = metadata?.proactive_recommendations
  const tabs = [
    { key: 'blueprint', label: 'Blueprint' },
    sim && { key: 'simulation', label: 'Simulation' },
    genome && { key: 'genome', label: 'DNA' },
    recs?.length && { key: 'recs', label: 'Recs' },
  ].filter(Boolean)

  const hasAnything = blueprint || validation || genSummary || isGenerating

  return (
    <div className="flex h-full flex-col">
      <div className="flex shrink-0 gap-1 border-b border-line p-1.5">
        {tabs.map(t => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={`rounded-md px-2.5 py-1.5 text-[12px] font-medium transition-colors ${
              tab === t.key ? 'bg-white/[0.06] text-ink' : 'text-ink-dim hover:text-ink-muted'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      <div className="scroll-thin flex-1 space-y-3 overflow-y-auto p-3.5">
        {isGenerating && (
          <SectionCard title="Generation" accent>
            <GenerationProgress jobStatus={jobStatus} progress={progress} jobId={jobId} />
          </SectionCard>
        )}

        {tab === 'blueprint' && (
          <>
            {blueprint && (
              <SectionCard title="Blueprint">
                <p className="text-[13.5px] font-medium text-ink">{blueprint.project_name}</p>
                {blueprint.description && (
                  <p className="mt-0.5 text-[12px] leading-relaxed text-ink-dim">{blueprint.description}</p>
                )}
                <div className="mt-2.5 flex gap-4 text-[12px] text-ink-muted">
                  <span><b className="font-semibold text-ink">{blueprint.modules?.length || 0}</b> modules</span>
                  <span>
                    <b className="font-semibold text-ink">
                      {blueprint.modules?.reduce((s, m) => s + (m.tables?.length || 0), 0) || 0}
                    </b> tables
                  </span>
                </div>
              </SectionCard>
            )}

            {validation && (
              <SectionCard title="Rules compliance">
                <div className="flex items-center gap-3">
                  <ScoreRing score={validation.score} />
                  <div className="min-w-0">
                    <p className="text-[13px] font-medium text-ink">
                      {validation.passed ? 'Passed' : 'Action required'}
                      {validation.grade ? ` · Grade ${validation.grade}` : ''}
                    </p>
                    <p className="mt-0.5 truncate text-[11.5px] text-ink-dim">
                      {validation.summary || 'Headline quality score'}
                    </p>
                  </div>
                </div>
              </SectionCard>
            )}

            {genSummary && (
              <SectionCard title="Generation summary">
                <Row label="Tables generated" value={genSummary.tables_generated ?? '—'} />
                <Row label="Modules" value={genSummary.modules_generated ?? genSummary.modules_planned ?? '—'} />
                <Row
                  label="Completeness"
                  value={genSummary.completeness_pct != null ? `${genSummary.completeness_pct}%` : '—'}
                />
              </SectionCard>
            )}

            {!hasAnything && (
              <EmptyPanel
                icon="panel-right"
                title="Nothing here yet"
                body="Your blueprint, validation score, and generation summary will show up here as you go."
              />
            )}
          </>
        )}
      </div>

      <div className="hairline-t bg-bg p-3.5">
        <p className="label mb-2">{isGenerating ? 'While you wait' : 'Tips'}</p>
        <TipsByStage stage={isGenerating ? 'generating' : stage} />
      </div>
    </div>
  )
}

function SectionCard({ title, accent, children }) {
  return (
    <div className={`rounded-xl border p-3.5 ${accent ? 'border-accent-line bg-accent-bg' : 'border-line bg-bg-elevated'} shadow-inset-hl`}>
      <p className="label mb-2.5">{title}</p>
      {children}
    </div>
  )
}

function Row({ label, value }) {
  return (
    <div className="flex items-center justify-between py-0.5 text-[12.5px]">
      <span className="text-ink-dim">{label}</span>
      <span className="font-medium text-ink">{value}</span>
    </div>
  )
}

function ScoreRing({ score = 0 }) {
  const r = 16
  const c = 2 * Math.PI * r
  const pct = Math.max(0, Math.min(100, score))
  const col = pct >= 85 ? '#3ecf8e' : pct >= 70 ? '#a89bff' : pct >= 55 ? '#f5a623' : '#f56565'
  return (
    <div className="relative size-11 shrink-0">
      <svg viewBox="0 0 40 40" className="size-full -rotate-90">
        <circle cx="20" cy="20" r={r} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="3" />
        <circle
          cx="20" cy="20" r={r} fill="none" stroke={col} strokeWidth="3" strokeLinecap="round"
          strokeDasharray={c} strokeDashoffset={c - (c * pct) / 100}
          style={{ transition: 'stroke-dashoffset .7s cubic-bezier(0.16,1,0.3,1)' }}
        />
      </svg>
      <span className="absolute inset-0 grid place-items-center text-[12px] font-semibold tabular-nums text-ink">
        {score}
      </span>
    </div>
  )
}

function EmptyPanel({ icon, title, body }) {
  return (
    <div className="flex flex-col items-center px-4 py-10 text-center">
      <div className="mb-3 grid size-9 place-items-center rounded-lg border border-line bg-white/[0.03] text-ink-faint">
        <Icon name={icon} className="size-[18px]" />
      </div>
      <p className="text-[13px] font-medium text-ink-muted">{title}</p>
      <p className="mt-1 text-[11.5px] leading-relaxed text-ink-faint">{body}</p>
    </div>
  )
}

function TipsByStage({ stage }) {
  const tips = {
    idle:       ['Pick or start a design to begin.'],
    initial:    ['Name the core things it tracks.', 'Mention scale and any tax/GST needs.', 'Say who the users are.'],
    clarifying: ['Answer what\'s relevant — skip the rest.', 'Say "Generate Blueprint" when ready.'],
    compiling:  ['Mapping entities, relationships and lifecycles.', 'This usually takes ~20 seconds.'],
    blueprint:  ['Scan the modules and tables.', 'Type YES to build the SQL, or say what to change.'],
    generating: ['Tables are generated in small batches.', 'Every table is validated as it lands.'],
    complete:   ['Download the SQL and the PDF.', 'Ask "explain <table>" to walk through one.'],
  }
  const list = tips[stage] || tips.initial
  return (
    <ul className="space-y-1.5">
      {list.map((t, i) => (
        <li key={i} className="flex gap-2 text-[12px] leading-relaxed text-ink-muted">
          <Icon name="check" className="mt-0.5 size-3 shrink-0 text-accent-hi" strokeWidth={2.2} />
          {t}
        </li>
      ))}
    </ul>
  )
}
