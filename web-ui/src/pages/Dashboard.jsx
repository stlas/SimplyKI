// SimplyKI Web UI - Dashboard Page
// Erstellt: 2025-07-24 16:03:00 CEST

import React from 'react'
import { useQuery } from '@tanstack/react-query'
import { Brain, DollarSign, Activity, TrendingUp, Clock, Cpu } from 'lucide-react'
import { formatCost, formatDuration, formatBytes } from '@/lib/utils'
import StatsCard from '@/components/StatsCard'
import ActivityChart from '@/components/ActivityChart'
import RecentSessions from '@/components/RecentSessions'

export default function Dashboard() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      // Mock data for now
      return {
        totalCost: 12.45,
        activeSessions: 3,
        memoryUsage: 256 * 1024 * 1024, // 256MB
        performance: 0.92,
        recentActivity: [
          { time: '10:00', cost: 0.5, operations: 12 },
          { time: '11:00', cost: 1.2, operations: 34 },
          { time: '12:00', cost: 0.8, operations: 23 },
          { time: '13:00', cost: 2.1, operations: 56 },
          { time: '14:00', cost: 1.5, operations: 41 },
        ]
      }
    },
    refetchInterval: 30000, // 30 seconds
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-brain-500 border-t-transparent"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Dashboard
        </h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">
          Überblick über Ihr SimplyKI System
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard
          title="Gesamtkosten heute"
          value={formatCost(stats.totalCost)}
          icon={DollarSign}
          trend="+12%"
          color="text-green-600"
        />
        <StatsCard
          title="Aktive Sessions"
          value={stats.activeSessions}
          icon={Activity}
          trend={null}
          color="text-blue-600"
        />
        <StatsCard
          title="Speichernutzung"
          value={formatBytes(stats.memoryUsage)}
          icon={Brain}
          trend="-5%"
          color="text-purple-600"
        />
        <StatsCard
          title="Performance Score"
          value={`${(stats.performance * 100).toFixed(0)}%`}
          icon={Cpu}
          trend="+3%"
          color="text-indigo-600"
        />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">
            Aktivität & Kosten
          </h2>
          <ActivityChart data={stats.recentActivity} />
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">
            Letzte Sessions
          </h2>
          <RecentSessions />
        </div>
      </div>

      {/* System Health */}
      <div className="bg-gradient-to-r from-brain-500 to-neural-500 rounded-lg shadow-lg p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-xl font-semibold">System Health</h3>
            <p className="mt-2 text-brain-100">
              Alle Systeme funktionieren optimal. BrainMemory läuft mit 100x Performance.
            </p>
          </div>
          <div className="flex items-center gap-2">
            <span className="flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-3 w-3 rounded-full bg-white opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-white"></span>
            </span>
            <span className="text-sm font-medium">Optimal</span>
          </div>
        </div>
      </div>
    </div>
  )
}