// src/components/ui/Logo.jsx
import React from 'react'
import Icon from './Icon'

export default function Logo({ className = 'size-7' }) {
  return (
    <span
      className={`grid place-items-center rounded-[7px] bg-gradient-to-br from-accent-hi to-accent text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.25)] ${className}`}
    >
      <Icon name="database" className="size-[58%]" strokeWidth={1.9} />
    </span>
  )
}
