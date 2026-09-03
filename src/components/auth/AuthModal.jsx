// src/components/auth/AuthModal.jsx
import React, { useState } from 'react'
import { useAuth } from '../../context/AuthContext'
import Button from '../ui/Button'
import Icon from '../ui/Icon'
import Logo from '../ui/Logo'

export default function AuthModal({ onClose }) {
  const { login, register, loading, error } = useAuth()
  const [mode, setMode] = useState('login')
  const [form, setForm] = useState({ email: '', displayName: '', password: '' })
  const [showPw, setShowPw] = useState(false)
  const [localError, setLocalError] = useState(null)

  const set = k => e => setForm(f => ({ ...f, [k]: e.target.value }))

  const submit = async e => {
    e.preventDefault()
    setLocalError(null)
    let result
    if (mode === 'login') {
      result = await login(form.email, form.password)
    } else {
      if (!form.displayName.trim()) return setLocalError('Enter a display name.')
      result = await register(form.email, form.displayName, form.password)
    }
    if (result?.success) onClose()
    else setLocalError(result?.error || 'Something went wrong.')
  }

  const err = localError || error

  return (
    <div
      className="fixed inset-0 z-[100] grid place-items-center bg-black/60 p-4 backdrop-blur-sm animate-fade-in"
      onClick={e => e.target === e.currentTarget && onClose()}
    >
      <div className="w-full max-w-[400px] rounded-2xl border border-line bg-bg-elevated p-6 shadow-pop animate-scale-in">
        <div className="mb-5 flex items-start justify-between">
          <div className="flex items-center gap-2.5">
            <Logo className="size-8" />
            <span className="text-[15px] font-semibold tracking-tight">BaseAI</span>
          </div>
          <button
            onClick={onClose}
            className="grid size-7 place-items-center rounded-md text-ink-dim transition-colors hover:bg-white/[0.06] hover:text-ink"
            aria-label="Close"
          >
            <Icon name="x" className="size-4" />
          </button>
        </div>

        <h2 className="text-[19px] font-semibold tracking-tight">
          {mode === 'login' ? 'Welcome back' : 'Create your account'}
        </h2>
        <p className="mt-1 text-[13px] text-ink-muted">
          {mode === 'login'
            ? 'Sign in to keep your project history and versions.'
            : 'Save your schemas, track quality scores, and pick up where you left off.'}
        </p>

        {err && (
          <div className="mt-4 flex items-start gap-2 rounded-lg border border-danger-line bg-danger-bg px-3 py-2 text-[12.5px] text-danger">
            <Icon name="x" className="mt-0.5 size-3.5 shrink-0" strokeWidth={2.2} />
            {err}
          </div>
        )}

        <form onSubmit={submit} className="mt-5 space-y-3.5">
          {mode === 'register' && (
            <Field label="Display name" id="auth-name">
              <input id="auth-name" className="field" placeholder="Alex Morgan" value={form.displayName} onChange={set('displayName')} required />
            </Field>
          )}
          <Field label="Email" id="auth-email">
            <input id="auth-email" type="email" className="field" placeholder="you@company.com" value={form.email} onChange={set('email')} required />
          </Field>
          <Field label="Password" id="auth-pw">
            <div className="relative">
              <input
                id="auth-pw"
                type={showPw ? 'text' : 'password'}
                className="field pr-10"
                placeholder={mode === 'register' ? 'At least 6 characters' : '••••••••'}
                value={form.password}
                onChange={set('password')}
                minLength={6}
                required
              />
              <button
                type="button"
                onClick={() => setShowPw(v => !v)}
                className="absolute right-2.5 top-1/2 grid size-6 -translate-y-1/2 place-items-center rounded text-ink-dim transition-colors hover:text-ink"
                aria-label={showPw ? 'Hide password' : 'Show password'}
              >
                <Icon name={showPw ? 'eye-off' : 'eye'} className="size-4" />
              </button>
            </div>
          </Field>

          <Button type="submit" variant="primary" size="lg" disabled={loading} className="w-full">
            {loading ? 'Working…' : mode === 'login' ? 'Sign in' : 'Create account'}
          </Button>
        </form>

        <p className="mt-4 text-center text-[12.5px] text-ink-dim">
          {mode === 'login' ? "Don't have an account? " : 'Already have an account? '}
          <button
            onClick={() => { setMode(mode === 'login' ? 'register' : 'login'); setLocalError(null) }}
            className="font-medium text-accent-hi hover:underline"
          >
            {mode === 'login' ? 'Sign up' : 'Sign in'}
          </button>
        </p>
      </div>
    </div>
  )
}

function Field({ label, id, children }) {
  return (
    <div className="space-y-1.5">
      <label htmlFor={id} className="label block">{label}</label>
      {children}
    </div>
  )
}
