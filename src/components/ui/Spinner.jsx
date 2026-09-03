// src/components/ui/Spinner.jsx
import React from 'react'

const SIZES = { xs: 'size-3', sm: 'size-4', md: 'size-5', lg: 'size-7' }

export default function Spinner({ size = 'md', className = '' }) {
  return (
    <span
      role="status"
      aria-label="Loading"
      className={`inline-block rounded-full border-[1.5px] border-white/15 border-t-accent-hi animate-spin ${SIZES[size]} ${className}`}
    />
  )
}
