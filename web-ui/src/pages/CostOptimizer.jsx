// SimplyKI Web UI - Cost Optimizer Page
// Erstellt: 2025-07-24 16:08:00 CEST

import React, { useState } from 'react'
import { DollarSign, TrendingDown, Calculator, BarChart3 } from 'lucide-react'
import { formatCost, getModelIcon, getCostLevel } from '@/lib/utils'
import { cn } from '@/lib/utils'

const models = [
  { id: 'claude-3.5-haiku', name: 'Claude 3.5 Haiku', costPer1k: 0.001, speed: 'Sehr schnell', quality: 'Gut' },
  { id: 'claude-3.5-sonnet', name: 'Claude 3.5 Sonnet', costPer1k: 0.003, speed: 'Schnell', quality: 'Sehr gut' },
  { id: 'claude-4-opus', name: 'Claude 4 Opus', costPer1k: 0.015, speed: 'Mittel', quality: 'Exzellent' },
  { id: 'gpt-3.5-turbo', name: 'GPT-3.5 Turbo', costPer1k: 0.0005, speed: 'Sehr schnell', quality: 'Gut' },
  { id: 'gpt-4', name: 'GPT-4', costPer1k: 0.01, speed: 'Langsam', quality: 'Exzellent' },
]

const taskTypes = [
  { id: 'simple_fix', name: 'Einfache Korrekturen', complexity: 1 },
  { id: 'documentation', name: 'Dokumentation', complexity: 1 },
  { id: 'code_review', name: 'Code Review', complexity: 2 },
  { id: 'feature_development', name: 'Feature Entwicklung', complexity: 3 },
  { id: 'architecture', name: 'Architektur Design', complexity: 4 },
  { id: 'complex_refactoring', name: 'Komplexe Refaktorierung', complexity: 4 },
]

export default function CostOptimizer() {
  const [selectedTask, setSelectedTask] = useState('feature_development')
  const [estimatedTokens, setEstimatedTokens] = useState(5000)
  const [budget, setBudget] = useState(10)

  const currentTask = taskTypes.find(t => t.id === selectedTask)
  
  const recommendations = models.map(model => {
    const cost = (estimatedTokens / 1000) * model.costPer1k
    const withinBudget = cost <= budget
    const complexityMatch = 
      (currentTask.complexity <= 2 && model.costPer1k <= 0.001) ||
      (currentTask.complexity === 3 && model.costPer1k <= 0.003) ||
      (currentTask.complexity >= 4 && model.quality === 'Exzellent')
    
    return {
      ...model,
      cost,
      withinBudget,
      recommended: withinBudget && complexityMatch,
    }
  }).sort((a, b) => {
    if (a.recommended && !b.recommended) return -1
    if (!a.recommended && b.recommended) return 1
    return a.cost - b.cost
  })

  const bestModel = recommendations.find(r => r.recommended) || recommendations[0]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Kostenoptimierung
        </h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">
          Intelligente Modellauswahl für minimale Kosten bei maximaler Qualität
        </p>
      </div>

      {/* Configuration */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Aufgabentyp
          </label>
          <select
            value={selectedTask}
            onChange={(e) => setSelectedTask(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
            {taskTypes.map(task => (
              <option key={task.id} value={task.id}>
                {task.name} (Komplexität: {task.complexity}/4)
              </option>
            ))}
          </select>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Geschätzte Tokens
          </label>
          <input
            type="number"
            value={estimatedTokens}
            onChange={(e) => setEstimatedTokens(parseInt(e.target.value) || 0)}
            className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          />
          <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
            Durchschnitt: ~1000 Tokens pro Anfrage
          </p>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Budget (EUR)
          </label>
          <input
            type="number"
            value={budget}
            onChange={(e) => setBudget(parseFloat(e.target.value) || 0)}
            step="0.5"
            className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          />
        </div>
      </div>

      {/* Best Recommendation */}
      <div className="bg-gradient-to-r from-green-500 to-emerald-500 rounded-lg shadow-lg p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-xl font-semibold mb-2">Empfohlenes Modell</h3>
            <div className="flex items-center gap-3">
              <span className="text-3xl">{getModelIcon(bestModel.id)}</span>
              <div>
                <p className="text-2xl font-bold">{bestModel.name}</p>
                <p className="text-green-100">
                  Geschätzte Kosten: {formatCost(bestModel.cost)} | 
                  {' '}Ersparnis: {formatCost(recommendations[recommendations.length - 1].cost - bestModel.cost)}
                </p>
              </div>
            </div>
          </div>
          <TrendingDown className="h-12 w-12 text-green-200" />
        </div>
      </div>

      {/* Model Comparison */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">
          Modellvergleich
        </h3>
        <div className="space-y-3">
          {recommendations.map((model) => (
            <div
              key={model.id}
              className={cn(
                "p-4 rounded-lg border-2 transition-all",
                model.recommended
                  ? "border-green-500 bg-green-50 dark:bg-green-900/20"
                  : model.withinBudget
                  ? "border-gray-300 dark:border-gray-600"
                  : "border-red-300 dark:border-red-800 opacity-60"
              )}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{getModelIcon(model.id)}</span>
                  <div>
                    <h4 className="font-medium text-gray-900 dark:text-white">
                      {model.name}
                    </h4>
                    <div className="flex items-center gap-4 mt-1 text-sm text-gray-600 dark:text-gray-400">
                      <span>Geschwindigkeit: {model.speed}</span>
                      <span>Qualität: {model.quality}</span>
                      <span>€{model.costPer1k}/1k Tokens</span>
                    </div>
                  </div>
                </div>
                
                <div className="text-right">
                  <p className={cn(
                    "text-lg font-bold",
                    getCostLevel(model.cost) === 'low' && "text-green-600",
                    getCostLevel(model.cost) === 'medium' && "text-amber-600",
                    getCostLevel(model.cost) === 'high' && "text-red-600"
                  )}>
                    {formatCost(model.cost)}
                  </p>
                  {model.recommended && (
                    <span className="inline-flex items-center gap-1 px-2 py-1 mt-1 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 text-xs font-medium rounded-full">
                      <Calculator className="h-3 w-3" />
                      Optimal
                    </span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Cost Savings Tips */}
      <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-6">
        <h3 className="text-lg font-semibold mb-3 text-blue-900 dark:text-blue-300">
          💡 Kostenspartipps
        </h3>
        <ul className="space-y-2 text-blue-800 dark:text-blue-200">
          <li>• Verwenden Sie Templates für wiederkehrende Aufgaben (60-70% Ersparnis)</li>
          <li>• Nutzen Sie günstigere Modelle für einfache Aufgaben</li>
          <li>• Batch-Verarbeitung für ähnliche Anfragen</li>
          <li>• Aktivieren Sie Budget-Limits für automatische Kostenkontrolle</li>
        </ul>
      </div>
    </div>
  )
}