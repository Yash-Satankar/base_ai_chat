// src/components/schema/ValidationScore.jsx

import { gradeColor, scoreColor, formatPriority } from '../../utils/formatters'
import Badge from '../ui/Badge'

export default function ValidationScore({ validation }) {
  if (!validation) return null

  const { score, grade, total_issues, issues = [] } = validation
  const passed = score >= 60

  return (
    <div className="w-full rounded-xl border border-slate-700
                    bg-slate-900 overflow-hidden">

      {/* Score header */}
      <div className={`px-4 py-3 border-b border-slate-700
                       ${passed
                         ? 'bg-green-500/5'
                         : 'bg-red-500/5'}`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="text-center">
              <div className={`text-2xl font-bold ${scoreColor(score)}`}>
                {score}
              </div>
              <div className="text-xs text-slate-500">/ 100</div>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className={`text-lg font-bold ${gradeColor(grade)}`}>
                  Grade {grade}
                </span>
                <Badge variant={passed ? 'success' : 'critical'}>
                  {passed ? '✓ PASSED' : '✗ FAILED'}
                </Badge>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                {total_issues} issue{total_issues !== 1 ? 's' : ''} found
              </p>
            </div>
          </div>

          {/* Score bar */}
          <div className="w-24">
            <div className="h-2 bg-slate-700 rounded-full overflow-hidden">
              <div
                className={`h-full rounded-full transition-all duration-500
                             ${score >= 90 ? 'bg-green-500'
                               : score >= 80 ? 'bg-blue-500'
                               : score >= 70 ? 'bg-yellow-500'
                               : score >= 60 ? 'bg-orange-500'
                               : 'bg-red-500'}`}
                style={{ width: `${score}%` }}
              />
            </div>
            <p className="text-xs text-slate-500 mt-1 text-right">
              {score}%
            </p>
          </div>
        </div>
      </div>

      {/* Issues list */}
      {issues.length > 0 && (
        <div className="px-4 py-3 space-y-2">
          <p className="text-xs font-medium text-slate-400 uppercase tracking-wide">
            Issues to fix
          </p>
          {issues.map((issue, i) => (
            <IssueRow key={i} issue={issue} />
          ))}
        </div>
      )}

      {/* No issues */}
      {issues.length === 0 && (
        <div className="px-4 py-3 text-center">
          <p className="text-xs text-green-400">
            ✓ No issues found — schema follows all production rules
          </p>
        </div>
      )}
    </div>
  )
}


function IssueRow({ issue }) {
  const severityVariant = {
    critical: 'critical',
    high:     'high',
    medium:   'medium',
    low:      'low',
  }[issue.severity] || 'default'

  return (
    <div className="flex items-start gap-2 text-xs">
      <Badge variant={severityVariant} className="shrink-0 mt-0.5">
        {issue.severity}
      </Badge>
      <div>
        <p className="text-slate-300">{issue.issue}</p>
        <p className="text-slate-500 mt-0.5">→ {issue.suggestion}</p>
      </div>
    </div>
  )
}