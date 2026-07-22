// src/components/schema/ValidationScore.jsx

import React from 'react'
import { gradeColor, scoreColor } from '../../utils/formatters'
import Badge from '../ui/Badge'

export default function ValidationScore({ validation }) {
  if (!validation) return null

  const { score, grade, total_issues, issues = [] } = validation
  const passed = score >= 60

  return (
    <div className="w-full rounded-2xl border border-slate-800 bg-[#090d16] overflow-hidden glass-panel shadow-lg">
      {/* Score Header */}
      <div className={`px-4.5 py-3.5 border-b border-slate-800/80 ${passed ? 'bg-emerald-500/5' : 'bg-rose-500/5'}`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3.5">
            <div className="text-center">
              <div className={`text-3xl font-extrabold tracking-tight ${scoreColor(score)}`}>
                {score}
              </div>
              <div className="text-[10px] text-slate-500 font-semibold uppercase">/ 100 Score</div>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className={`text-lg font-extrabold ${gradeColor(grade)}`}>
                  Grade {grade}
                </span>
                <Badge variant={passed ? 'success' : 'critical'}>
                  {passed ? '✓ PASSED' : 'Action Required'}
                </Badge>
              </div>
              <p className="text-xs text-slate-400 mt-0.5 font-medium">
                {total_issues} compliance issue{total_issues !== 1 ? 's' : ''} evaluated
              </p>
            </div>
          </div>

          {/* Animated score bar */}
          <div className="w-28 hidden sm:block">
            <div className="h-2 bg-slate-800 rounded-full overflow-hidden border border-slate-700/60">
              <div
                className={`h-full rounded-full transition-all duration-700 ${
                  score >= 90
                    ? 'bg-emerald-500'
                    : score >= 80
                    ? 'bg-indigo-500'
                    : score >= 70
                    ? 'bg-amber-500'
                    : 'bg-rose-500'
                }`}
                style={{ width: `${score}%` }}
              />
            </div>
            <p className="text-[11px] font-semibold text-slate-400 mt-1 text-right">
              {score}% Rating
            </p>
          </div>
        </div>
      </div>

      {/* Issues list */}
      {issues.length > 0 && (
        <div className="px-4.5 py-3.5 space-y-2.5">
          <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
            Rules Assessment Breakdown
          </p>
          {issues.map((issue, i) => (
            <IssueRow key={i} issue={issue} />
          ))}
        </div>
      )}

      {/* Zero issues */}
      {issues.length === 0 && (
        <div className="px-4.5 py-3.5 text-center bg-emerald-500/5 border-t border-emerald-500/10">
          <p className="text-xs font-semibold text-emerald-400">
            ✓ Excellent — Schema complies with 100% of architectural rules!
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
    <div className="flex items-start gap-2.5 text-xs p-2 rounded-xl bg-slate-900/60 border border-slate-800/80">
      <Badge variant={severityVariant} className="shrink-0 mt-0.5">
        {issue.severity}
      </Badge>
      <div className="space-y-0.5">
        <p className="text-slate-200 font-medium">{issue.issue}</p>
        <p className="text-slate-400 text-[11px] leading-relaxed">💡 Fix: {issue.suggestion}</p>
      </div>
    </div>
  )
}