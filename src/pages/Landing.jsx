// src/pages/Landing.jsx
import React from 'react'
import { useNavigate } from 'react-router-dom'
import Button from '../components/ui/Button'
import Icon from '../components/ui/Icon'
import Logo from '../components/ui/Logo'
import DownloadButtons from '../components/schema/DownloadButtons'

// Real output from the actual product — generated end-to-end (conversation
// -> blueprint -> batched generation -> auto-refinement -> real-MySQL
// validation), not hand-written. Every figure below is read directly off
// the committed schema files in public/showcase/, not asserted copy.
const SHOWCASE = [
  {
    slug: 'financial-ledger',
    icon: '🏦',
    name: 'Financial Ledger',
    blurb: 'Double-entry NBFC accounting core — chart of accounts, journal vouchers, GST, bank reconciliation.',
    tables: 22,
    score: 98,
    grade: 'A',
    mysql: 'clean',
    findings: [
      '18 foreign keys — 100% with an explicit ON DELETE/ON UPDATE action (SET NULL on optional references), never left at implicit RESTRICT.',
      '2 Layer-3 archive tables and 3 lifecycle-transition trails on its regulated entities.',
    ],
  },
  {
    slug: 'healthcare-ehr',
    icon: '🏥',
    name: 'Healthcare EHR',
    blurb: 'Clinical database for a 300-bed hospital — encounters, medication administration, lab results, access audit log.',
    tables: 35,
    score: 100,
    grade: 'A',
    mysql: 'clean',
    findings: [
      '59 foreign keys — 100% with an explicit action (57 RESTRICT, 2 SET NULL) matched to whether the relationship is independent or optional.',
      '5 Layer-3 archive tables and 6 lifecycle-transition trails for patient and clinical entities.',
    ],
  },
  {
    slug: 'saas-control-plane',
    icon: '☁️',
    name: 'Multi-Tenant SaaS',
    blurb: 'B2B control plane — organisations, RBAC, metered billing, webhooks, per-tenant audit log.',
    tables: 40,
    score: 96,
    grade: 'A',
    mysql: 'clean',
    findings: [
      '51 foreign keys — 100% with an explicit action (46 RESTRICT, 3 SET NULL, 2 CASCADE on owned child records).',
      '5 archive tables and 10 lifecycle trails across billing and access-control entities.',
    ],
  },
  {
    slug: 'logistics-freight',
    icon: '🚚',
    name: 'Logistics',
    blurb: 'National parcel carrier — shipments, hub routing, high-volume tracking events, proof of delivery, claims.',
    tables: 35,
    score: 100,
    grade: 'A',
    mysql: 'clean',
    findings: [
      '55 foreign keys — 100% with an explicit action (51 RESTRICT, 2 SET NULL, 2 CASCADE on owned child records).',
      '5 archive tables and 7 lifecycle trails on its regulated shipment and claim entities.',
    ],
  },
]

const FEATURES = [
  { icon: 'layers',   title: '98 architecture rules', desc: 'Distilled from 23 production databases across 9 domains, applied as your schema is designed.' },
  { icon: 'shield',   title: '7-dimension validator', desc: 'Naming, audit fields, indexes, money types, data preservation — scored, then auto-fixed.' },
  { icon: 'file-code',title: 'SQL + PDF, ready to run', desc: 'A clean MySQL DDL file plus documentation explaining every table and decision.' },
  { icon: 'lock',     title: 'Compliance built in', desc: 'Soft deletes, immutable transaction logs, archive mirrors, GST columns where they belong.' },
]

const DOMAINS = [
  ['🏦', 'Financial & ledger'], ['👥', 'HR & payroll'], ['🛒', 'E-commerce'],
  ['☁️', 'Multi-tenant SaaS'], ['🏥', 'Healthcare & EHR'], ['📡', 'IoT & telemetry'],
  ['🏢', 'Real estate'], ['🚚', 'Logistics'], ['🎓', 'E-learning'],
]

const STEPS = [
  { n: '01', title: 'Describe it', body: 'Say what you\'re building in plain English. No schema jargon required.' },
  { n: '02', title: 'Review the blueprint', body: 'BaseAI asks a few sharp questions, then proposes the modules and tables.' },
  { n: '03', title: 'Get the schema', body: 'Confirm, and it generates the validated DDL and a PDF you can hand to a dev.' },
]

export default function Landing() {
  const navigate = useNavigate()

  return (
    <div className="relative min-h-screen bg-bg text-ink grain overflow-hidden">
      {/* ambient backdrop */}
      <div aria-hidden className="pointer-events-none fixed inset-0 z-0">
        <div className="absolute left-1/2 top-[-14rem] h-[34rem] w-[46rem] -translate-x-1/2 rounded-full bg-accent/[0.13] blur-[130px] animate-drift" />
        <div className="absolute right-[-12rem] top-1/3 h-[24rem] w-[24rem] rounded-full bg-[#3a7bd5]/[0.07] blur-[120px]" />
        <div className="absolute inset-0 bg-[radial-gradient(60rem_40rem_at_50%_-10%,rgba(139,124,248,0.06),transparent)]" />
      </div>

      <div className="relative z-10">
        <Nav navigate={navigate} />

        {/* ── Hero ── */}
        <section className="mx-auto max-w-3xl px-6 pt-24 pb-14 text-center">
          <div className="mb-7 inline-flex items-center gap-2 rounded-full border border-line bg-white/[0.03] px-3 py-1 text-[12.5px] text-ink-muted">
            <span className="size-1.5 rounded-full bg-ok shadow-[0_0_8px_theme(colors.ok.DEFAULT)]" />
            98 rules · 23 production schemas analysed
          </div>

          <h1 className="text-[2.6rem] font-semibold leading-[1.06] tracking-tightest sm:text-[3.4rem]">
            Production-grade database schemas,
            <br className="hidden sm:block" />{' '}
            <span className="text-gradient">designed in a conversation.</span>
          </h1>

          <p className="mx-auto mt-6 max-w-xl text-[16.5px] leading-relaxed text-ink-muted">
            Describe your system in plain English. BaseAI asks what it needs, plans the
            architecture, and hands back a validated MySQL schema with documentation.
          </p>

          <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Button
              size="lg" variant="primary" onClick={() => navigate('/chat')}
              iconRight={<Icon name="arrow-right" className="size-4" />}
              className="w-full sm:w-auto"
            >
              Start designing
            </Button>
            <Button
              as="a" href="#how" size="lg" variant="ghost"
              iconRight={<Icon name="chevron-down" className="size-4" />}
            >
              See how it works
            </Button>
          </div>

          <PreviewFrame />
        </section>

        {/* ── Features ── */}
        <section className="mx-auto max-w-5xl px-6 py-16">
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
            {FEATURES.map((f) => (
              <div
                key={f.title}
                className="group rounded-xl border border-line bg-bg-raised p-5 shadow-inset-hl transition-[border-color,transform] duration-150 hover:-translate-y-0.5 hover:border-line-strong"
              >
                <div className="mb-4 grid size-9 place-items-center rounded-lg border border-line bg-white/[0.03] text-accent-hi">
                  <Icon name={f.icon} className="size-[18px]" />
                </div>
                <h3 className="text-[14.5px] font-medium text-ink">{f.title}</h3>
                <p className="mt-1.5 text-[13px] leading-relaxed text-ink-dim">{f.desc}</p>
              </div>
            ))}
          </div>
        </section>

        {/* ── How it works ── */}
        <section id="how" className="mx-auto max-w-5xl px-6 py-16">
          <p className="label mb-8 text-center">How it works</p>
          <div className="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-line bg-line md:grid-cols-3">
            {STEPS.map((s) => (
              <div key={s.n} className="bg-bg-raised p-7">
                <span className="font-mono text-[13px] text-accent-hi">{s.n}</span>
                <h3 className="mt-3 text-[15px] font-medium text-ink">{s.title}</h3>
                <p className="mt-1.5 text-[13px] leading-relaxed text-ink-dim">{s.body}</p>
              </div>
            ))}
          </div>
        </section>

        {/* ── Domains ── */}
        <section className="mx-auto max-w-4xl px-6 py-14 text-center">
          <p className="label mb-6">Built for real domains</p>
          <div className="flex flex-wrap justify-center gap-2">
            {DOMAINS.map(([icon, name]) => (
              <button
                key={name}
                onClick={() => navigate('/chat')}
                className="inline-flex items-center gap-2 rounded-full border border-line bg-white/[0.03] px-3.5 py-1.5 text-[13px] text-ink-muted transition-colors hover:border-line-strong hover:text-ink"
              >
                <span className="text-[13px]">{icon}</span>
                {name}
              </button>
            ))}
          </div>
        </section>

        {/* ── Showcase ── */}
        <section className="mx-auto max-w-5xl px-6 py-16">
          <p className="label mb-2 text-center">Real output, not mockups</p>
          <h2 className="text-center text-[1.6rem] font-semibold tracking-tight text-ink">
            Four schemas, generated end-to-end by the actual product
          </h2>
          <p className="mx-auto mt-2.5 max-w-xl text-center text-[13.5px] leading-relaxed text-ink-dim">
            Same conversation → blueprint → generation → auto-refinement → real-MySQL
            validation pipeline you'd run. Download the exact files below.
          </p>

          <div className="mt-8 grid grid-cols-1 gap-4 sm:grid-cols-2">
            {SHOWCASE.map((s) => (
              <ShowcaseCard key={s.slug} s={s} />
            ))}
          </div>
        </section>

        {/* ── Trust strip ── */}
        <section className="mx-auto max-w-4xl px-6 py-14">
          <div className="grid grid-cols-1 divide-y divide-line rounded-2xl border border-line bg-bg-raised sm:grid-cols-3 sm:divide-x sm:divide-y-0">
            {[
              ['80–120', 'tables in a full enterprise schema'],
              ['A–F', 'quality grade on every generation'],
              ['1 PDF', 'explaining every table and rule applied'],
            ].map(([big, small]) => (
              <div key={small} className="px-6 py-7 text-center">
                <div className="text-2xl font-semibold tracking-tight text-ink">{big}</div>
                <div className="mt-1 text-[12.5px] text-ink-dim">{small}</div>
              </div>
            ))}
          </div>
        </section>

        {/* ── CTA ── */}
        <section className="mx-auto max-w-3xl px-6 pb-24 pt-10">
          <div className="relative overflow-hidden rounded-2xl border border-line bg-bg-raised p-10 text-center shadow-inset-hl">
            <div aria-hidden className="pointer-events-none absolute inset-x-0 -top-24 mx-auto h-48 w-3/4 rounded-full bg-accent/10 blur-3xl" />
            <h2 className="relative text-2xl font-semibold tracking-tight">Design your first schema</h2>
            <p className="relative mx-auto mt-2 max-w-md text-[14px] text-ink-muted">
              No setup. Describe the system, review the plan, download the SQL.
            </p>
            <Button
              size="lg" variant="primary" onClick={() => navigate('/chat')}
              iconRight={<Icon name="arrow-right" className="size-4" />}
              className="relative mt-6"
            >
              Open the Workbench
            </Button>
          </div>
        </section>

        <footer className="hairline-t">
          <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-3 px-6 py-8 text-[12.5px] text-ink-faint sm:flex-row">
            <div className="flex items-center gap-2">
              <Logo className="size-5" />
              <span>BaseAI Engine · 98 verified rules</span>
            </div>
            <span>© {new Date().getFullYear()} BaseAI. Enterprise database architecture.</span>
          </div>
        </footer>
      </div>
    </div>
  )
}

/* ── pieces ─────────────────────────────────────────────── */

function ShowcaseCard({ s }) {
  return (
    <div className="rounded-2xl border border-line bg-bg-raised p-5 shadow-inset-hl transition-[border-color,transform] duration-150 hover:-translate-y-0.5 hover:border-line-strong">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <span className="grid size-9 shrink-0 place-items-center rounded-lg border border-line bg-white/[0.03] text-[16px]">
            {s.icon}
          </span>
          <div>
            <h3 className="text-[14.5px] font-medium text-ink">{s.name}</h3>
            <p className="text-[11.5px] text-ink-faint">{s.tables} tables</p>
          </div>
        </div>
        <div className="flex flex-col items-end gap-1">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-ok-line bg-ok-bg px-2.5 py-0.5 text-[11px] font-medium text-ok">
            {s.score}/100 · {s.grade}
          </span>
          <span className="inline-flex items-center gap-1 text-[10.5px] text-ink-faint">
            <span className="size-1.5 rounded-full bg-ok" />
            MySQL {s.mysql}
          </span>
        </div>
      </div>

      <p className="mt-3 text-[12.5px] leading-relaxed text-ink-dim">{s.blurb}</p>

      <ul className="mt-3 space-y-1.5">
        {s.findings.map((f) => (
          <li key={f} className="flex gap-2 text-[11.5px] leading-relaxed text-ink-muted">
            <Icon name="check" className="mt-0.5 size-3 shrink-0 text-accent-hi" />
            <span>{f}</span>
          </li>
        ))}
      </ul>

      <div className="mt-4">
        <DownloadButtons
          sqlUrl={`/showcase/${s.slug}.sql`}
          pdfUrl={`/showcase/${s.slug}.pdf`}
        />
      </div>
    </div>
  )
}

function Nav({ navigate }) {
  return (
    <nav className="sticky top-0 z-50 border-b border-line/70 bg-bg/70 backdrop-blur-xl">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-3.5">
        <button onClick={() => navigate('/')} className="flex items-center gap-2.5">
          <Logo className="size-7" />
          <span className="text-[15px] font-semibold tracking-tight">BaseAI</span>
        </button>
        <div className="flex items-center gap-1.5">
          <Button size="sm" variant="ghost" onClick={() => navigate('/chat')}>Sign in</Button>
          <Button
            size="sm" variant="primary" onClick={() => navigate('/chat')}
            iconRight={<Icon name="arrow-right" className="size-3.5" />}
          >
            Launch Workbench
          </Button>
        </div>
      </div>
    </nav>
  )
}

// A built-from-divs mini Workbench — ages better than a screenshot.
function PreviewFrame() {
  return (
    <div className="relative mx-auto mt-16 max-w-3xl">
      <div aria-hidden className="pointer-events-none absolute -inset-x-8 -top-10 h-40 rounded-full bg-accent/10 blur-3xl" />
      <div className="relative overflow-hidden rounded-2xl border border-line bg-bg-raised shadow-pop">
        {/* window bar */}
        <div className="flex items-center gap-2 border-b border-line px-4 py-2.5">
          <span className="size-2.5 rounded-full bg-white/10" />
          <span className="size-2.5 rounded-full bg-white/10" />
          <span className="size-2.5 rounded-full bg-white/10" />
          <span className="ml-3 text-[11px] text-ink-faint">baseai.workbench</span>
        </div>

        <div className="grid grid-cols-[1fr] gap-0 sm:grid-cols-[1fr_260px]">
          {/* chat */}
          <div className="space-y-4 p-5 text-left">
            <div className="flex justify-end">
              <div className="max-w-[80%] rounded-2xl border border-line bg-white/[0.05] px-3.5 py-2 text-[12.5px] text-ink">
                Multi-tenant B2B billing with usage-based tiers and Stripe payouts
              </div>
            </div>
            <div className="flex gap-2.5">
              <Logo className="size-6 shrink-0" />
              <div className="space-y-2 text-[12.5px] leading-relaxed text-ink-muted">
                <p>Got it — a SaaS billing engine. A few things I need:</p>
                <p className="text-ink">1. Per-tenant plans, or global plans with tenant overrides?</p>
                <p className="text-ink">2. Do payouts need a reconciliation ledger?</p>
              </div>
            </div>
          </div>
          {/* side panel */}
          <div className="hidden border-l border-line bg-bg p-4 sm:block">
            <p className="label mb-3">Blueprint</p>
            {['tenant_header_all', 'subscription_header_all', 'usage_transaction_all', 'payout_ledger_transaction_all'].map((t) => (
              <div key={t} className="mb-1.5 flex items-center gap-2 text-[11.5px]">
                <Icon name="database" className="size-3 text-accent-hi" />
                <span className="font-mono text-ink-muted">{t}</span>
              </div>
            ))}
            <div className="mt-4 rounded-lg border border-ok-line bg-ok-bg px-2.5 py-2 text-[11.5px] text-ok">
              Validation 92 / 100 · Grade A
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
