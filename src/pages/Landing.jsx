// src/pages/Landing.jsx

import React from 'react'
import { useNavigate } from 'react-router-dom'

const FEATURES = [
  {
    icon: '⚡',
    title: '109 Production Rules',
    desc: 'Deep architectural blueprints compiled from 23 real enterprise systems.',
  },
  {
    icon: '🛡️',
    title: 'Automated Validation',
    desc: 'Self-correcting schema validator enforcing 3NF normalization & foreign keys.',
  },
  {
    icon: '📦',
    title: 'Production Deliverables',
    desc: 'Instantly download production-ready .SQL schemas & PDF technical specs.',
  },
  {
    icon: '🔒',
    title: 'Enterprise Compliance',
    desc: 'Built-in audit trails, soft deletes, immutable logs, and GST compliance.',
  },
]

const DOMAINS = [
  { name: 'Financial & Ledger', icon: '💳' },
  { name: 'HR & Payroll', icon: '👥' },
  { name: 'E-Commerce Marketplace', icon: '🛍️' },
  { name: 'Multi-Tenant SaaS', icon: '☁️' },
  { name: 'Healthcare & EHR', icon: '🏥' },
  { name: 'IoT & Real-time Logs', icon: '📡' },
  { name: 'Real Estate & Properties', icon: '🏢' },
  { name: 'Logistics & Supply Chain', icon: '🚚' },
]

export default function Landing() {
  const navigate = useNavigate()

  return (
    <div className="min-h-screen bg-[#090d16] text-slate-200 selection:bg-indigo-500/30 selection:text-indigo-200">
      {/* Background radial glow */}
      <div className="fixed inset-0 pointer-events-none z-0 overflow-hidden">
        <div className="absolute -top-40 -left-40 w-96 h-96 bg-indigo-600/15 rounded-full blur-3xl"></div>
        <div className="absolute top-1/3 -right-40 w-[30rem] h-[30rem] bg-purple-600/10 rounded-full blur-3xl"></div>
      </div>

      <div className="relative z-10">
        {/* Navigation */}
        <nav className="border-b border-slate-800/80 backdrop-blur-xl sticky top-0 bg-[#090d16]/80 px-6 py-4 z-50">
          <div className="max-w-6xl mx-auto flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-indigo-600 to-purple-600 flex items-center justify-center shadow-lg shadow-indigo-500/20 font-bold text-white text-lg">
                S
              </div>
              <span className="font-extrabold text-white text-lg tracking-tight">
                Base<span className="gradient-text">AI</span>
              </span>
            </div>

            <div className="flex items-center gap-4">
              <button
                onClick={() => navigate('/chat')}
                className="px-5 py-2.5 bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white text-sm font-semibold rounded-xl shadow-lg shadow-indigo-600/25 transition-all hover:scale-[1.02] active:scale-[0.98]"
              >
                Launch Workbench →
              </button>
            </div>
          </div>
        </nav>

        {/* Hero Section */}
        <section className="max-w-5xl mx-auto px-6 pt-20 pb-16 text-center">
          <div className="inline-flex items-center gap-2.5 px-4 py-1.5 glass-panel rounded-full text-indigo-300 text-xs font-medium mb-8 border border-indigo-500/20">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            Engineered with 109 Rules · 23 Enterprise Blueprints Analysed
          </div>

          <h1 className="text-5xl sm:text-6xl font-extrabold text-white mb-8 tracking-tight leading-[1.15]">
            Architect Production-Grade <br className="hidden sm:inline" />
            <span className="gradient-text">Database Schemas</span> in Seconds
          </h1>

          <p className="text-lg sm:text-xl text-slate-400 mb-12 max-w-2xl mx-auto leading-relaxed font-normal">
            Transform high-level requirements into enterprise-ready SQL databases. Complete with normalization, foreign key constraints, audit compliance, and PDF documentation.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <button
              onClick={() => navigate('/chat')}
              className="w-full sm:w-auto px-8 py-4 bg-gradient-to-r from-indigo-600 via-indigo-500 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-bold rounded-2xl text-base shadow-xl shadow-indigo-600/30 transition-all hover:scale-[1.02] active:scale-[0.98]"
            >
              Start Designing Free →
            </button>
          </div>
        </section>

        {/* Features Showcase */}
        <section className="max-w-6xl mx-auto px-6 py-12">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {FEATURES.map((f, i) => (
              <div
                key={i}
                className="glass-card p-6 rounded-2xl border border-slate-800/80 hover:border-indigo-500/40 transition-all group"
              >
                <div className="w-12 h-12 rounded-xl bg-indigo-500/10 border border-indigo-500/20 flex items-center justify-center text-2xl mb-4 group-hover:scale-110 transition-transform">
                  {f.icon}
                </div>
                <h3 className="font-bold text-white mb-2 text-base">
                  {f.title}
                </h3>
                <p className="text-slate-400 text-xs leading-relaxed font-normal">
                  {f.desc}
                </p>
              </div>
            ))}
          </div>
        </section>

        {/* Domains List */}
        <section className="border-t border-slate-800/60 py-16">
          <div className="max-w-5xl mx-auto px-6 text-center">
            <h2 className="text-xs font-bold text-indigo-400 uppercase tracking-widest mb-6">
              Supported Industry Domains
            </h2>
            <div className="flex flex-wrap justify-center gap-3">
              {DOMAINS.map((d, i) => (
                <button
                  key={i}
                  onClick={() => navigate('/chat')}
                  className="glass-panel px-4 py-2 rounded-xl text-slate-300 hover:text-white text-xs font-medium flex items-center gap-2 hover:border-indigo-500/40 transition-all hover:scale-[1.03]"
                >
                  <span>{d.icon}</span>
                  <span>{d.name}</span>
                </button>
              ))}
            </div>
          </div>
        </section>

        {/* Footer */}
        <footer className="border-t border-slate-800/80 py-8 text-center bg-[#060911]">
          <div className="max-w-6xl mx-auto px-6 flex flex-col sm:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-2 text-xs text-slate-500">
              <span>BaseAI Engine v2.4</span>
              <span>•</span>
              <span>109 Verified Rules</span>
            </div>
            <p className="text-slate-500 text-xs">
              © {new Date().getFullYear()} BaseAI Inc. Enterprise Database Architect Engine.
            </p>
          </div>
        </footer>
      </div>
    </div>
  )
}