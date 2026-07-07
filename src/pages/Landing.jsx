// src/pages/Landing.jsx

import { useNavigate } from 'react-router-dom'

const FEATURES = [
  {
    icon: '🧠',
    title: '109 Production Rules',
    desc: 'Extracted from 23 real production databases across 9 domains.',
  },
  {
    icon: '✅',
    title: 'Auto Validation',
    desc: 'Every schema scored against rules. Auto-fixed until score ≥ 80.',
  },
  {
    icon: '📄',
    title: 'Two Deliverables',
    desc: 'Ready-to-run .sql file + complete PDF documentation.',
  },
  {
    icon: '🔒',
    title: 'Production Ready',
    desc: 'Audit trails, GST compliance, archive tables — built in.',
  },
]

const DOMAINS = [
  'Financial', 'HR & Payroll', 'E-Learning',
  'Security Agency', 'Real Estate', 'E-Commerce',
  'Multi-Tenant SaaS', 'IoT & Wearables', 'Land Acquisition',
]

export default function Landing() {
  const navigate = useNavigate()

  return (
    <div className="min-h-screen bg-slate-950 text-slate-200">

      {/* Nav */}
      <nav className="border-b border-slate-800 px-6 py-4">
        <div className="max-w-6xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-xl">🗄️</span>
            <span className="font-bold text-white">SchemaAI</span>
          </div>
          <button
            onClick={() => navigate('/chat')}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-500
                       text-white text-sm font-medium rounded-lg
                       transition-colors"
          >
            Get Started →
          </button>
        </div>
      </nav>

      {/* Hero */}
      <section className="max-w-4xl mx-auto px-6 py-24 text-center">
        <div className="inline-flex items-center gap-2 px-3 py-1
                        bg-blue-500/10 border border-blue-500/20
                        rounded-full text-blue-300 text-xs mb-6">
          <span className="w-1.5 h-1.5 rounded-full bg-blue-400 animate-pulse" />
          109 production rules · 23 real databases analysed
        </div>

        <h1 className="text-5xl font-bold text-white mb-6 leading-tight">
          Generate Production-Quality
          <span className="text-transparent bg-clip-text
                           bg-gradient-to-r from-blue-400 to-purple-400">
            {' '}MySQL Schemas
          </span>
        </h1>

        <p className="text-xl text-slate-400 mb-10 max-w-2xl mx-auto">
          Describe your project in plain English. Get a complete, validated
          database schema with audit trails, GST compliance, and full
          documentation — in minutes.
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <button
            onClick={() => navigate('/chat')}
            className="px-8 py-4 bg-blue-600 hover:bg-blue-500
                       text-white font-semibold rounded-xl text-lg
                       transition-all hover:scale-105 active:scale-95"
          >
            Build My Schema →
          </button>
          <button
            className="px-8 py-4 border border-slate-700
                       hover:border-slate-500 text-slate-300
                       font-semibold rounded-xl text-lg transition-all"
          >
            See Example
          </button>
        </div>
      </section>

      {/* Features */}
      <section className="max-w-6xl mx-auto px-6 pb-20">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {FEATURES.map((f, i) => (
            <div key={i}
                 className="p-5 rounded-xl border border-slate-800
                            bg-slate-900/50 hover:border-slate-700
                            transition-colors">
              <div className="text-3xl mb-3">{f.icon}</div>
              <h3 className="font-semibold text-white mb-1 text-sm">
                {f.title}
              </h3>
              <p className="text-slate-400 text-xs leading-relaxed">
                {f.desc}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* Domains */}
      <section className="border-t border-slate-800 py-12">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <p className="text-slate-500 text-sm mb-4">
            Works for any domain
          </p>
          <div className="flex flex-wrap justify-center gap-2">
            {DOMAINS.map((d, i) => (
              <span key={i}
                    className="px-3 py-1 rounded-full border border-slate-700
                               text-slate-400 text-xs">
                {d}
              </span>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-slate-800 py-6 text-center">
        <p className="text-slate-600 text-xs">
          Built with 23 real production databases · 109 validated rules
        </p>
      </footer>
    </div>
  )
}