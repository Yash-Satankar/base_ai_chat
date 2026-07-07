// src/components/schema/DownloadButtons.jsx

import { conversationApi } from '../../api/client'

export default function DownloadButtons({ sessionId }) {
  if (!sessionId) return null

  const handleDownload = (type) => {
    const url = type === 'sql'
      ? conversationApi.downloadSql(sessionId)
      : conversationApi.downloadPdf(sessionId)

    // Open in new tab — browser handles download
    window.open(url, '_blank')
  }

  return (
    <div className="flex flex-col gap-2 w-full">
      <p className="text-xs text-slate-400 font-medium">
        Your files are ready:
      </p>

      <div className="flex gap-2">
        <DownloadBtn
          onClick={() => handleDownload('sql')}
          icon="📄"
          label="Download SQL"
          sublabel="Run directly in MySQL"
          color="blue"
        />
        <DownloadBtn
          onClick={() => handleDownload('pdf')}
          icon="📋"
          label="Download PDF"
          sublabel="Complete documentation"
          color="purple"
        />
      </div>
    </div>
  )
}


function DownloadBtn({ onClick, icon, label, sublabel, color }) {
  const colors = {
    blue:   'border-blue-500/40 hover:bg-blue-500/10 hover:border-blue-500/60',
    purple: 'border-purple-500/40 hover:bg-purple-500/10 hover:border-purple-500/60',
  }

  return (
    <button
      onClick={onClick}
      className={`flex-1 flex items-center gap-3 px-3 py-2.5
                  rounded-lg border bg-slate-900/50
                  transition-all duration-200 text-left group
                  ${colors[color]}`}
    >
      <span className="text-xl">{icon}</span>
      <div>
        <p className="text-xs font-medium text-slate-200
                      group-hover:text-white transition-colors">
          {label}
        </p>
        <p className="text-xs text-slate-500">{sublabel}</p>
      </div>
    </button>
  )
}