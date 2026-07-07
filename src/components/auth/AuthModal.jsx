/* src/components/auth/AuthModal.jsx
   Premium login / register modal
   ─────────────────────────────── */

import { useState } from 'react'
import { useAuth } from '../../context/AuthContext'
import './AuthModal.css'

export default function AuthModal({ onClose }) {
  const { login, register, loading, error } = useAuth()
  const [mode, setMode] = useState('login')   // 'login' | 'register'
  const [form, setForm] = useState({ email: '', displayName: '', password: '' })
  const [localError, setLocalError] = useState(null)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLocalError(null)

    let result
    if (mode === 'login') {
      result = await login(form.email, form.password)
    } else {
      if (!form.displayName.trim()) {
        setLocalError('Display name is required.')
        return
      }
      result = await register(form.email, form.displayName, form.password)
    }

    if (result.success) {
      onClose()
    } else {
      setLocalError(result.error)
    }
  }

  const displayedError = localError || error

  return (
    <div className="auth-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="auth-modal">
        {/* Close button */}
        <button className="auth-modal__close" onClick={onClose} aria-label="Close">✕</button>

        {/* Header */}
        <div className="auth-modal__header">
          <div className="auth-modal__logo">
            <span className="auth-modal__logo-icon">⬡</span>
            <span className="auth-modal__logo-text">BaseAI</span>
          </div>
          <h2 className="auth-modal__title">
            {mode === 'login' ? 'Welcome back' : 'Create your account'}
          </h2>
          <p className="auth-modal__subtitle">
            {mode === 'login'
              ? 'Sign in to access your saved schemas and projects.'
              : 'Start building enterprise-grade database architectures.'}
          </p>
        </div>

        {/* Error banner */}
        {displayedError && (
          <div className="auth-modal__error">
            <span>⚠</span> {displayedError}
          </div>
        )}

        {/* Form */}
        <form className="auth-modal__form" onSubmit={handleSubmit}>
          {mode === 'register' && (
            <div className="auth-field">
              <label htmlFor="auth-name">Display Name</label>
              <input
                id="auth-name"
                type="text"
                placeholder="e.g. Arjun Sharma"
                value={form.displayName}
                onChange={e => setForm(f => ({ ...f, displayName: e.target.value }))}
                required
              />
            </div>
          )}

          <div className="auth-field">
            <label htmlFor="auth-email">Email</label>
            <input
              id="auth-email"
              type="email"
              placeholder="you@company.com"
              value={form.email}
              onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
              required
            />
          </div>

          <div className="auth-field">
            <label htmlFor="auth-password">Password</label>
            <input
              id="auth-password"
              type="password"
              placeholder={mode === 'register' ? 'Min 6 characters' : '••••••••'}
              value={form.password}
              onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
              required
              minLength={6}
            />
          </div>

          <button
            className="auth-modal__submit"
            type="submit"
            disabled={loading}
          >
            {loading
              ? 'Please wait…'
              : mode === 'login' ? 'Sign In' : 'Create Account'}
          </button>
        </form>

        {/* Mode toggle */}
        <div className="auth-modal__footer">
          {mode === 'login' ? (
            <>
              Don't have an account?{' '}
              <button className="auth-toggle" onClick={() => setMode('register')}>
                Sign up free
              </button>
            </>
          ) : (
            <>
              Already have an account?{' '}
              <button className="auth-toggle" onClick={() => setMode('login')}>
                Sign in
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
