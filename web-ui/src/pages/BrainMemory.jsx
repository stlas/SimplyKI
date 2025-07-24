// SimplyKI Web UI - BrainMemory Page
// Erstellt: 2025-07-24 16:07:00 CEST

import React, { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Brain, Zap, Database, Network, RefreshCw, Play, Pause } from 'lucide-react'
import { formatBytes, formatDuration, cn } from '@/lib/utils'

export default function BrainMemory() {
  const [isRunning, setIsRunning] = useState(true)
  const queryClient = useQueryClient()

  const { data: memoryStats } = useQuery({
    queryKey: ['brain-memory-stats'],
    queryFn: async () => {
      // Mock data - will be replaced with API call
      return {
        workingMemory: {
          used: 45 * 1024 * 1024, // 45MB
          total: 256 * 1024 * 1024, // 256MB
          entries: 1234,
        },
        longTermMemory: {
          used: 890 * 1024 * 1024, // 890MB
          total: 4 * 1024 * 1024 * 1024, // 4GB
          entries: 45678,
        },
        contextCache: {
          hits: 8934,
          misses: 234,
          hitRate: 0.974,
        },
        associations: {
          nodes: 5678,
          edges: 12345,
          avgDegree: 4.3,
        },
        performance: {
          avgLookupTime: 0.23, // ms
          avgStoreTime: 0.45, // ms
          throughput: 4567, // ops/sec
        }
      }
    },
    refetchInterval: isRunning ? 5000 : false,
  })

  const benchmarkMutation = useMutation({
    mutationFn: async () => {
      // Simulate benchmark
      await new Promise(resolve => setTimeout(resolve, 3000))
      return {
        results: {
          shellTime: 234.5,
          rustTime: 2.3,
          improvement: 102.0,
        }
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['brain-memory-stats'])
    },
  })

  if (!memoryStats) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-brain-500 border-t-transparent"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            BrainMemory System
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Gehirn-inspiriertes Speichersystem mit 100x Performance
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => setIsRunning(!isRunning)}
            className={cn(
              "flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors",
              isRunning
                ? "bg-red-100 text-red-700 hover:bg-red-200 dark:bg-red-900/30 dark:text-red-400"
                : "bg-green-100 text-green-700 hover:bg-green-200 dark:bg-green-900/30 dark:text-green-400"
            )}
          >
            {isRunning ? <Pause className="h-4 w-4" /> : <Play className="h-4 w-4" />}
            {isRunning ? 'Pause' : 'Start'}
          </button>
          <button
            onClick={() => benchmarkMutation.mutate()}
            disabled={benchmarkMutation.isPending}
            className="flex items-center gap-2 px-4 py-2 bg-brain-500 text-white rounded-lg hover:bg-brain-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Zap className="h-4 w-4" />
            {benchmarkMutation.isPending ? 'Running...' : 'Benchmark'}
          </button>
        </div>
      </div>

      {/* Memory Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Working Memory */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
              <Brain className="h-5 w-5 text-brain-500" />
              Working Memory
            </h2>
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {memoryStats.workingMemory.entries} Einträge
            </span>
          </div>
          <div className="space-y-3">
            <div>
              <div className="flex justify-between text-sm mb-1">
                <span className="text-gray-600 dark:text-gray-400">Belegt</span>
                <span className="font-medium">
                  {formatBytes(memoryStats.workingMemory.used)} / {formatBytes(memoryStats.workingMemory.total)}
                </span>
              </div>
              <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-3">
                <div 
                  className="bg-brain-500 h-3 rounded-full transition-all duration-500"
                  style={{ width: `${(memoryStats.workingMemory.used / memoryStats.workingMemory.total) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </div>

        {/* Long Term Memory */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
              <Database className="h-5 w-5 text-neural-500" />
              Long Term Memory
            </h2>
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {memoryStats.longTermMemory.entries.toLocaleString()} Einträge
            </span>
          </div>
          <div className="space-y-3">
            <div>
              <div className="flex justify-between text-sm mb-1">
                <span className="text-gray-600 dark:text-gray-400">Belegt</span>
                <span className="font-medium">
                  {formatBytes(memoryStats.longTermMemory.used)} / {formatBytes(memoryStats.longTermMemory.total)}
                </span>
              </div>
              <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-3">
                <div 
                  className="bg-neural-500 h-3 rounded-full transition-all duration-500"
                  style={{ width: `${(memoryStats.longTermMemory.used / memoryStats.longTermMemory.total) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Performance Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Context Cache */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">
            Context Cache
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Hit Rate</span>
              <span className="font-medium text-green-600">
                {(memoryStats.contextCache.hitRate * 100).toFixed(1)}%
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Hits</span>
              <span className="font-medium">{memoryStats.contextCache.hits.toLocaleString()}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Misses</span>
              <span className="font-medium">{memoryStats.contextCache.misses}</span>
            </div>
          </div>
        </div>

        {/* Association Network */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white flex items-center gap-2">
            <Network className="h-5 w-5 text-brain-500" />
            Association Network
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Nodes</span>
              <span className="font-medium">{memoryStats.associations.nodes.toLocaleString()}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Edges</span>
              <span className="font-medium">{memoryStats.associations.edges.toLocaleString()}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Avg Degree</span>
              <span className="font-medium">{memoryStats.associations.avgDegree.toFixed(1)}</span>
            </div>
          </div>
        </div>

        {/* Performance */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white flex items-center gap-2">
            <Zap className="h-5 w-5 text-yellow-500" />
            Performance
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Lookup</span>
              <span className="font-medium">{memoryStats.performance.avgLookupTime.toFixed(2)}ms</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Store</span>
              <span className="font-medium">{memoryStats.performance.avgStoreTime.toFixed(2)}ms</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Throughput</span>
              <span className="font-medium">{memoryStats.performance.throughput.toLocaleString()} ops/s</span>
            </div>
          </div>
        </div>
      </div>

      {/* Benchmark Results */}
      {benchmarkMutation.data && (
        <div className="bg-gradient-to-r from-brain-500 to-neural-500 rounded-lg shadow-lg p-6 text-white">
          <h3 className="text-xl font-semibold mb-4">Benchmark Ergebnisse</h3>
          <div className="grid grid-cols-3 gap-6">
            <div>
              <p className="text-brain-100">Shell Implementation</p>
              <p className="text-2xl font-bold">{benchmarkMutation.data.results.shellTime.toFixed(1)}ms</p>
            </div>
            <div>
              <p className="text-brain-100">Rust Implementation</p>
              <p className="text-2xl font-bold">{benchmarkMutation.data.results.rustTime.toFixed(1)}ms</p>
            </div>
            <div>
              <p className="text-brain-100">Performance Boost</p>
              <p className="text-2xl font-bold">{benchmarkMutation.data.results.improvement.toFixed(0)}x</p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}