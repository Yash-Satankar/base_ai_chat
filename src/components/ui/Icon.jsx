// src/components/ui/Icon.jsx
// Tiny inline stroke-icon set — no dependency, renders crisp at any size.
// Usage: <Icon name="arrow-right" className="size-4" />

import React from 'react'

const P = {
  'arrow-right':   'M5 12h14M13 6l6 6-6 6',
  'arrow-up':      'M12 19V5M6 11l6-6 6 6',
  'arrow-up-right':'M7 17 17 7M8 7h9v9',
  'chevron-right': 'M9 6l6 6-6 6',
  'chevron-down':  'M6 9l6 6 6-6',
  check:           'M4 12.5l5 5 11-12',
  x:               'M6 6l12 12M18 6L6 18',
  plus:            'M12 5v14M5 12h14',
  copy:            'M9 9h10v10H9zM5 15H4V4h11v1',
  download:        'M12 3v12M7 11l5 5 5-5M5 21h14',
  search:          'M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16zM21 21l-4.3-4.3',
  'log-out':       'M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9',
  eye:             'M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7zM12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
  'eye-off':       'M3 3l18 18M10.6 10.6a3 3 0 0 0 4.2 4.2M9.4 5.2A9.9 9.9 0 0 1 12 5c6.5 0 10 7 10 7a17 17 0 0 1-3.2 4M6.3 6.3A17 17 0 0 0 2 12s3.5 7 10 7a9.7 9.7 0 0 0 3.7-.7',
  sparkles:        'M12 3l1.9 4.6L18.5 9.5 13.9 11.4 12 16l-1.9-4.6L5.5 9.5 10.1 7.6zM19 15l.9 2.1 2.1.9-2.1.9L19 21l-.9-2.1L16 18l2.1-.9z',
  database:        'M12 3c4.4 0 8 1.3 8 3s-3.6 3-8 3-8-1.3-8-3 3.6-3 8-3zM4 6v12c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3',
  shield:          'M12 3l8 3v5c0 5-3.4 8.5-8 10-4.6-1.5-8-5-8-10V6l8-3zM9 12l2 2 4-4',
  'file-code':     'M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8l-5-5zM13 3v5h5M10 12l-2 2 2 2M14 12l2 2-2 2',
  'file-text':     'M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8l-5-5zM13 3v5h5M9 13h6M9 17h4',
  boxes:           'M12 3l7 3.5v7L12 17l-7-3.5v-7L12 3zM5 6.5 12 10l7-3.5M12 10v7',
  layers:          'M12 3l9 5-9 5-9-5 9-5zM3 13l9 5 9-5M3 17l9 5 9-5',
  lock:            'M6 10V8a6 6 0 0 1 12 0v2M5 10h14v10H5zM12 15v2',
  zap:             'M13 2 4 14h7l-1 8 9-12h-7l1-8z',
  loader:          'M12 3v4M12 17v4M5 12H1M23 12h-4M6.3 6.3 3.5 3.5M20.5 20.5l-2.8-2.8M17.7 6.3l2.8-2.8M3.5 20.5l2.8-2.8',
  wand:            'M15 4V2M15 10V8M11 6H9M21 6h-2M6 21 21 6l-3-3L3 18zM17 8l-1-1',
  message:         'M21 12a8 8 0 0 1-11.5 7.2L3 21l1.8-6.5A8 8 0 1 1 21 12z',
  'panel-right':   'M4 4h16v16H4zM15 4v16',
  circle:          'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z',
  'circle-check':  'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM8.5 12l2.5 2.5 5-5',
  refresh:         'M3 12a9 9 0 0 1 15-6.7L21 8M21 3v5h-5M21 12a9 9 0 0 1-15 6.7L3 16M3 21v-5h5',
  route:           'M6 19a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM18 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM8 17h6a4 4 0 0 0 0-8H9a3 3 0 0 1 0-6h1',
}

export default function Icon({ name, className = 'size-4', strokeWidth = 1.6, ...rest }) {
  const d = P[name]
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden="true"
      {...rest}
    >
      {d ? <path d={d} /> : null}
    </svg>
  )
}
