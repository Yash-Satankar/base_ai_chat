// src/components/schema/ValidationScore.jsx
import React from 'react'
import { gradeColor, scoreColor, scoreBar } from '../../utils/formatters'
import Badge from '../ui/Badge'
import Icon from '../ui/Icon'

export default function ValidationScore({ validation }) {
  if (!validation) return null

  const { score, grade, total_issues, issues } = validation
  const passed = validation.passed ?? score >= 60
  const hasBreakdown = Array.isArray(issues)
  const list = hasBreakdown ? issues : []
  const count = total_issues ?? list.length

  return (
    <div className="w-full overflow-hidden rounded-xl border border-line bg-bg-raised shadow-inset-hl">
      <div className="border-b border-line px-4 py-3.5">
        <div className="flex items-center gap-4">
          <div className="text-center">
            <div className={`text-[26px] font-semibold leading-none tracking-tight tabular-nums ${scoreColor(score)}`}>
              {score}
            </div>
            <div className="mt-0.5 text-[10px] font-medium uppercase tracking-wide text-ink-faint">/ 100</div>
          </div>
          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-2">
              {grade && <span className={`text-[15px] font-semibold ${gradeColor(grade)}`}>Grade {grade}</span>}
              <Badge variant={passed ? 'success' : 'critical'}>{passed ? 'Passed' : 'Action needed'}</Badge>
            </div>
            <p className="mt-1 text-[12px] text-ink-dim">
              {hasBreakdown ? `${count} compliance check${count !== 1 ? 's' : ''} evaluated` : 'Headline quality score'}
            </p>
            <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-white/[0.06]">
              <div className={`h-full rounded-full transition-[width] duration-700 ${scoreBar(score)}`} style={{ width: `${score}%` }} />
            </div>
          </div>
        </div>
      </div>

      {hasBreakdown && list.length > 0 && (
        <div className="space-y-2 px-4 py-3.5">
          <p className="label">Findings</p>
          {list.map((issue, i) => (
            <div key={i} className="flex items-start gap-2.5 rounded-lg border border-line bg-white/[0.02] p-2.5 text-[12px]">
              <Badge variant={issue.severity || 'medium'} className="mt-0.5 shrink-0 capitalize">{issue.severity}</Badge>
              <div className="min-w-0 space-y-0.5">
                <p className="text-ink">{issue.issue}</p>
                <p className="text-[11.5px] leading-relaxed text-ink-dim">Fix — {issue.suggestion}</p>
              </div>
            </div>
          ))}
        </div>
      )}

      {hasBreakdown && list.length === 0 && (
        <div className="flex items-center justify-center gap-2 border-t border-ok-line bg-ok-bg py-2.5 text-[12px] font-medium text-ok">
          <Icon name="circle-check" className="size-3.5" />
          Complies with every architectural rule
        </div>
      )}
    </div>
  )
}
