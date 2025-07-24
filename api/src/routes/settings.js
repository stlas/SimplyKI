// SimplyKI API - Settings Routes
// Erstellt: 2025-07-24 16:31:00 CEST

import { Router } from 'express'
import { readFile, writeFile } from 'fs/promises'
import Joi from 'joi'
import bcrypt from 'bcrypt'
import { ValidationError } from '../middleware/errorHandler.js'

const router = Router()
const SETTINGS_FILE = '/home/aicollab/local/config/settings.json'
const CREDENTIALS_VAULT = '/home/aicollab/local/config/credentials-vault.json'

// Validation schemas
const settingsSchema = Joi.object({
  api_keys: Joi.object({
    anthropic: Joi.string().allow(''),
    openai: Joi.string().allow('')
  }),
  defaults: Joi.object({
    model: Joi.string(),
    max_cost_per_session: Joi.number().min(0),
    temperature: Joi.number().min(0).max(1),
    max_tokens: Joi.number().min(256).max(32768)
  }),
  ui: Joi.object({
    theme: Joi.string().valid('light', 'dark'),
    language: Joi.string(),
    show_cost_warnings: Joi.boolean(),
    auto_save: Joi.boolean()
  }),
  brain: Joi.object({
    cache_size: Joi.number().min(128).max(2048),
    persistence_enabled: Joi.boolean(),
    compression_enabled: Joi.boolean()
  })
})

// Get settings
router.get('/', async (req, res, next) => {
  try {
    const content = await readFile(SETTINGS_FILE, 'utf-8')
    const settings = JSON.parse(content)

    // Mask sensitive data
    if (settings.api_keys) {
      Object.keys(settings.api_keys).forEach(key => {
        if (settings.api_keys[key]) {
          settings.api_keys[key] = maskApiKey(settings.api_keys[key])
        }
      })
    }

    res.json(settings)
  } catch (error) {
    // Return default settings if file doesn't exist
    res.json({
      api_keys: {
        anthropic: '',
        openai: ''
      },
      defaults: {
        model: 'auto',
        max_cost_per_session: 10.00,
        temperature: 0.7,
        max_tokens: 4096
      },
      ui: {
        theme: 'light',
        language: 'de',
        show_cost_warnings: true,
        auto_save: true
      },
      brain: {
        cache_size: 256,
        persistence_enabled: true,
        compression_enabled: true
      }
    })
  }
})

// Update settings
router.put('/', async (req, res, next) => {
  try {
    // Validate input
    const { error, value } = settingsSchema.validate(req.body)
    if (error) {
      return next(new ValidationError('Invalid settings', error.details))
    }

    // Read existing settings
    let settings = {}
    try {
      const content = await readFile(SETTINGS_FILE, 'utf-8')
      settings = JSON.parse(content)
    } catch (error) {
      // File doesn't exist, use empty object
    }

    // Merge settings
    const updatedSettings = {
      ...settings,
      ...value,
      updated: new Date().toISOString()
    }

    // Handle API keys separately (store in vault)
    if (value.api_keys) {
      await updateCredentials(value.api_keys)
    }

    // Save settings
    await writeFile(SETTINGS_FILE, JSON.stringify(updatedSettings, null, 2))

    // Return masked settings
    if (updatedSettings.api_keys) {
      Object.keys(updatedSettings.api_keys).forEach(key => {
        if (updatedSettings.api_keys[key]) {
          updatedSettings.api_keys[key] = maskApiKey(updatedSettings.api_keys[key])
        }
      })
    }

    res.json({
      message: 'Settings updated successfully',
      settings: updatedSettings
    })
  } catch (error) {
    next(error)
  }
})

// Get specific setting
router.get('/:category/:key', async (req, res, next) => {
  try {
    const { category, key } = req.params
    
    const content = await readFile(SETTINGS_FILE, 'utf-8')
    const settings = JSON.parse(content)

    if (!settings[category] || settings[category][key] === undefined) {
      return res.status(404).json({ error: 'Setting not found' })
    }

    let value = settings[category][key]
    
    // Mask API keys
    if (category === 'api_keys' && value) {
      value = maskApiKey(value)
    }

    res.json({
      category,
      key,
      value
    })
  } catch (error) {
    next(error)
  }
})

// Validate API key
router.post('/validate-api-key', async (req, res, next) => {
  try {
    const { service, key } = req.body

    if (!service || !key) {
      return res.status(400).json({ error: 'Service and key are required' })
    }

    // Simple validation (check format)
    const valid = validateApiKeyFormat(service, key)

    res.json({
      service,
      valid,
      message: valid ? 'API key format is valid' : 'Invalid API key format'
    })
  } catch (error) {
    next(error)
  }
})

// Export settings
router.get('/export', async (req, res, next) => {
  try {
    const content = await readFile(SETTINGS_FILE, 'utf-8')
    const settings = JSON.parse(content)

    // Remove sensitive data
    const exportData = {
      ...settings,
      api_keys: undefined,
      exported: new Date().toISOString(),
      version: '0.1.0'
    }

    res.setHeader('Content-Type', 'application/json')
    res.setHeader('Content-Disposition', 'attachment; filename="simplyKI-settings.json"')
    res.json(exportData)
  } catch (error) {
    next(error)
  }
})

// Import settings
router.post('/import', async (req, res, next) => {
  try {
    const { settings } = req.body

    if (!settings) {
      return res.status(400).json({ error: 'Settings data is required' })
    }

    // Validate imported settings (exclude api_keys)
    const { api_keys, ...settingsToValidate } = settings
    const { error } = settingsSchema.validate(settingsToValidate)
    if (error) {
      return next(new ValidationError('Invalid settings format', error.details))
    }

    // Read existing settings
    let currentSettings = {}
    try {
      const content = await readFile(SETTINGS_FILE, 'utf-8')
      currentSettings = JSON.parse(content)
    } catch (error) {
      // File doesn't exist
    }

    // Merge settings (preserve API keys)
    const mergedSettings = {
      ...currentSettings,
      ...settingsToValidate,
      api_keys: currentSettings.api_keys,
      imported: new Date().toISOString()
    }

    await writeFile(SETTINGS_FILE, JSON.stringify(mergedSettings, null, 2))

    res.json({
      message: 'Settings imported successfully',
      imported: Object.keys(settingsToValidate)
    })
  } catch (error) {
    next(error)
  }
})

// Reset settings
router.post('/reset', async (req, res, next) => {
  try {
    const { category } = req.body

    const defaultSettings = {
      api_keys: {
        anthropic: '',
        openai: ''
      },
      defaults: {
        model: 'auto',
        max_cost_per_session: 10.00,
        temperature: 0.7,
        max_tokens: 4096
      },
      ui: {
        theme: 'light',
        language: 'de',
        show_cost_warnings: true,
        auto_save: true
      },
      brain: {
        cache_size: 256,
        persistence_enabled: true,
        compression_enabled: true
      }
    }

    if (category && defaultSettings[category]) {
      // Reset specific category
      const content = await readFile(SETTINGS_FILE, 'utf-8')
      const settings = JSON.parse(content)
      settings[category] = defaultSettings[category]
      await writeFile(SETTINGS_FILE, JSON.stringify(settings, null, 2))
      
      res.json({
        message: `Category '${category}' reset to defaults`,
        settings: settings[category]
      })
    } else if (!category) {
      // Reset all settings
      await writeFile(SETTINGS_FILE, JSON.stringify(defaultSettings, null, 2))
      
      res.json({
        message: 'All settings reset to defaults',
        settings: defaultSettings
      })
    } else {
      res.status(400).json({ error: 'Invalid category' })
    }
  } catch (error) {
    next(error)
  }
})

// Helper functions
function maskApiKey(key) {
  if (!key || key.length < 8) return key
  return key.substring(0, 6) + '*'.repeat(key.length - 10) + key.substring(key.length - 4)
}

function validateApiKeyFormat(service, key) {
  const patterns = {
    anthropic: /^sk-ant-[a-zA-Z0-9]{48}$/,
    openai: /^sk-[a-zA-Z0-9]{48}$/
  }

  return patterns[service] ? patterns[service].test(key) : false
}

async function updateCredentials(apiKeys) {
  try {
    // Read existing vault
    let vault = {}
    try {
      const content = await readFile(CREDENTIALS_VAULT, 'utf-8')
      vault = JSON.parse(content)
    } catch (error) {
      // File doesn't exist
    }

    // Update API keys (only if not masked)
    Object.entries(apiKeys).forEach(([service, key]) => {
      if (key && !key.includes('*')) {
        vault[`${service}_api_key`] = key
      }
    })

    // Save vault
    await writeFile(CREDENTIALS_VAULT, JSON.stringify(vault, null, 2))
  } catch (error) {
    console.error('Failed to update credentials vault:', error)
  }
}

export default router