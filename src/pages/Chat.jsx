// src/pages/Chat.jsx

import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import ChatWindow from '../components/chat/ChatWindow'
import InputBar from '../components/chat/InputBar'
import useConversation from '../hooks/useConversation'
import { formatStage } from '../utils/formatters'
import Spinner from '../components/ui/Spinner'
import GenerationProgress from '../components/ui/GenerationProgress'
import { useAuth } from '../context/AuthContext'
import AuthModal from '../components/auth/AuthModal'
import ProjectsSidebar from '../components/projects/ProjectsSidebar'
import { projectsApi, conversationApi } from '../api/client'

export default function Chat() {
  const navigate = useNavigate()
  const { user, logout, isAuthenticated } = useAuth()
  const [starting, setStarting] = useState(true)
  const [showAuthModal, setShowAuthModal] = useState(false)
  const [sidebarKey, setSidebarKey] = useState(0)

  const {
    sessionId,
    messages,
    stage,
    blueprint,
    validation,
    metadata,
    genSummary,
    isLoading,
    error,
    messagesEndRef,
    startSession,
    loadExistingVersion,
    sendMessage,
    reset,
    // Job polling
    jobId,
    jobStatus,
    progress,
    isPolling,
  } = useConversation()

  // Auto-start session on mount
  useEffect(() => {
    const init = async () => {
      await startSession()
      setStarting(false)
    }
    init()
  }, [])

  // Auto-refresh sidebar list when status becomes COMPLETE
  useEffect(() => {
    if (stage === 'complete') {
      setSidebarKey(prev => prev + 1)
    }
  }, [stage])

  const handleNewSession = async () => {
    reset()
    setStarting(true)
    await startSession()
    setStarting(false)
    setSidebarKey(prev => prev + 1)
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


  return (
    <div className="h-screen flex flex-col bg-slate-950">

      {/* ── Header ── */}
      <header className="flex items-center justify-between
                         px-4 py-3 border-b border-slate-800
                         bg-slate-900/95 backdrop-blur-sm shrink-0">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/')}
            className="text-slate-400 hover:text-white transition-colors text-sm"
          >
            ← Home
          </button>
          <span className="text-slate-700">|</span>
          <span className="text-white font-semibold text-sm">🗄️ SchemaAI</span>
        </div>

        {/* Stage indicator */}
        <div className="flex items-center gap-2">
          <StageIndicator stage={stage} isLoading={isLoading} isPolling={isPolling} />
        </div>

        {/* Actions */}
        <div className="flex items-center gap-3">
          {sessionId && !sessionId.startsWith('project_ver_') && (
            <span className="text-xs text-slate-600 font-mono hidden sm:block">
              Session: {sessionId.slice(0, 8)}...
            </span>
          )}
          <button
            onClick={handleNewSession}
            disabled={isLoading || isPolling}
            className="text-xs px-3 py-1.5 rounded-lg
                       border border-slate-700 text-slate-400
                       hover:border-slate-500 hover:text-slate-200
                       transition-all disabled:opacity-50"
          >
            New Session
          </button>

          <span className="text-slate-800">|</span>

          {isAuthenticated ? (
            <div className="flex items-center gap-2">
              <span className="text-xs text-indigo-400 font-medium max-w-[85px] truncate">
                {user.displayName}
              </span>
              <button
                onClick={logout}
                className="text-xs px-2.5 py-1.5 rounded-lg
                           bg-slate-800 hover:bg-slate-700 text-slate-300
                           transition-all"
              >
                Sign Out
              </button>
            </div>
          ) : (
            <button
              onClick={() => setShowAuthModal(true)}
              className="text-xs px-3 py-1.5 rounded-lg
                         bg-indigo-600 hover:bg-indigo-500 text-white font-medium
                         transition-all"
            >
              Sign In
            </button>
          )}
        </div>
      </header>

      {/* ── Main area ── */}
      <div className="flex flex-1 overflow-hidden">

        {/* Left projects sidebar */}
        <ProjectsSidebar
          key={sidebarKey}
          currentSessionId={sessionId}
          onSelectProject={handleSelectProjectVersion}
          onNewChat={handleNewSession}
        />

        {/* Chat */}
        <div className="flex flex-col flex-1 overflow-hidden">

          {starting ? (
            <div className="flex-1 flex items-center justify-center">
              <div className="text-center space-y-3">
                <Spinner size="lg" className="mx-auto" />
                <p className="text-slate-400 text-sm">Starting session...</p>
              </div>
            </div>
          ) : (
            <ChatWindow
              messages={messages}
              messagesEndRef={messagesEndRef}
              sessionId={sessionId}
            />
          )}

          <InputBar
            onSend={sendMessage}
            disabled={isLoading || starting || isPolling}
            stage={stage}
          />
        </div>

        {/* ── Right sidebar ── */}
        <aside className="hidden lg:flex flex-col w-72
                           border-l border-slate-800 bg-slate-900/50
                           overflow-y-auto shrink-0">
          <ContextPanel
            stage={stage}
            blueprint={blueprint}
            validation={validation}
            genSummary={genSummary}
            sessionId={sessionId}
            metadata={metadata}
            // Generation progress
            jobId={jobId}
            jobStatus={jobStatus}
            progress={progress}
            isGenerating={isGenerating}
          />
        </aside>
      </div>
    </div>
  )
}


// ── Stage indicator ──────────────────────────────────────────────

function StageIndicator({ stage, isLoading, isPolling }) {
  const colors = {
    idle:       'bg-slate-500',
    initial:    'bg-blue-500',
    clarifying: 'bg-yellow-500',
    blueprint:  'bg-purple-500',
    confirmed:  'bg-orange-500',
    generating: 'bg-violet-500 animate-pulse',
    fixing:     'bg-orange-500 animate-pulse',
    complete:   'bg-green-500',
  }

  const showSpinner = isLoading || isPolling

  return (
    <div className="flex items-center gap-2">
      {showSpinner && <Spinner size="sm" />}
      <div className={`w-2 h-2 rounded-full ${colors[stage] || 'bg-slate-500'}`} />
      <span className="text-xs text-slate-400">
        {formatStage(stage)}
      </span>
    </div>
  )
}


// ── Context panel (right sidebar) ──────────────────────────────────

function ContextPanel({
  stage, blueprint, validation, genSummary, sessionId,
  jobId, jobStatus, progress, isGenerating, metadata
}) {
  const [activeTab, setActiveTab] = useState('blueprint')

  // Extract metadata
  const l1 = metadata?.l1_understanding
  const l2 = metadata?.l2_capabilities
  const trace = metadata?.traceability_graph?.tables
  const council = metadata?.council_synthesis
  const sim = metadata?.simulation_report
  const genome = metadata?.genome
  const benchmarks = metadata?.benchmarks
  const recs = metadata?.proactive_recommendations

  return (
    <div className="flex flex-col h-full bg-slate-900/40">
      {/* Tab Headers */}
      <div className="flex border-b border-slate-800 bg-slate-950 px-1 py-1 shrink-0 overflow-x-auto whitespace-nowrap scrollbar-none">
        <TabButton active={activeTab === 'blueprint'} onClick={() => setActiveTab('blueprint')} label="Blueprint" />
        {sim && <TabButton active={activeTab === 'simulation'} onClick={() => setActiveTab('simulation')} label="Simulation & Council" />}
        {genome && <TabButton active={activeTab === 'genome'} onClick={() => setActiveTab('genome')} label="DNA & Benchmarks" />}
        {recs && recs.length > 0 && <TabButton active={activeTab === 'recommendations'} onClick={() => setActiveTab('recommendations')} label="Recs" />}
        {trace && <TabButton active={activeTab === 'traceability'} onClick={() => setActiveTab('traceability')} label="Traceability" />}
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {/* Live Generation Progress */}
        {isGenerating && (
          <div className="space-y-2">
            <p className="text-xs font-medium text-violet-400 uppercase tracking-wider">
              ⚡ Generating
            </p>
            <div className="bg-slate-800/80 rounded-xl p-3 border border-violet-500/20
                            shadow-lg shadow-violet-900/10">
              <GenerationProgress
                jobStatus={jobStatus}
                progress={progress}
                jobId={jobId}
              />
            </div>
          </div>
        )}

        {activeTab === 'blueprint' && (
          <>
            {/* Blueprint summary */}
            {blueprint && (
              <div className="space-y-2">
                <p className="text-xs font-medium text-slate-400">Blueprint (L8)</p>
                <div className="bg-slate-800 rounded-lg p-3 space-y-1">
                  <p className="text-sm font-medium text-white">
                    {blueprint.project_name}
                  </p>
                  <p className="text-xs text-slate-400">
                    {blueprint.modules?.length || 0} modules ·{' '}
                    {blueprint.modules?.reduce(
                      (s, m) => s + (m.tables?.length || 0), 0
                    )}{' '}
                    tables planned
                  </p>
                  <p className="text-xs text-slate-500">
                    Domain: {blueprint.domain?.replace(/_/g, ' ')}
                  </p>
                </div>
              </div>
            )}

            {/* Validation score */}
            {validation && (
              <div className="space-y-2">
                <p className="text-xs font-medium text-slate-400">
                  Quality Score
                </p>
                <div className="bg-slate-800 rounded-lg p-3">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-2xl font-bold text-white">
                      {validation.score}
                      <span className="text-sm text-slate-500">/100</span>
                    </span>
                    <span className={`text-lg font-bold
                      ${validation.grade === 'A' ? 'text-green-400'
                        : validation.grade === 'B' ? 'text-blue-400'
                        : validation.grade === 'C' ? 'text-yellow-400'
                        : validation.grade === 'F' ? 'text-red-400'
                        : 'text-orange-400'}`}
                    >
                      {validation.grade}
                    </span>
                  </div>
                  <div className="h-1.5 bg-slate-700 rounded-full overflow-hidden">
                    <div
                      className={`h-full rounded-full transition-all duration-700 ${
                        validation.score >= 90 ? 'bg-green-500'
                        : validation.score >= 80 ? 'bg-blue-500'
                        : validation.score >= 70 ? 'bg-yellow-500'
                        : 'bg-red-500'
                      }`}
                      style={{ width: `${validation.score}%` }}
                    />
                  </div>
                  <p className="text-[10px] text-slate-600 mt-1.5">
                    {validation.passed ? '✅ Production ready' : '⚠️ Needs review'}
                  </p>
                </div>
              </div>
            )}

            {/* Download links */}
            {stage === 'complete' && sessionId && (
              <div className="space-y-2">
                <p className="text-xs font-medium text-slate-400">Downloads</p>
                <div className="space-y-2">
                  <SidebarDownloadBtn
                    href={conversationApi.downloadSql(sessionId)}
                    icon="📄"
                    label="Download SQL"
                  />
                  <SidebarDownloadBtn
                    href={conversationApi.downloadPdf(sessionId)}
                    icon="📋"
                    label="Download PDF"
                  />
                </div>
              </div>
            )}
          </>
        )}

        {activeTab === 'simulation' && sim && (
          <div className="space-y-4">
            {/* Simulation health report */}
            <div className="space-y-2">
              <p className="text-xs font-medium text-slate-400">Simulation Health Report</p>
              <div className="bg-slate-800 rounded-lg p-3 space-y-2.5">
                <div className="flex items-center justify-between">
                  <span className="text-xs text-slate-400">Simulated Scale:</span>
                  <span className="text-xs font-semibold text-white uppercase">{sim.scale_simulated}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-slate-400">Avg Write Amplification:</span>
                  <span className="text-xs font-semibold text-amber-400">{sim.average_write_amplification}x</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-slate-400">Simulated Health Score:</span>
                  <span className={`text-xs font-bold ${sim.health_score >= 85 ? 'text-green-400' : 'text-yellow-400'}`}>
                    {sim.health_score}/100
                  </span>
                </div>
              </div>
            </div>

            {/* Bottlenecks */}
            {sim.bottlenecks && sim.bottlenecks.length > 0 && (
              <div className="space-y-2">
                <p className="text-xs font-medium text-red-400">Predicted Bottlenecks</p>
                <div className="space-y-2">
                  {sim.bottlenecks.map((b, idx) => (
                    <div key={idx} className="bg-red-500/5 border border-red-500/25 rounded-lg p-2.5 space-y-1">
                      <div className="flex items-center justify-between">
                        <code className="text-[11px] font-mono text-red-300 font-bold">{b.table}</code>
                        <span className="text-[9px] bg-red-500/20 text-red-300 px-1 rounded font-semibold">{b.type}</span>
                      </div>
                      <p className="text-[10px] text-slate-400">{b.recommendation}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Council reviews */}
            {council && (
              <div className="space-y-2">
                <p className="text-xs font-medium text-slate-400">Architecture Council Review</p>
                <div className="bg-slate-800 rounded-lg p-3 space-y-2.5">
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-slate-400">Consensus Verdict:</span>
                    <span className={`text-xs font-bold ${council.consensus_verdict === 'APPROVED' ? 'text-green-400' : 'text-amber-400'}`}>
                      {council.consensus_verdict}
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-slate-400">Consensus Score:</span>
                    <span className="text-xs font-bold text-white">{council.consensus_score}/100</span>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {activeTab === 'genome' && genome && (
          <div className="space-y-4">
            <div className="space-y-2">
              <p className="text-xs font-medium text-slate-400">Architecture Genome DNA</p>
              <div className="bg-slate-800 rounded-lg p-3 space-y-3">
                <GenomeMetric label="Workflow Complexity" val={genome.workflow_complexity} />
                <GenomeMetric label="Audit Intensity" val={genome.audit_intensity} />
                <GenomeMetric label="Financial Depth" val={genome.financial_depth} />
                <GenomeMetric label="Document Density" val={genome.document_density} />
                <GenomeMetric label="Approval Complexity" val={genome.approval_complexity} />
                <GenomeMetric label="Lifecycle Depth" val={genome.lifecycle_depth} />
                <GenomeMetric label="Reuse Score" val={genome.reuse_score} />
              </div>
            </div>

            {/* Benchmarks */}
            {benchmarks && benchmarks.benchmarks && (
              <div className="space-y-2">
                <p className="text-xs font-medium text-slate-400">Reference Benchmarks</p>
                <div className="space-y-2">
                  {benchmarks.benchmarks.map((b, idx) => (
                    <div key={idx} className="bg-slate-850 border border-slate-800 rounded-lg p-2.5 flex items-center justify-between">
                      <span className="text-[11px] text-slate-300 font-medium">{b.reference_name}</span>
                      <span className="text-xs font-bold text-blue-400">{b.similarity_percentage}% match</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {activeTab === 'recommendations' && recs && (
          <div className="space-y-3">
            <p className="text-xs font-medium text-slate-400">Proactive Recommendations</p>
            {recs.map((r, idx) => (
              <div key={idx} className="bg-violet-950/20 border border-violet-500/25 rounded-lg p-3 space-y-1.5 shadow-lg shadow-violet-950/10">
                <p className="text-xs font-bold text-violet-300">{r.title}</p>
                <p className="text-[10px] text-slate-400">{r.description}</p>
                {r.suggested_table && (
                  <div className="flex items-center justify-between mt-2 pt-1.5 border-t border-violet-500/10">
                    <span className="text-[10px] font-mono text-violet-400">{r.suggested_table}</span>
                    <span className="text-[9px] text-violet-300 font-semibold uppercase tracking-wider">Suggested Add</span>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {activeTab === 'traceability' && trace && (
          <div className="space-y-3">
            <p className="text-xs font-medium text-slate-400">Traceability Graph</p>
            {Object.entries(trace).map(([tableName, tInfo]) => (
              <div key={tableName} className="bg-slate-800 rounded-lg p-3 space-y-2 border border-slate-700/50">
                <div className="flex items-center justify-between">
                  <code className="text-xs text-blue-300 font-mono font-bold">{tableName}</code>
                  {tInfo.reusable_component && (
                    <span className="text-[10px] bg-purple-500/20 text-purple-300 border border-purple-500/30 px-1.5 py-0.5 rounded">
                      {tInfo.reusable_component}
                    </span>
                  )}
                </div>
                <p className="text-[11px] text-slate-300">
                  <span className="text-slate-500">Capability:</span> {tInfo.originating_capability}
                </p>
                <p className="text-[11px] text-slate-400">{tInfo.design_rationale}</p>
                {tInfo.alternatives_considered && (
                  <p className="text-[10px] text-slate-500 bg-slate-900/50 p-1.5 rounded border border-slate-800">
                    <span className="text-amber-500/80 font-medium font-semibold">Rejected:</span> {tInfo.alternatives_considered}
                  </p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
      {/* Tips */}
      <div className="p-4 border-t border-slate-800 bg-slate-950/50">
        <p className="text-xs font-medium text-slate-500 uppercase tracking-wider mb-1">
          {isGenerating ? 'While you wait' : 'Tips'}
        </p>
        <TipsByStage stage={isGenerating ? 'generating' : stage} />
      </div>
    </div>
  )
}

function GenomeMetric({ label, val }) {
  const pct = Math.round(val * 100)
  return (
    <div className="space-y-1">
      <div className="flex justify-between text-[10px]">
        <span className="text-slate-400 font-medium">{label}</span>
        <span className="text-slate-300 font-bold">{pct}%</span>
      </div>
      <div className="h-1 bg-slate-750 rounded-full overflow-hidden">
        <div className="h-full bg-violet-500 rounded-full" style={{ width: `${pct}%` }} />
      </div>
    </div>
  )
}

function TabButton({ active, onClick, label }) {
  return (
    <button
      onClick={onClick}
      className={`px-3 py-2 text-xs font-medium border-b-2 transition-all ${
        active
          ? 'border-blue-500 text-blue-400 bg-slate-900/40'
          : 'border-transparent text-slate-500 hover:text-slate-300'
      }`}
    >
      {label}
    </button>
  )
}



function SidebarDownloadBtn({ href, icon, label }) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="flex items-center gap-2 w-full px-3 py-2
                 rounded-lg border border-slate-700 text-slate-300
                 hover:border-blue-500/40 hover:text-blue-300
                 hover:bg-blue-500/5 transition-all text-xs"
    >
      <span>{icon}</span>
      <span>{label}</span>
    </a>
  )
}


function TipsByStage({ stage }) {
  const tips = {
    initial:    ['Be specific about your domain', 'Mention if GST is needed', 'Describe the scale'],
    clarifying: ['Answer all questions', 'Skip ones that don\'t apply', 'More detail = better schema'],
    blueprint:  ['Review every module', 'Check table names', 'Type YES to confirm'],
    generating: ['Your schema is being built module by module', 'Each module gets 4 tables per AI call', 'Progress updates every ~3 seconds'],
    complete:   ['Download both files', 'Type "explain [table]" for details', 'Start over for new project'],
  }

  const stageTips = tips[stage] || ['Describe your database project to begin']

  return (
    <ul className="space-y-1">
      {stageTips.map((tip, i) => (
        <li key={i} className="text-xs text-slate-500 flex items-start gap-1">
          <span className="text-slate-600 mt-0.5">·</span>
          {tip}
        </li>
      ))}
    </ul>
  )
}