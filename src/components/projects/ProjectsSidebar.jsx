/* src/components/projects/ProjectsSidebar.jsx
   Persistent project history sidebar.
   Shows when logged in; collapses on mobile.
   ─────────────────────────────────────────── */

import { useState, useEffect, useCallback } from 'react'
import { projectsApi } from '../../api/client'
import { useAuth } from '../../context/AuthContext'
import './ProjectsSidebar.css'

export default function ProjectsSidebar({ currentSessionId, onSelectProject, onNewChat }) {
  const { user, isAuthenticated } = useAuth()
  const [projects, setProjects] = useState([])
  const [loading, setLoading] = useState(false)
  const [expanded, setExpanded] = useState({})
  const [error, setError] = useState(null)

  const fetchProjects = useCallback(async () => {
    if (!isAuthenticated) return
    setLoading(true)
    setError(null)
    try {
      const data = await projectsApi.list()
      setProjects(data)
    } catch (err) {
      setError('Failed to load projects')
    } finally {
      setLoading(false)
    }
  }, [isAuthenticated])

  useEffect(() => {
    fetchProjects()
  }, [fetchProjects])

  const toggleExpanded = (id) => {
    setExpanded(prev => ({ ...prev, [id]: !prev[id] }))
  }

  const gradeColor = (score) => {
    if (!score) return '#6b7280'
    if (score >= 90) return '#10b981'
    if (score >= 75) return '#6366f1'
    if (score >= 60) return '#f59e0b'
    return '#ef4444'
  }

  if (!isAuthenticated) {
    return (
      <aside className="projects-sidebar projects-sidebar--guest">
        <div className="projects-sidebar__guest-msg">
          <div className="projects-sidebar__guest-icon">🔒</div>
          <p>Sign in to save your projects and access schema history</p>
        </div>
      </aside>
    )
  }

  return (
    <aside className="projects-sidebar">
      {/* Header */}
      <div className="projects-sidebar__header">
        <div className="projects-sidebar__title-row">
          <span className="projects-sidebar__title">Projects</span>
          <span className="projects-sidebar__count">{projects.length}</span>
        </div>
        <button
          className="projects-sidebar__new-btn"
          onClick={onNewChat}
          title="New database design"
        >
          + New
        </button>
      </div>

      {/* Loading */}
      {loading && (
        <div className="projects-sidebar__loading">
          <div className="projects-sidebar__spinner" />
          <span>Loading projects…</span>
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="projects-sidebar__error">
          {error}
          <button onClick={fetchProjects}>Retry</button>
        </div>
      )}

      {/* Empty state */}
      {!loading && !error && projects.length === 0 && (
        <div className="projects-sidebar__empty">
          <div className="projects-sidebar__empty-icon">📐</div>
          <p>No projects yet.</p>
          <p>Start a new conversation to create one.</p>
        </div>
      )}

      {/* Project list */}
      <ul className="projects-sidebar__list">
        {projects.map(project => (
          <li
            key={project.id}
            className="projects-sidebar__item"
          >
            {/* Project row */}
            <div
              className="projects-sidebar__project"
              onClick={() => toggleExpanded(project.id)}
            >
              <div className="projects-sidebar__project-icon">
                {project.domain
                  ? domainIcon(project.domain)
                  : '📦'}
              </div>
              <div className="projects-sidebar__project-info">
                <div className="projects-sidebar__project-name">
                  {project.name}
                </div>
                <div className="projects-sidebar__project-meta">
                  <span>{project.version_count} version{project.version_count !== 1 ? 's' : ''}</span>
                  {project.latest_score != null && (
                    <span
                      className="projects-sidebar__score"
                      style={{ color: gradeColor(project.latest_score) }}
                    >
                      {project.latest_score}/100
                    </span>
                  )}
                </div>
              </div>
              <span className="projects-sidebar__chevron">
                {expanded[project.id] ? '▾' : '›'}
              </span>
            </div>

            {/* Expanded version history */}
            {expanded[project.id] && project.versions?.length > 0 && (
              <ul className="projects-sidebar__versions">
                {project.versions.map(v => (
                  <li
                    key={v.id}
                    className="projects-sidebar__version"
                    onClick={() => onSelectProject(project.id, v.version_number)}
                  >
                    <span className={`projects-sidebar__version-badge projects-sidebar__version-badge--${v.status}`}>
                      v{v.version_number}
                    </span>
                    <span className="projects-sidebar__version-info">
                      {v.tables_count ? `${v.tables_count} tables` : v.status}
                      {v.validation_score != null && (
                        <span style={{ color: gradeColor(v.validation_score) }}>
                          {' '}· {v.validation_score}/100
                        </span>
                      )}
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </li>
        ))}
      </ul>
    </aside>
  )
}

function domainIcon(domain) {
  const d = (domain || '').toLowerCase()
  if (d.includes('hospital') || d.includes('health') || d.includes('medical')) return '🏥'
  if (d.includes('finance') || d.includes('bank')) return '🏦'
  if (d.includes('school') || d.includes('education')) return '🏫'
  if (d.includes('logistics') || d.includes('delivery')) return '🚚'
  if (d.includes('ecommerce') || d.includes('shop')) return '🛒'
  if (d.includes('hotel') || d.includes('travel')) return '✈️'
  if (d.includes('restaurant') || d.includes('food')) return '🍽️'
  return '🗄️'
}
