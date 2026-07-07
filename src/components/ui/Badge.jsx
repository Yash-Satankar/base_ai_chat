// src/components/ui/Badge.jsx

export default function Badge({ children, variant = 'default', className = '' }) {
  const variants = {
    default:  'bg-slate-700 text-slate-300',
    critical: 'bg-red-500/20 text-red-400 border border-red-500/30',
    high:     'bg-orange-500/20 text-orange-400 border border-orange-500/30',
    medium:   'bg-blue-500/20 text-blue-400 border border-blue-500/30',
    low:      'bg-green-500/20 text-green-400 border border-green-500/30',
    success:  'bg-green-500/20 text-green-400',
    warning:  'bg-yellow-500/20 text-yellow-400',
  }

  return (
    <span className={`
      inline-flex items-center px-2 py-0.5
      rounded text-xs font-medium
      ${variants[variant]}
      ${className}
    `}>
      {children}
    </span>
  )
}