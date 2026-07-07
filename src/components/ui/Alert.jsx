// src/components/ui/Alert.jsx

export default function Alert({ type = 'info', children, className = '' }) {
  const types = {
    info:    'bg-blue-500/10 border-blue-500/30 text-blue-300',
    error:   'bg-red-500/10 border-red-500/30 text-red-300',
    success: 'bg-green-500/10 border-green-500/30 text-green-300',
    warning: 'bg-yellow-500/10 border-yellow-500/30 text-yellow-300',
  }

  return (
    <div className={`
      border rounded-lg px-4 py-3 text-sm
      ${types[type]} ${className}
    `}>
      {children}
    </div>
  )
}