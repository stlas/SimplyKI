// SimplyKI Web UI - Recent Sessions Component
// Erstellt: 2025-07-24 16:06:00 CEST

import React from 'react'
import { Clock, Brain, DollarSign } from 'lucide-react'
import { formatCost, formatDuration, getModelIcon } from '@/lib/utils'

const recentSessions = [
  {
    id: 1,
    name: 'CSV2Actual Migration',
    model: 'claude-3.5-sonnet',
    duration: 324000, // 5.4 minutes
    cost: 0.45,
    status: 'completed',
    time: 'vor 2 Stunden',
  },
  {
    id: 2,
    name: 'BrainMemory Optimization',
    model: 'claude-4-opus',
    duration: 892000, // 14.8 minutes
    cost: 2.10,
    status: 'active',
    time: 'vor 30 Minuten',
  },
  {
    id: 3,
    name: 'Documentation Update',
    model: 'claude-3.5-haiku',
    duration: 120000, // 2 minutes
    cost: 0.08,
    status: 'completed',
    time: 'vor 1 Stunde',
  },
]

export default function RecentSessions() {
  return (
    <div className="space-y-3">
      {recentSessions.map((session) => (
        <div
          key={session.id}
          className="flex items-center justify-between p-4 rounded-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
        >
          <div className="flex items-center gap-3">
            <div className="text-2xl">{getModelIcon(session.model)}</div>
            <div>
              <h4 className="font-medium text-gray-900 dark:text-white">
                {session.name}
              </h4>
              <div className="flex items-center gap-4 mt-1 text-sm text-gray-500 dark:text-gray-400">
                <span className="flex items-center gap-1">
                  <Clock className="h-3 w-3" />
                  {formatDuration(session.duration)}
                </span>
                <span className="flex items-center gap-1">
                  <DollarSign className="h-3 w-3" />
                  {formatCost(session.cost)}
                </span>
                <span>{session.time}</span>
              </div>
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            {session.status === 'active' && (
              <span className="flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-2 w-2 rounded-full bg-green-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
              </span>
            )}
            <span className={`px-2 py-1 text-xs font-medium rounded-full ${
              session.status === 'active' 
                ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
                : 'bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-400'
            }`}>
              {session.status === 'active' ? 'Aktiv' : 'Abgeschlossen'}
            </span>
          </div>
        </div>
      ))}
    </div>
  )
}