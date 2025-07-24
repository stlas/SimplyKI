// SimplyKI Web UI - Stats Card Component
// Erstellt: 2025-07-24 16:04:00 CEST

import React from 'react'
import { TrendingUp, TrendingDown } from 'lucide-react'
import { cn } from '@/lib/utils'

export default function StatsCard({ title, value, icon: Icon, trend, color }) {
  const isPositiveTrend = trend && trend.startsWith('+')
  
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
            {title}
          </p>
          <p className="mt-2 text-3xl font-bold text-gray-900 dark:text-white">
            {value}
          </p>
          {trend && (
            <div className="mt-2 flex items-center gap-1">
              {isPositiveTrend ? (
                <TrendingUp className="h-4 w-4 text-green-500" />
              ) : (
                <TrendingDown className="h-4 w-4 text-red-500" />
              )}
              <span className={cn(
                "text-sm font-medium",
                isPositiveTrend ? "text-green-600" : "text-red-600"
              )}>
                {trend}
              </span>
            </div>
          )}
        </div>
        <div className={cn("p-3 rounded-full bg-gray-100 dark:bg-gray-700", color)}>
          <Icon className="h-6 w-6" />
        </div>
      </div>
    </div>
  )
}