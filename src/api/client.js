// src/api/client.js

import axios from 'axios'

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

const api = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 300000,
})

// ── Auth token injection ─────────────────────────────────────────
api.interceptors.request.use(config => {
  const token = localStorage.getItem('baseai_token')
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`
  }
  console.log(`→ ${config.method?.toUpperCase()} ${config.url}`)
  return config
})

// ── Global error handler ─────────────────────────────────────────
// NOTE: /conversation/* endpoints no longer return a 5xx for engine
// failures — they reply 200 with an in-persona `message` and the preserved
// `stage` (and `success: false`). This handler therefore only sees genuine
// transport/client conditions there (network down, 400, 401, 404, 429).
api.interceptors.response.use(
  response => response,
  error => {
    const msg =
      error.response?.data?.detail ||
      error.response?.data?.error ||
      error.message ||
      'Something went wrong'

    // Auto-clear stale token on 401
    if (error.response?.status === 401) {
      localStorage.removeItem('baseai_token')
      localStorage.removeItem('baseai_user')
    }

    console.error(`API Error: ${msg}`)
    return Promise.reject(new Error(msg))
  }
)

// ── Auth API ─────────────────────────────────────────────────────

export const authApi = {
  register: (email, displayName, password) =>
    api.post('/auth/register', { email, display_name: displayName, password }).then(r => r.data),

  login: (email, password) =>
    api.post('/auth/login', { email, password }).then(r => r.data),

  createApiKey: (name, expiresDays = null) =>
    api.post('/auth/api-keys', { name, expires_days: expiresDays }).then(r => r.data),

  listApiKeys: () =>
    api.get('/auth/api-keys').then(r => r.data),

  revokeApiKey: (keyId) =>
    api.delete(`/auth/api-keys/${keyId}`).then(r => r.data),
}

// ── Projects API ─────────────────────────────────────────────────

export const projectsApi = {
  list: () =>
    api.get('/projects/').then(r => r.data),

  create: (name, description = null, domain = null) =>
    api.post('/projects/', { name, description, domain }).then(r => r.data),

  get: (projectId) =>
    api.get(`/projects/${projectId}`).then(r => r.data),

  delete: (projectId) =>
    api.delete(`/projects/${projectId}`).then(r => r.data),

  getVersion: (projectId, versionNumber) =>
    api.get(`/projects/${projectId}/versions/${versionNumber}`).then(r => r.data),
}

// ── Conversation API ─────────────────────────────────────────────

export const conversationApi = {
  start: (projectId = null) =>
    api.post('/conversation/start', null, {
      params: projectId ? { project_id: projectId } : {}
    }).then(r => r.data),

  message: (sessionId, message) =>
    api.post('/conversation/message', {
      session_id: sessionId,
      message,
    }).then(r => r.data),

  getStatus: (sessionId) =>
    api.get(`/conversation/session/${sessionId}`).then(r => r.data),

  downloadSql: (sessionId) =>
    `${BASE_URL}/conversation/download/sql/${sessionId}`,

  downloadPdf: (sessionId) =>
    `${BASE_URL}/conversation/download/pdf/${sessionId}`,
}

// ── Rules API ────────────────────────────────────────────────────

export const rulesApi = {
  search: (query, topK = 5) =>
    api.post('/rules/search', { query, top_k: topK }).then(r => r.data),

  stats: () =>
    api.get('/rules/').then(r => r.data),
}

// ── Health ───────────────────────────────────────────────────────

export const healthApi = {
  check: () => api.get('/health/').then(r => r.data),
  full: () => api.get('/health/full').then(r => r.data),
}

// ── Planner (async job) API ──────────────────────────────────────

export const plannerApi = {
  submitJob: (requirement, blueprint = null, additionalContext = null, sessionId = null) =>
    api.post('/planner/generate', {
      requirement,
      blueprint,
      additional_context: additionalContext,
      session_id: sessionId,
    }).then(r => r.data),

  pollJob: (jobId) =>
    api.get(`/planner/job/${jobId}`, { timeout: 10000 }).then(r => r.data),
}

export default api