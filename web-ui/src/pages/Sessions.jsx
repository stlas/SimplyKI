// SimplyKI Web UI - Sessions Page
// Erstellt: 2025-07-24 16:09:00 CEST

import React, { useState } from 'react'
import { Play, Save, Upload, Clock, DollarSign, FileJson, Trash2 } from 'lucide-react'
import { formatCost, formatDuration, getModelIcon } from '@/lib/utils'

const sessions = [
  {
    id: 'csv2actual-migration',
    name: 'CSV2Actual Migration',
    project: 'CSV2Actual',
    created: '2025-07-23T10:30:00',
    lastActive: '2025-07-24T14:45:00',
    duration: 18540000, // 5.15 hours
    totalCost: 12.45,
    model: 'claude-3.5-sonnet',
    status: 'active',
    parameters: {
      max_tokens: 4096,
      temperature: 0.7,
      task_type: 'feature_development',
    }
  },
  {
    id: 'brainmemory-poc',
    name: 'BrainMemory PoC',
    project: 'SimplyKI',
    created: '2025-07-24T08:00:00',
    lastActive: '2025-07-24T15:30:00',
    duration: 27000000, // 7.5 hours
    totalCost: 23.80,
    model: 'claude-4-opus',
    status: 'paused',
    parameters: {
      max_tokens: 8192,
      temperature: 0.5,
      task_type: 'architecture',
    }
  },
  {
    id: 'docs-update-v2',
    name: 'Documentation Update v2',
    project: 'SimplyKI',
    created: '2025-07-22T14:00:00',
    lastActive: '2025-07-22T16:30:00',
    duration: 9000000, // 2.5 hours
    totalCost: 3.20,
    model: 'claude-3.5-haiku',
    status: 'completed',
    parameters: {
      max_tokens: 2048,
      temperature: 0.3,
      task_type: 'documentation',
    }
  },
]

export default function Sessions() {
  const [selectedSession, setSelectedSession] = useState(null)

  const handleRestore = (session) => {
    console.log('Restoring session:', session.id)
    // Implementation would restore the session
  }

  const handleSnapshot = (session) => {
    console.log('Creating snapshot for:', session.id)
    // Implementation would create a snapshot
  }

  const handleDelete = (session) => {
    if (confirm(`Session "${session.name}" wirklich löschen?`)) {
      console.log('Deleting session:', session.id)
      // Implementation would delete the session
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Sessions
        </h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">
          Verwalten Sie Ihre Entwicklungs-Sessions mit persistenter Parameter-Speicherung
        </p>
      </div>

      {/* Sessions Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
        {sessions.map((session) => (
          <div
            key={session.id}
            className="bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-lg transition-shadow"
          >
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                    {session.name}
                  </h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    {session.project}
                  </p>
                </div>
                <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                  session.status === 'active' 
                    ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
                    : session.status === 'paused'
                    ? 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400'
                    : 'bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-400'
                }`}>
                  {session.status === 'active' ? 'Aktiv' : 
                   session.status === 'paused' ? 'Pausiert' : 'Abgeschlossen'}
                </span>
              </div>

              <div className="space-y-3 mb-4">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-600 dark:text-gray-400">Modell</span>
                  <span className="flex items-center gap-1">
                    <span className="text-lg">{getModelIcon(session.model)}</span>
                    {session.model}
                  </span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-600 dark:text-gray-400">Dauer</span>
                  <span className="flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    {formatDuration(session.duration)}
                  </span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-600 dark:text-gray-400">Kosten</span>
                  <span className="flex items-center gap-1">
                    <DollarSign className="h-3 w-3" />
                    {formatCost(session.totalCost)}
                  </span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-600 dark:text-gray-400">Zuletzt aktiv</span>
                  <span>{new Date(session.lastActive).toLocaleDateString('de-DE')}</span>
                </div>
              </div>

              <div className="flex items-center gap-2">
                {session.status !== 'completed' && (
                  <button
                    onClick={() => handleRestore(session)}
                    className="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-brain-500 text-white rounded-lg hover:bg-brain-600 text-sm font-medium"
                  >
                    <Play className="h-3 w-3" />
                    Fortsetzen
                  </button>
                )}
                <button
                  onClick={() => handleSnapshot(session)}
                  className="flex items-center justify-center gap-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 text-sm font-medium"
                >
                  <Save className="h-3 w-3" />
                  Snapshot
                </button>
                <button
                  onClick={() => setSelectedSession(session)}
                  className="p-2 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700"
                >
                  <FileJson className="h-4 w-4" />
                </button>
                <button
                  onClick={() => handleDelete(session)}
                  className="p-2 border border-red-300 dark:border-red-800 text-red-600 dark:text-red-400 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Session Details Modal */}
      {selectedSession && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
                  Session Details: {selectedSession.name}
                </h3>
                <button
                  onClick={() => setSelectedSession(null)}
                  className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
                >
                  ✕
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <h4 className="font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Basis-Informationen
                  </h4>
                  <pre className="bg-gray-100 dark:bg-gray-900 p-4 rounded-lg overflow-x-auto text-sm">
{JSON.stringify({
  id: selectedSession.id,
  name: selectedSession.name,
  project: selectedSession.project,
  created: selectedSession.created,
  lastActive: selectedSession.lastActive,
  status: selectedSession.status,
}, null, 2)}
                  </pre>
                </div>

                <div>
                  <h4 className="font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Parameter
                  </h4>
                  <pre className="bg-gray-100 dark:bg-gray-900 p-4 rounded-lg overflow-x-auto text-sm">
{JSON.stringify(selectedSession.parameters, null, 2)}
                  </pre>
                </div>

                <div>
                  <h4 className="font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Statistiken
                  </h4>
                  <pre className="bg-gray-100 dark:bg-gray-900 p-4 rounded-lg overflow-x-auto text-sm">
{JSON.stringify({
  duration: formatDuration(selectedSession.duration),
  totalCost: formatCost(selectedSession.totalCost),
  model: selectedSession.model,
}, null, 2)}
                  </pre>
                </div>
              </div>

              <div className="mt-6 flex items-center gap-3">
                <button
                  onClick={() => {
                    navigator.clipboard.writeText(JSON.stringify(selectedSession, null, 2))
                    alert('Session-Daten in Zwischenablage kopiert!')
                  }}
                  className="px-4 py-2 bg-brain-500 text-white rounded-lg hover:bg-brain-600 font-medium"
                >
                  In Zwischenablage kopieren
                </button>
                <button
                  onClick={() => setSelectedSession(null)}
                  className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 font-medium"
                >
                  Schließen
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}