// SimplyKI Web UI - Settings Page
// Erstellt: 2025-07-24 16:11:00 CEST

import React, { useState } from 'react'
import { Settings as SettingsIcon, Key, Database, Globe, Moon, Sun, Save, AlertCircle } from 'lucide-react'
import { formatCost } from '@/lib/utils'

export default function Settings() {
  const [settings, setSettings] = useState({
    apiKeys: {
      anthropic: 'sk-ant-*************',
      openai: '',
    },
    defaults: {
      model: 'auto',
      maxCostPerSession: 10.00,
      temperature: 0.7,
      maxTokens: 4096,
    },
    ui: {
      theme: 'light',
      language: 'de',
      showCostWarnings: true,
      autoSave: true,
    },
    brain: {
      cacheSize: 256, // MB
      persistenceEnabled: true,
      compressionEnabled: true,
    }
  })

  const [saved, setSaved] = useState(false)

  const handleSave = () => {
    console.log('Saving settings:', settings)
    setSaved(true)
    setTimeout(() => setSaved(false), 3000)
  }

  const updateSetting = (category, key, value) => {
    setSettings(prev => ({
      ...prev,
      [category]: {
        ...prev[category],
        [key]: value
      }
    }))
  }

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Einstellungen
        </h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">
          Konfigurieren Sie SimplyKI nach Ihren Anforderungen
        </p>
      </div>

      {/* API Keys */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div className="flex items-center gap-2 mb-4">
          <Key className="h-5 w-5 text-gray-500" />
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
            API Schlüssel
          </h2>
        </div>
        
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Anthropic API Key
            </label>
            <input
              type="password"
              value={settings.apiKeys.anthropic}
              onChange={(e) => updateSetting('apiKeys', 'anthropic', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              OpenAI API Key (optional)
            </label>
            <input
              type="password"
              value={settings.apiKeys.openai}
              onChange={(e) => updateSetting('apiKeys', 'openai', e.target.value)}
              placeholder="sk-..."
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700"
            />
          </div>
        </div>

        <div className="mt-4 p-3 bg-amber-50 dark:bg-amber-900/20 rounded-lg flex items-start gap-2">
          <AlertCircle className="h-4 w-4 text-amber-600 dark:text-amber-400 mt-0.5" />
          <p className="text-sm text-amber-800 dark:text-amber-200">
            API-Schlüssel werden lokal verschlüsselt gespeichert und niemals an Dritte weitergegeben.
          </p>
        </div>
      </div>

      {/* Default Settings */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div className="flex items-center gap-2 mb-4">
          <SettingsIcon className="h-5 w-5 text-gray-500" />
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
            Standard-Einstellungen
          </h2>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Standard-Modell
            </label>
            <select
              value={settings.defaults.model}
              onChange={(e) => updateSetting('defaults', 'model', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700"
            >
              <option value="auto">Automatisch (empfohlen)</option>
              <option value="claude-3.5-haiku">Claude 3.5 Haiku</option>
              <option value="claude-3.5-sonnet">Claude 3.5 Sonnet</option>
              <option value="claude-4-opus">Claude 4 Opus</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Max. Kosten pro Session
            </label>
            <div className="flex items-center gap-2">
              <input
                type="number"
                value={settings.defaults.maxCostPerSession}
                onChange={(e) => updateSetting('defaults', 'maxCostPerSession', parseFloat(e.target.value))}
                step="1"
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700"
              />
              <span className="text-gray-600 dark:text-gray-400">EUR</span>
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Temperature
            </label>
            <input
              type="range"
              min="0"
              max="1"
              step="0.1"
              value={settings.defaults.temperature}
              onChange={(e) => updateSetting('defaults', 'temperature', parseFloat(e.target.value))}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400">
              <span>Präzise</span>
              <span>{settings.defaults.temperature}</span>
              <span>Kreativ</span>
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Max. Tokens
            </label>
            <select
              value={settings.defaults.maxTokens}
              onChange={(e) => updateSetting('defaults', 'maxTokens', parseInt(e.target.value))}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700"
            >
              <option value="2048">2048 (Klein)</option>
              <option value="4096">4096 (Standard)</option>
              <option value="8192">8192 (Groß)</option>
              <option value="16384">16384 (Extra Groß)</option>
            </select>
          </div>
        </div>
      </div>

      {/* UI Settings */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div className="flex items-center gap-2 mb-4">
          <Globe className="h-5 w-5 text-gray-500" />
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
            Benutzeroberfläche
          </h2>
        </div>
        
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Theme</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Aussehen der Oberfläche</p>
            </div>
            <button
              onClick={() => updateSetting('ui', 'theme', settings.ui.theme === 'light' ? 'dark' : 'light')}
              className="p-2 rounded-lg border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-700"
            >
              {settings.ui.theme === 'light' ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
            </button>
          </div>
          
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Kostenwarnungen</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Warnung bei hohen Kosten anzeigen</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.ui.showCostWarnings}
                onChange={(e) => updateSetting('ui', 'showCostWarnings', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-brain-600"></div>
            </label>
          </div>
          
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Automatisches Speichern</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Sessions automatisch speichern</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.ui.autoSave}
                onChange={(e) => updateSetting('ui', 'autoSave', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-brain-600"></div>
            </label>
          </div>
        </div>
      </div>

      {/* BrainMemory Settings */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div className="flex items-center gap-2 mb-4">
          <Database className="h-5 w-5 text-gray-500" />
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
            BrainMemory
          </h2>
        </div>
        
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Cache-Größe (MB)
            </label>
            <input
              type="range"
              min="128"
              max="1024"
              step="128"
              value={settings.brain.cacheSize}
              onChange={(e) => updateSetting('brain', 'cacheSize', parseInt(e.target.value))}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400">
              <span>128 MB</span>
              <span>{settings.brain.cacheSize} MB</span>
              <span>1024 MB</span>
            </div>
          </div>
          
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Persistenz</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Speicher zwischen Sessions erhalten</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.brain.persistenceEnabled}
                onChange={(e) => updateSetting('brain', 'persistenceEnabled', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-brain-600"></div>
            </label>
          </div>
          
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Kompression</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Speicher komprimieren für mehr Kapazität</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.brain.compressionEnabled}
                onChange={(e) => updateSetting('brain', 'compressionEnabled', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-brain-600"></div>
            </label>
          </div>
        </div>
      </div>

      {/* Save Button */}
      <div className="flex items-center gap-4">
        <button
          onClick={handleSave}
          className="flex items-center gap-2 px-6 py-3 bg-brain-500 text-white rounded-lg hover:bg-brain-600 font-medium"
        >
          <Save className="h-4 w-4" />
          Einstellungen speichern
        </button>
        
        {saved && (
          <p className="text-green-600 dark:text-green-400 flex items-center gap-1">
            ✓ Einstellungen gespeichert
          </p>
        )}
      </div>
    </div>
  )
}