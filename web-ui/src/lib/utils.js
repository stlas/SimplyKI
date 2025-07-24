// SimplyKI Web UI - Utility Functions
// Erstellt: 2025-07-24 16:02:00 CEST

import { clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs) {
  return twMerge(clsx(inputs))
}

export function formatCost(amount) {
  return new Intl.NumberFormat('de-DE', {
    style: 'currency',
    currency: 'EUR',
  }).format(amount)
}

export function formatBytes(bytes, decimals = 2) {
  if (bytes === 0) return '0 Bytes'

  const k = 1024
  const dm = decimals < 0 ? 0 : decimals
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB']

  const i = Math.floor(Math.log(bytes) / Math.log(k))

  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
}

export function formatDuration(ms) {
  if (ms < 1000) return `${ms}ms`
  if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`
  if (ms < 3600000) return `${Math.floor(ms / 60000)}m ${Math.floor((ms % 60000) / 1000)}s`
  return `${Math.floor(ms / 3600000)}h ${Math.floor((ms % 3600000) / 60000)}m`
}

export function getCostLevel(cost) {
  if (cost < 0.01) return 'low'
  if (cost < 0.1) return 'medium'
  return 'high'
}

export function getModelIcon(model) {
  const icons = {
    'claude-3-haiku': '⚡',
    'claude-3.5-haiku': '⚡',
    'claude-3-sonnet': '🎵',
    'claude-3.5-sonnet': '🎵',
    'claude-4-opus': '🎭',
    'gpt-3.5-turbo': '💬',
    'gpt-4': '🧠',
    'gpt-4-turbo': '🚀',
  }
  return icons[model] || '🤖'
}

export function truncate(str, length = 50) {
  if (str.length <= length) return str
  return str.substring(0, length) + '...'
}