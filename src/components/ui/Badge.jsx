// src/components/ui/Badge.jsx
import React from 'react'

const VARIANTS = {
  default:  'bg-white/[0.05] text-ink-muted border-line',
  neutral:  'bg-white/[0.05] text-ink-muted border-line',
  accent:   'bg-accent-bg text-accent-hi border-accent-line',
  success:  'bg-ok-bg text-ok border-ok-line',
  ok:       'bg-ok-bg text-ok border-ok-line',
  warning:  'bg-warn-bg text-warn border-warn-line',
  critical: 'bg-danger-bg text-danger border-danger-line',
  high:     'bg-warn-bg text-warn border-warn-line',
  medium:   'bg-accent-bg text-accent-hi border-accent-line',
  low:      'bg-ok-bg text-ok border-ok-line',
}

export default function Badge({ children, variant = 'default', className = '' }) {
  return (
    <span
      className={`inline-flex items-center gap-1 px-2 h-[20px] rounded-md border text-[11px] font-medium leading-none ${
        VARIANTS[variant] || VARIANTS.default
      } ${className}`}
    >
      {children}
    </span>
  )
}
