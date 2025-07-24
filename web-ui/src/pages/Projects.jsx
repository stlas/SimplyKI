// SimplyKI Web UI - Projects Page
// Erstellt: 2025-07-24 16:10:00 CEST

import React, { useState } from 'react'
import { FolderOpen, GitBranch, Calendar, Code, FileText, Plus, ExternalLink } from 'lucide-react'
import { formatBytes } from '@/lib/utils'

const projects = [
  {
    id: 'simplyKI',
    name: 'SimplyKI',
    description: 'Gehirn-inspiriertes KI-Entwicklungsframework mit Rust und Shell',
    path: '/home/aicollab/SimplyKI-repo',
    type: 'framework',
    language: 'Rust/Shell',
    lastModified: '2025-07-24T15:30:00',
    size: 45 * 1024 * 1024, // 45MB
    status: 'active',
    github: 'https://github.com/stlas/SimplyKI',
    stats: {
      files: 234,
      commits: 89,
      branches: 3,
    }
  },
  {
    id: 'csv2actual',
    name: 'CSV2Actual',
    description: 'PowerShell-basiertes Tool zur CSV-Verarbeitung und Excel-Integration',
    path: '/home/aicollab/projects/CSV2Actual',
    type: 'tool',
    language: 'PowerShell',
    lastModified: '2025-07-23T18:45:00',
    size: 12 * 1024 * 1024, // 12MB
    status: 'active',
    github: 'https://github.com/stlas/CSV2Actual',
    stats: {
      files: 67,
      commits: 156,
      branches: 2,
    }
  },
  {
    id: 'smartki-web',
    name: 'SmartKI Web',
    description: 'Web-Interface für SmartKI mit React und TypeScript',
    path: '/home/aicollab/projects/SmartKI-web',
    type: 'web',
    language: 'TypeScript/React',
    lastModified: '2025-07-22T10:20:00',
    size: 234 * 1024 * 1024, // 234MB
    status: 'development',
    github: 'https://github.com/stlas/SmartKI-web',
    stats: {
      files: 512,
      commits: 234,
      branches: 5,
    }
  },
  {
    id: 'smartki-pm',
    name: 'SmartKI PM',
    description: 'Projektmanagement-Integration mit Kanboard',
    path: '/home/aicollab/projects/SmartKI-PM',
    type: 'integration',
    language: 'Python',
    lastModified: '2025-07-20T14:30:00',
    size: 8 * 1024 * 1024, // 8MB
    status: 'stable',
    github: 'https://github.com/stlas/SmartKI-PM',
    stats: {
      files: 45,
      commits: 78,
      branches: 1,
    }
  },
]

const projectTypes = {
  framework: { color: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400', icon: Code },
  tool: { color: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400', icon: Code },
  web: { color: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400', icon: Code },
  integration: { color: 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400', icon: Code },
}

export default function Projects() {
  const [showAddProject, setShowAddProject] = useState(false)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Projekte
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Verwalten Sie Ihre SimplyKI-integrierten Projekte
          </p>
        </div>
        <button
          onClick={() => setShowAddProject(true)}
          className="flex items-center gap-2 px-4 py-2 bg-brain-500 text-white rounded-lg hover:bg-brain-600 font-medium"
        >
          <Plus className="h-4 w-4" />
          Projekt hinzufügen
        </button>
      </div>

      {/* Projects Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {projects.map((project) => {
          const TypeInfo = projectTypes[project.type]
          return (
            <div
              key={project.id}
              className="bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-lg transition-shadow"
            >
              <div className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-start gap-3">
                    <div className="p-2 bg-gray-100 dark:bg-gray-700 rounded-lg">
                      <FolderOpen className="h-6 w-6 text-gray-600 dark:text-gray-400" />
                    </div>
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                        {project.name}
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                        {project.description}
                      </p>
                    </div>
                  </div>
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${TypeInfo.color}`}>
                    {project.type}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-4 mb-4">
                  <div>
                    <p className="text-xs text-gray-600 dark:text-gray-400">Sprache</p>
                    <p className="font-medium text-sm">{project.language}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-600 dark:text-gray-400">Größe</p>
                    <p className="font-medium text-sm">{formatBytes(project.size)}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-600 dark:text-gray-400">Status</p>
                    <p className="font-medium text-sm capitalize">{project.status}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-600 dark:text-gray-400">Letzte Änderung</p>
                    <p className="font-medium text-sm">
                      {new Date(project.lastModified).toLocaleDateString('de-DE')}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-6 text-sm text-gray-600 dark:text-gray-400 mb-4">
                  <span className="flex items-center gap-1">
                    <FileText className="h-4 w-4" />
                    {project.stats.files} Dateien
                  </span>
                  <span className="flex items-center gap-1">
                    <GitBranch className="h-4 w-4" />
                    {project.stats.commits} Commits
                  </span>
                  <span className="flex items-center gap-1">
                    <Code className="h-4 w-4" />
                    {project.stats.branches} Branches
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 text-sm font-medium">
                    Öffnen
                  </button>
                  <a
                    href={project.github}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 text-sm font-medium"
                  >
                    <GitBranch className="h-4 w-4" />
                    GitHub
                    <ExternalLink className="h-3 w-3" />
                  </a>
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Project Stats */}
      <div className="bg-gradient-to-r from-brain-500 to-neural-500 rounded-lg shadow-lg p-6 text-white">
        <h3 className="text-xl font-semibold mb-4">Projekt-Statistiken</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          <div>
            <p className="text-brain-100">Gesamt-Projekte</p>
            <p className="text-3xl font-bold">{projects.length}</p>
          </div>
          <div>
            <p className="text-brain-100">Aktive Projekte</p>
            <p className="text-3xl font-bold">
              {projects.filter(p => p.status === 'active').length}
            </p>
          </div>
          <div>
            <p className="text-brain-100">Gesamtgröße</p>
            <p className="text-3xl font-bold">
              {formatBytes(projects.reduce((sum, p) => sum + p.size, 0))}
            </p>
          </div>
          <div>
            <p className="text-brain-100">Total Commits</p>
            <p className="text-3xl font-bold">
              {projects.reduce((sum, p) => sum + p.stats.commits, 0)}
            </p>
          </div>
        </div>
      </div>

      {/* Add Project Modal */}
      {showAddProject && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-md w-full">
            <div className="p-6">
              <h3 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white">
                Neues Projekt hinzufügen
              </h3>
              <form className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Projekt-Pfad
                  </label>
                  <input
                    type="text"
                    placeholder="/pfad/zum/projekt"
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Name (optional)
                  </label>
                  <input
                    type="text"
                    placeholder="Mein Projekt"
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700"
                  />
                </div>
                <div className="flex items-center gap-3 pt-4">
                  <button
                    type="submit"
                    className="flex-1 px-4 py-2 bg-brain-500 text-white rounded-lg hover:bg-brain-600 font-medium"
                  >
                    Hinzufügen
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowAddProject(false)}
                    className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 font-medium"
                  >
                    Abbrechen
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}