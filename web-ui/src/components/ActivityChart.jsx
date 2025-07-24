// SimplyKI Web UI - Activity Chart Component
// Erstellt: 2025-07-24 16:05:00 CEST

import React from 'react'

export default function ActivityChart({ data }) {
  const maxCost = Math.max(...data.map(d => d.cost))
  const maxOps = Math.max(...data.map(d => d.operations))

  return (
    <div className="h-64 relative">
      <div className="absolute inset-0 flex items-end justify-between gap-2">
        {data.map((item, index) => (
          <div key={index} className="flex-1 flex flex-col items-center gap-2">
            {/* Operations bar */}
            <div className="w-full flex flex-col items-center">
              <span className="text-xs text-gray-500 dark:text-gray-400 mb-1">
                {item.operations}
              </span>
              <div 
                className="w-full bg-neural-400 rounded-t"
                style={{ height: `${(item.operations / maxOps) * 150}px` }}
              />
            </div>
            
            {/* Cost indicator */}
            <div 
              className="w-full bg-brain-500 rounded"
              style={{ height: `${(item.cost / maxCost) * 50}px` }}
            />
            
            {/* Time label */}
            <span className="text-xs text-gray-600 dark:text-gray-400">
              {item.time}
            </span>
          </div>
        ))}
      </div>
      
      {/* Legend */}
      <div className="absolute top-0 right-0 flex items-center gap-4 text-sm">
        <div className="flex items-center gap-1">
          <div className="w-3 h-3 bg-neural-400 rounded" />
          <span className="text-gray-600 dark:text-gray-400">Operationen</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-3 h-3 bg-brain-500 rounded" />
          <span className="text-gray-600 dark:text-gray-400">Kosten</span>
        </div>
      </div>
    </div>
  )
}