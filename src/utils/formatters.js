// src/utils/formatters.js

export const STAGE_STEPS = [
  { key: 'describe',  label: 'Describe',  match: ['idle', 'initial'] },
  { key: 'clarify',   label: 'Clarify',   match: ['clarifying'] },
  { key: 'blueprint', label: 'Blueprint', match: ['compiling', 'blueprint', 'confirmed'] },
  { key: 'generate',  label: 'Generate',  match: ['generating', 'fixing'] },
  { key: 'done',      label: 'Done',      match: ['complete'] },
]

export function stageStepIndex(stage) {
  const i = STAGE_STEPS.findIndex(s => s.match.includes(stage))
  return i === -1 ? 0 : i
}

export function formatStage(stage) {
  const map = {
    idle:        'Ready',
    initial:     'Getting started',
    clarifying:  'Gathering requirements',
    compiling:   'Designing blueprint',
    blueprint:   'Blueprint ready',
    confirmed:   'Blueprint confirmed',
    generating:  'Generating schema',
    fixing:      'Refining schema',
    complete:    'Complete',
  }
  return map[stage] || 'Ready'
}

export function formatDomain(domain) {
  return (domain || 'general')
    .replace(/_/g, ' ')
    .replace(/\b\w/g, c => c.toUpperCase())
}

export function domainIcon(domain) {
  const d = (domain || '').toLowerCase()
  if (/(hospital|health|medical|ehr|clinic|patient)/.test(d)) return '🏥'
  if (/(finance|bank|ledger|payment|fintech|wallet)/.test(d)) return '🏦'
  if (/(school|educat|learning|lms|course)/.test(d)) return '🎓'
  if (/(logistic|deliver|fleet|shipment|supply)/.test(d)) return '🚚'
  if (/(commerce|shop|marketplace|retail|order)/.test(d)) return '🛒'
  if (/(hotel|travel|estate|property|realty)/.test(d)) return '🏢'
  if (/(saas|tenant|subscription|workspace)/.test(d)) return '☁️'
  if (/(hr|payroll|employee|recruit)/.test(d)) return '👥'
  if (/(iot|sensor|device|telemetry|realtime|real-time)/.test(d)) return '📡'
  return '🗄️'
}

export function formatTimestamp(iso) {
  try {
    return new Date(iso).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  } catch {
    return ''
  }
}

// grade / score → palette text classes (see tailwind.config.js)
export function gradeColor(grade) {
  return {
    A: 'text-ok',
    B: 'text-accent-hi',
    C: 'text-warn',
    D: 'text-warn',
    F: 'text-danger',
  }[grade] || 'text-ink-dim'
}

export function scoreColor(score) {
  if (score >= 85) return 'text-ok'
  if (score >= 70) return 'text-accent-hi'
  if (score >= 55) return 'text-warn'
  return 'text-danger'
}

export function scoreBar(score) {
  if (score >= 85) return 'bg-ok'
  if (score >= 70) return 'bg-accent'
  if (score >= 55) return 'bg-warn'
  return 'bg-danger'
}

export function scoreHex(score) {
  if (!score && score !== 0) return '#71717a'
  if (score >= 85) return '#3ecf8e'
  if (score >= 70) return '#a89bff'
  if (score >= 55) return '#f5a623'
  return '#f56565'
}
