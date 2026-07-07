// src/context/AuthContext.jsx
// Global auth state — provides user, token, login(), logout(), and register()

import { createContext, useContext, useState, useCallback } from 'react'
import { authApi } from '../api/client'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try {
      const saved = localStorage.getItem('baseai_user')
      return saved ? JSON.parse(saved) : null
    } catch {
      return null
    }
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const login = useCallback(async (email, password) => {
    setLoading(true)
    setError(null)
    try {
      const data = await authApi.login(email, password)
      localStorage.setItem('baseai_token', data.access_token)
      localStorage.setItem('baseai_user', JSON.stringify({
        id: data.user_id,
        email: data.email,
        displayName: data.display_name,
      }))
      setUser({ id: data.user_id, email: data.email, displayName: data.display_name })
      return { success: true }
    } catch (err) {
      setError(err.message)
      return { success: false, error: err.message }
    } finally {
      setLoading(false)
    }
  }, [])

  const register = useCallback(async (email, displayName, password) => {
    setLoading(true)
    setError(null)
    try {
      await authApi.register(email, displayName, password)
      // Auto-login after register
      return await login(email, password)
    } catch (err) {
      setError(err.message)
      return { success: false, error: err.message }
    } finally {
      setLoading(false)
    }
  }, [login])

  const logout = useCallback(() => {
    localStorage.removeItem('baseai_token')
    localStorage.removeItem('baseai_user')
    setUser(null)
    setError(null)
  }, [])

  return (
    <AuthContext.Provider value={{ user, loading, error, login, logout, register, isAuthenticated: !!user }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider')
  return ctx
}
