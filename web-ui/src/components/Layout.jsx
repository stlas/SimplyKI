// SimplyKI Web UI - Layout Component
// Erstellt: 2025-07-24 16:01:00 CEST

import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Brain, DollarSign, FolderOpen, Settings, Activity, Home } from 'lucide-react'
import { cn } from '@/lib/utils'

const navigation = [
  { name: 'Dashboard', href: '/', icon: Home },
  { name: 'BrainMemory', href: '/brain', icon: Brain },
  { name: 'Kostenoptimierung', href: '/cost', icon: DollarSign },
  { name: 'Sessions', href: '/sessions', icon: Activity },
  { name: 'Projekte', href: '/projects', icon: FolderOpen },
  { name: 'Einstellungen', href: '/settings', icon: Settings },
]

export default function Layout({ children }) {
  const location = useLocation()

  return (
    <div className="flex h-screen bg-gray-50 dark:bg-gray-900">
      {/* Sidebar */}
      <div className="w-64 bg-white dark:bg-gray-800 shadow-lg">
        <div className="flex h-full flex-col">
          {/* Logo */}
          <div className="flex h-16 items-center justify-center border-b dark:border-gray-700">
            <div className="flex items-center gap-2">
              <Brain className="h-8 w-8 text-brain-500" />
              <span className="text-xl font-bold text-gradient from-brain-500 to-neural-500">
                SimplyKI
              </span>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 space-y-1 px-2 py-4">
            {navigation.map((item) => {
              const isActive = location.pathname === item.href
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={cn(
                    'group flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                    isActive
                      ? 'bg-brain-100 text-brain-900 dark:bg-brain-900/20 dark:text-brain-300'
                      : 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700'
                  )}
                >
                  <item.icon
                    className={cn(
                      'h-5 w-5 transition-colors',
                      isActive
                        ? 'text-brain-600 dark:text-brain-400'
                        : 'text-gray-400 group-hover:text-gray-600 dark:group-hover:text-gray-200'
                    )}
                  />
                  {item.name}
                </Link>
              )
            })}
          </nav>

          {/* Status */}
          <div className="border-t p-4 dark:border-gray-700">
            <div className="glass-panel p-3">
              <div className="flex items-center justify-between">
                <span className="text-xs font-medium text-gray-600 dark:text-gray-400">
                  System Status
                </span>
                <span className="flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-2 w-2 rounded-full bg-green-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                </span>
              </div>
              <div className="mt-2 text-xs text-gray-500 dark:text-gray-400">
                BrainMemory: Aktiv
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main content */}
      <main className="flex-1 overflow-y-auto">
        <div className="p-8">
          {children}
        </div>
      </main>
    </div>
  )
}