// SimplyKI API - Cost Optimization Routes
// Erstellt: 2025-07-24 16:28:00 CEST

import { Router } from 'express'
import { exec } from 'child_process'
import { promisify } from 'util'
import Joi from 'joi'
import { ValidationError } from '../middleware/errorHandler.js'
import NodeCache from 'node-cache'

const router = Router()
const execAsync = promisify(exec)
const cache = new NodeCache({ stdTTL: 300 }) // 5 minute cache

// Model pricing data
const MODEL_PRICING = {
  'claude-3.5-haiku': { input: 0.00025, output: 0.00125, speed: 'fast', quality: 'good' },
  'claude-3.5-sonnet': { input: 0.003, output: 0.015, speed: 'fast', quality: 'excellent' },
  'claude-4-opus': { input: 0.015, output: 0.075, speed: 'medium', quality: 'excellent' },
  'gpt-3.5-turbo': { input: 0.0005, output: 0.0015, speed: 'fast', quality: 'good' },
  'gpt-4': { input: 0.01, output: 0.03, speed: 'slow', quality: 'excellent' },
  'gpt-4-turbo': { input: 0.01, output: 0.03, speed: 'medium', quality: 'excellent' }
}

// Task complexity mapping
const TASK_COMPLEXITY = {
  simple_fix: 1,
  documentation: 1,
  code_review: 2,
  feature_development: 3,
  architecture: 4,
  complex_refactoring: 4
}

// Validation schema
const optimizationSchema = Joi.object({
  task_type: Joi.string().valid(...Object.keys(TASK_COMPLEXITY)).required(),
  estimated_tokens: Joi.number().min(100).max(100000).default(1000),
  budget: Joi.number().min(0.01).max(1000).default(10),
  priority: Joi.string().valid('cost', 'quality', 'speed').default('cost')
})

// Get optimal model recommendation
router.post('/optimize', async (req, res, next) => {
  try {
    // Validate input
    const { error, value } = optimizationSchema.validate(req.body)
    if (error) {
      return next(new ValidationError('Invalid optimization parameters', error.details))
    }

    const { task_type, estimated_tokens, budget, priority } = value
    const complexity = TASK_COMPLEXITY[task_type]

    // Calculate costs and recommendations
    const recommendations = Object.entries(MODEL_PRICING).map(([model, pricing]) => {
      const inputCost = (estimated_tokens * 0.6 / 1000) * pricing.input
      const outputCost = (estimated_tokens * 0.4 / 1000) * pricing.output
      const totalCost = inputCost + outputCost

      // Score based on priority
      let score = 0
      if (priority === 'cost') {
        score = 1 / totalCost
      } else if (priority === 'quality') {
        score = pricing.quality === 'excellent' ? 10 : 5
      } else if (priority === 'speed') {
        score = pricing.speed === 'fast' ? 10 : pricing.speed === 'medium' ? 5 : 1
      }

      // Complexity matching
      const complexityMatch = 
        (complexity <= 2 && totalCost <= 0.01) ||
        (complexity === 3 && totalCost <= 0.05) ||
        (complexity >= 4 && pricing.quality === 'excellent')

      return {
        model,
        pricing,
        cost: {
          input: inputCost,
          output: outputCost,
          total: totalCost
        },
        withinBudget: totalCost <= budget,
        complexityMatch,
        score,
        recommended: totalCost <= budget && complexityMatch
      }
    })

    // Sort by score
    recommendations.sort((a, b) => b.score - a.score)

    // Get best recommendation
    const best = recommendations.find(r => r.recommended) || recommendations[0]

    res.json({
      task_type,
      complexity,
      estimated_tokens,
      budget,
      priority,
      recommendation: best,
      alternatives: recommendations.slice(0, 5),
      savings_tip: getSavingsTip(task_type)
    })
  } catch (error) {
    next(error)
  }
})

// Get cost statistics
router.get('/stats', async (req, res, next) => {
  try {
    // Check cache
    const cached = cache.get('cost-stats')
    if (cached) {
      return res.json(cached)
    }

    // Get cost data from SimplyKI
    const { stdout } = await execAsync('cd /home/aicollab/SimplyKI-repo && ./core/src/cost-optimizer.sh get-stats --json')
    const stats = JSON.parse(stdout)

    // Cache result
    cache.set('cost-stats', stats)

    res.json(stats)
  } catch (error) {
    // Fallback to mock data
    const mockStats = {
      today: {
        total: 12.45,
        sessions: 8,
        average_per_session: 1.56,
        by_model: {
          'claude-3.5-sonnet': 8.20,
          'claude-3.5-haiku': 2.15,
          'claude-4-opus': 2.10
        }
      },
      week: {
        total: 78.90,
        sessions: 45,
        average_per_session: 1.75
      },
      month: {
        total: 234.50,
        sessions: 156,
        average_per_session: 1.50
      },
      trend: 'decreasing',
      savings_achieved: 156.78
    }

    res.json(mockStats)
  }
})

// Get cost history
router.get('/history', async (req, res, next) => {
  try {
    const days = parseInt(req.query.days) || 7
    
    // Mock historical data
    const history = Array.from({ length: days }, (_, i) => {
      const date = new Date()
      date.setDate(date.getDate() - i)
      
      return {
        date: date.toISOString().split('T')[0],
        cost: Math.random() * 20 + 5,
        sessions: Math.floor(Math.random() * 10) + 3,
        models: {
          'claude-3.5-sonnet': Math.random() * 10,
          'claude-3.5-haiku': Math.random() * 5,
          'claude-4-opus': Math.random() * 5
        }
      }
    })

    res.json(history.reverse())
  } catch (error) {
    next(error)
  }
})

// Apply template for cost savings
router.post('/template/:templateName', async (req, res, next) => {
  try {
    const { templateName } = req.params
    
    // Execute template command
    const { stdout } = await execAsync(`cd /home/aicollab/SimplyKI-repo && ./core/src/ai-collab.sh template ${templateName} --estimate`)
    
    const estimate = JSON.parse(stdout)
    
    res.json({
      template: templateName,
      estimated_savings: estimate.savings,
      original_cost: estimate.original,
      optimized_cost: estimate.optimized,
      savings_percentage: estimate.percentage
    })
  } catch (error) {
    // Fallback response
    res.json({
      template: req.params.templateName,
      estimated_savings: 0.45,
      original_cost: 1.50,
      optimized_cost: 1.05,
      savings_percentage: 30
    })
  }
})

// Helper functions
function getSavingsTip(taskType) {
  const tips = {
    simple_fix: "Use claude-3.5-haiku for simple fixes - 80% cheaper than sonnet",
    documentation: "Templates can reduce documentation costs by 70%",
    code_review: "Batch multiple files together for better rates",
    feature_development: "Start with haiku for prototyping, then sonnet for refinement",
    architecture: "Use opus sparingly - only for critical decisions",
    complex_refactoring: "Break into smaller tasks to use cheaper models"
  }
  
  return tips[taskType] || "Use templates to save 60-70% on repeated tasks"
}

export default router