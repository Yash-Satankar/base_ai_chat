// src/components/ui/Button.jsx
import React from 'react'

const BASE =
  'relative inline-flex items-center justify-center gap-1.5 font-medium select-none ' +
  'transition-[transform,background-color,border-color,box-shadow,color] duration-150 ' +
  'disabled:opacity-45 disabled:pointer-events-none active:translate-y-px whitespace-nowrap'

const SIZES = {
  xs: 'h-7 px-2.5 text-[12px] rounded-lg',
  sm: 'h-8 px-3 text-[13px] rounded-lg',
  md: 'h-9 px-4 text-sm rounded-lg',
  lg: 'h-11 px-5 text-[15px] rounded-xl',
}

const VARIANTS = {
  primary:
    'text-white bg-accent hover:bg-accent-hi shadow-[inset_0_1px_0_rgba(255,255,255,0.18),0_1px_2px_rgba(0,0,0,0.5)]',
  secondary:
    'text-ink bg-white/[0.04] border border-line hover:bg-white/[0.07] hover:border-line-strong',
  ghost:
    'text-ink-muted hover:text-ink hover:bg-white/[0.05]',
  subtle:
    'text-accent-hi bg-accent-bg border border-accent-line hover:bg-[rgba(139,124,248,0.16)]',
  danger:
    'text-danger bg-danger-bg border border-danger-line hover:bg-[rgba(245,101,101,0.16)]',
}

export default function Button({
  as: As = 'button',
  variant = 'secondary',
  size = 'md',
  className = '',
  iconLeft = null,
  iconRight = null,
  children,
  ...rest
}) {
  return (
    <As className={`${BASE} ${SIZES[size]} ${VARIANTS[variant]} ${className}`} {...rest}>
      {iconLeft}
      {children}
      {iconRight}
    </As>
  )
}
