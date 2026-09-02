// src/utils/formatters.js

export function formatStage(stage) {
  const map = {
    idle:        'Ready',
    initial:     'Getting started',
    clarifying:  'Gathering requirements',
    compiling:   'Designing blueprint...',
    blueprint:   'Blueprint ready',
    confirmed:   'Blueprint confirmed',
    generating:  'Generating schema...',
    fixing:      'Fixing issues...',
    complete:    'Complete ✓',
  }
  return map[stage] || stage
}

export function formatDomain(domain) {
  return (domain || 'general')
    .replace(/_/g, ' ')
    .replace(/\b\w/g, c => c.toUpperCase())
}

export function formatPriority(priority) {
  const colors = {
    critical: 'text-red-400 bg-red-400/10',
    high:     'text-orange-400 bg-orange-400/10',
    medium:   'text-blue-400 bg-blue-400/10',
    low:      'text-green-400 bg-green-400/10',
  }
  return colors[priority] || 'text-gray-400 bg-gray-400/10'
}

export function formatTimestamp(iso) {
  return new Date(iso).toLocaleTimeString('en-IN', {
    hour:   '2-digit',
    minute: '2-digit',
  })
}

export function gradeColor(grade) {
  const map = {
    A: 'text-green-400',
    B: 'text-blue-400',
    C: 'text-yellow-400',
    D: 'text-orange-400',
    F: 'text-red-400',
  }
  return map[grade] || 'text-gray-400'
}

export function scoreColor(score) {
  if (score >= 90) return 'text-green-400'
  if (score >= 80) return 'text-blue-400'
  if (score >= 70) return 'text-yellow-400'
  if (score >= 60) return 'text-orange-400'
  return 'text-red-400'
}