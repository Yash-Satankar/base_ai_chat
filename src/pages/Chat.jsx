// src/pages/Chat.jsx

import React, { useEffect, useState } from 'react'
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
import { projectsApi } from '../api/client'

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
    <div className="h-screen flex flex-col bg-[#090d16] text-slate-200">
      {/* ── Header ── */}
      <header className="flex items-center justify-between px-4 sm:px-6 py-3.5 border-b border-slate-800/80 bg-[#090d16]/90 backdrop-blur-xl shrink-0 z-30 shadow-md">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/')}
            className="text-slate-400 hover:text-white transition-colors text-xs font-semibold flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg hover:bg-slate-800/60"
          >
            ← Home
          </button>
          <span className="text-slate-700">|</span>
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-lg bg-gradient-to-tr from-indigo-600 to-purple-600 flex items-center justify-center font-bold text-white text-xs shadow-sm">
              S
            </div>
            <span className="font-extrabold text-white text-sm tracking-tight hidden sm:inline">
              Base<span className="gradient-text">AI</span> Workbench
            </span>
          </div>
        </div>

        {/* Stage indicator */}
        <div className="flex items-center gap-2">
          <StageIndicator stage={stage} isLoading={isLoading} isPolling={isPolling} />
        </div>

        {/* Actions */}
        <div className="flex items-center gap-3">
          <button
            onClick={handleNewSession}
            disabled={isLoading || isPolling}
            className="text-xs px-3 py-1.5 rounded-xl border border-slate-700/80 text-slate-300 hover:border-indigo-500/50 hover:text-white hover:bg-indigo-500/10 transition-all disabled:opacity-50 font-medium"
          >
            + New Design
          </button>

          <span className="text-slate-800">|</span>

          {isAuthenticated ? (
            <div className="flex items-center gap-2">
              <span className="text-xs text-indigo-300 font-semibold max-w-[100px] truncate bg-indigo-500/10 border border-indigo-500/20 px-2.5 py-1 rounded-lg">
                {user.displayName}
              </span>
              <button
                onClick={logout}
                className="text-xs px-2.5 py-1.5 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-300 transition-all"
              >
                Sign Out
              </button>
            </div>
          ) : (
            <button
              onClick={() => setShowAuthModal(true)}
              className="text-xs px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-semibold shadow-md shadow-indigo-600/20 transition-all hover:scale-[1.02]"
            >
              Sign In
            </button>
          )}
        </div>
      </header>

      {/* ── Main Workspace ── */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left projects sidebar */}
        <ProjectsSidebar
          key={sidebarKey}
          currentSessionId={sessionId}
          onSelectProject={handleSelectProjectVersion}
          onNewChat={handleNewSession}
        />

        {/* Chat main area */}
        <div className="flex flex-col flex-1 overflow-hidden bg-gradient-to-b from-[#090d16] to-[#0c1220]">
          {starting ? (
            <div className="flex-1 flex items-center justify-center">
              <div className="text-center space-y-3">
                <Spinner size="lg" className="mx-auto text-indigo-500" />
                <p className="text-slate-400 text-sm font-medium">Initializing Workbench...</p>
              </div>
            </div>
          ) : (
            <ChatWindow
              messages={messages}
              messagesEndRef={messagesEndRef}
              sessionId={sessionId}
              onQuickStart={sendMessage}
            />
          )}

          <InputBar
            onSend={sendMessage}
            disabled={isLoading || starting || isPolling}
            stage={stage}
          />
        </div>

        {/* ── Right sidebar ── */}
        <aside className="hidden lg:flex flex-col w-80 border-l border-slate-800/80 bg-[#090d16]/70 overflow-y-auto shrink-0 z-10 backdrop-blur-md">
          <ContextPanel
            stage={stage}
            blueprint={blueprint}
            validation={validation}
            genSummary={genSummary}
            sessionId={sessionId}
            metadata={metadata}
            jobId={jobId}
            jobStatus={jobStatus}
            progress={progress}
            isGenerating={isGenerating}
          />
        </aside>
      </div>

      {showAuthModal && <AuthModal onClose={() => setShowAuthModal(false)} />}
    </div>
  )
}

function StageIndicator({ stage, isLoading, isPolling }) {
  const colors = {
    idle:       'bg-slate-500',
    initial:    'bg-indigo-500',
    clarifying: 'bg-amber-500',
    blueprint:  'bg-purple-500',
    confirmed:  'bg-indigo-400',
    generating: 'bg-violet-500 animate-pulse',
    fixing:     'bg-rose-500 animate-pulse',
    complete:   'bg-emerald-500',
  }

  const showSpinner = isLoading || isPolling

  return (
    <div className="flex items-center gap-2.5 px-3 py-1 glass-panel rounded-full border border-slate-800">
      {showSpinner && <Spinner size="sm" />}
      <div className={`w-2 h-2 rounded-full ${colors[stage] || 'bg-slate-500'}`} />
      <span className="text-xs font-semibold text-slate-300">
        {formatStage(stage)}
      </span>
    </div>
  )
}

function ContextPanel({
  stage, blueprint, validation, genSummary, sessionId,
  jobId, jobStatus, progress, isGenerating, metadata
}) {
  const [activeTab, setActiveTab] = useState('blueprint')

  const sim = metadata?.simulation_report
  const genome = metadata?.genome
  const trace = metadata?.traceability_graph?.tables
  const recs = metadata?.proactive_recommendations

  return (
    <div className="flex flex-col h-full bg-[#090d16]/50">
      {/* Tab Headers */}
      <div className="flex border-b border-slate-800/80 bg-[#060911] px-1 py-1 shrink-0 overflow-x-auto whitespace-nowrap scrollbar-none">
        <TabButton active={activeTab === 'blueprint'} onClick={() => setActiveTab('blueprint')} label="Blueprint" />
        {sim && <TabButton active={activeTab === 'simulation'} onClick={() => setActiveTab('simulation')} label="Simulation" />}
        {genome && <TabButton active={activeTab === 'genome'} onClick={() => setActiveTab('genome')} label="DNA Specs" />}
        {recs && recs.length > 0 && <TabButton active={activeTab === 'recommendations'} onClick={() => setActiveTab('recommendations')} label="Recs" />}
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4 scrollbar-thin">
        {/* Live Generation Progress */}
        {isGenerating && (
          <div className="space-y-2">
            <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider">
              ⚡ Generation Pipeline
            </p>
            <div className="glass-panel rounded-2xl p-4 border border-indigo-500/20 shadow-xl shadow-indigo-900/10">
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
            {blueprint && (
              <div className="space-y-2">
                <p className="text-xs font-semibold text-slate-400">Blueprint (L8 Spec)</p>
                <div className="glass-card rounded-xl p-3.5 space-y-2 border border-slate-800">
                  <p className="text-sm font-bold text-white">
                    {blueprint.project_name}
                  </p>
                  <p className="text-xs text-slate-400 font-medium">
                    {blueprint.modules?.length || 0} Modules Planned
                  </p>
                </div>
              </div>
            )}

            {validation && (
              <div className="space-y-2">
                <p className="text-xs font-semibold text-slate-400">Rules Compliance</p>
                <div className="glass-card rounded-xl p-3.5 space-y-1.5 border border-slate-800">
                  <div className="flex justify-between items-center text-xs">
                    <span className="text-slate-400 font-medium">Validation Score:</span>
                    <span className="font-bold text-emerald-400">{validation.score} / 100</span>
                  </div>
                  <div className="flex justify-between items-center text-xs">
                    <span className="text-slate-400 font-medium">Status:</span>
                    <span className="font-semibold text-slate-200">{validation.passed ? 'Passed (Grade A)' : 'Action Required'}</span>
                  </div>
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {/* Guide Footnote */}
      <div className="p-4 border-t border-slate-800/80 bg-[#060911]/80">
        <p className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
          {isGenerating ? 'Pipeline Active' : 'Workbench Guidance'}
        </p>
        <TipsByStage stage={isGenerating ? 'generating' : stage} />
      </div>
    </div>
  )
}

function TabButton({ active, onClick, label }) {
  return (
    <button
      onClick={onClick}
      className={`px-3 py-2 text-xs font-semibold border-b-2 transition-all ${
        active
          ? 'border-indigo-500 text-indigo-400 bg-slate-900/60'
          : 'border-transparent text-slate-500 hover:text-slate-300'
      }`}
    >
      {label}
    </button>
  )
}

function TipsByStage({ stage }) {
  const tips = {
    initial:    ['Specify core entities & relationship types', 'Mention GST/tax compliance requirements', 'State expected database scale'],
    clarifying: ['Provide as much context as possible', 'Skip rules that don\'t apply', 'Type "Generate Blueprint" when ready'],
    blueprint:  ['Review target modules and tables', 'Type YES to launch schema generator'],
    generating: ['Multi-pass batching generates tables in isolation', 'Validation rules applied on every table'],
    complete:   ['Download SQL DDL and PDF technical specs', 'Ask to explain individual tables'],
  }

  const stageTips = tips[stage] || ['Describe your database requirements to begin']

  return (
    <ul className="space-y-1.5">
      {stageTips.map((tip, i) => (
        <li key={i} className="text-xs text-slate-400 flex items-start gap-1.5 leading-normal">
          <span className="text-indigo-400 font-bold">•</span>
          {tip}
        </li>
      ))}
    </ul>
  )
}