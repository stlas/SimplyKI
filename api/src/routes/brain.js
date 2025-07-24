// SimplyKI API - BrainMemory Routes
// Erstellt: 2025-07-24 16:29:00 CEST

import { Router } from 'express'
import axios from 'axios'
import { broadcast } from '../../server.js'
import NodeCache from 'node-cache'

const router = Router()
const cache = new NodeCache({ stdTTL: 5 }) // 5 second cache for real-time data
const BRAIN_URL = process.env.BRAIN_MEMORY_URL || 'http://localhost:5000'

// Get BrainMemory status
router.get('/status', async (req, res, next) => {
  try {
    // Check cache
    const cached = cache.get('brain-status')
    if (cached) {
      return res.json(cached)
    }

    // Mock data for now (will be replaced with actual BrainMemory API)
    const status = {
      status: 'running',
      version: '0.1.0',
      uptime: 3600000, // 1 hour
      performance: {
        rust_enabled: true,
        performance_boost: 102.5,
        avg_operation_time: 0.98 // ms
      }
    }

    // Cache result
    cache.set('brain-status', status)

    res.json(status)
  } catch (error) {
    res.json({
      status: 'error',
      message: error.message
    })
  }
})

// Get memory statistics
router.get('/memory', async (req, res, next) => {
  try {
    // Mock memory data
    const memory = {
      working_memory: {
        used: 48234496, // ~46MB
        total: 268435456, // 256MB
        entries: 1456,
        oldest_entry: new Date(Date.now() - 3600000).toISOString(),
        newest_entry: new Date().toISOString()
      },
      long_term_memory: {
        used: 932184064, // ~889MB
        total: 4294967296, // 4GB
        entries: 48923,
        compression_ratio: 2.3
      },
      context_cache: {
        size: 234,
        hits: 9834,
        misses: 245,
        hit_rate: 0.976,
        avg_retrieval_time: 0.23 // ms
      },
      associations: {
        nodes: 6234,
        edges: 14567,
        clusters: 23,
        avg_degree: 4.67
      }
    }

    // Broadcast memory update
    broadcast('brain-memory', memory)

    res.json(memory)
  } catch (error) {
    next(error)
  }
})

// Get performance metrics
router.get('/performance', async (req, res, next) => {
  try {
    const performance = {
      operations: {
        store: {
          count: 4567,
          avg_time: 0.45,
          p95_time: 0.89,
          p99_time: 1.23
        },
        retrieve: {
          count: 12456,
          avg_time: 0.23,
          p95_time: 0.45,
          p99_time: 0.67
        },
        search: {
          count: 2345,
          avg_time: 2.34,
          p95_time: 4.56,
          p99_time: 6.78
        }
      },
      throughput: {
        current: 4892, // ops/sec
        peak: 6234,
        average: 4567
      },
      comparison: {
        shell_baseline: 234.5, // ms
        rust_optimized: 2.3, // ms
        improvement_factor: 102.0
      }
    }

    res.json(performance)
  } catch (error) {
    next(error)
  }
})

// Run benchmark
router.post('/benchmark', async (req, res, next) => {
  try {
    // Simulate benchmark execution
    const benchmark = {
      status: 'running',
      started: new Date().toISOString(),
      tests: [
        { name: 'Sequential Write', status: 'completed', shell_ms: 145.2, rust_ms: 1.4 },
        { name: 'Random Read', status: 'completed', shell_ms: 234.5, rust_ms: 2.3 },
        { name: 'Pattern Search', status: 'running', shell_ms: null, rust_ms: null },
        { name: 'Cache Hit Rate', status: 'pending', shell_ms: null, rust_ms: null }
      ]
    }

    // Simulate async benchmark completion
    setTimeout(() => {
      broadcast('brain-benchmark', {
        status: 'completed',
        results: {
          shell_total: 567.8,
          rust_total: 5.6,
          improvement: 101.4,
          tests: [
            { name: 'Sequential Write', shell_ms: 145.2, rust_ms: 1.4, improvement: 103.7 },
            { name: 'Random Read', shell_ms: 234.5, rust_ms: 2.3, improvement: 102.0 },
            { name: 'Pattern Search', shell_ms: 123.4, rust_ms: 1.2, improvement: 102.8 },
            { name: 'Cache Hit Rate', shell_ms: 64.7, rust_ms: 0.7, improvement: 92.4 }
          ]
        }
      })
    }, 3000)

    res.json(benchmark)
  } catch (error) {
    next(error)
  }
})

// Store data in BrainMemory
router.post('/store', async (req, res, next) => {
  try {
    const { key, value, type = 'general' } = req.body

    if (!key || !value) {
      return res.status(400).json({ error: 'Key and value are required' })
    }

    // In production, this would call the actual BrainMemory Rust service
    const result = {
      stored: true,
      key,
      type,
      size: JSON.stringify(value).length,
      timestamp: new Date().toISOString()
    }

    res.json(result)
  } catch (error) {
    next(error)
  }
})

// Retrieve data from BrainMemory
router.get('/retrieve/:key', async (req, res, next) => {
  try {
    const { key } = req.params

    // Mock retrieval
    const result = {
      found: true,
      key,
      value: { example: 'data', timestamp: new Date().toISOString() },
      retrieval_time: 0.23,
      cache_hit: true
    }

    res.json(result)
  } catch (error) {
    next(error)
  }
})

// Search in BrainMemory
router.post('/search', async (req, res, next) => {
  try {
    const { query, limit = 10 } = req.body

    if (!query) {
      return res.status(400).json({ error: 'Query is required' })
    }

    // Mock search results
    const results = {
      query,
      matches: [
        {
          key: 'session-123',
          score: 0.95,
          preview: 'CSV processing session with pandas integration...',
          type: 'session'
        },
        {
          key: 'template-csv-import',
          score: 0.87,
          preview: 'Template for importing CSV files with validation...',
          type: 'template'
        },
        {
          key: 'doc-csv-best-practices',
          score: 0.76,
          preview: 'Best practices for handling large CSV files...',
          type: 'documentation'
        }
      ],
      search_time: 2.34,
      total_matches: 3
    }

    res.json(results)
  } catch (error) {
    next(error)
  }
})

// Get association graph
router.get('/associations/:key', async (req, res, next) => {
  try {
    const { key } = req.params
    const depth = parseInt(req.query.depth) || 2

    // Mock association data
    const associations = {
      root: key,
      depth,
      nodes: [
        { id: key, label: 'Current', type: 'root' },
        { id: 'related-1', label: 'CSV Parser', type: 'code' },
        { id: 'related-2', label: 'Data Validation', type: 'function' },
        { id: 'related-3', label: 'Error Handling', type: 'pattern' }
      ],
      edges: [
        { from: key, to: 'related-1', strength: 0.9 },
        { from: key, to: 'related-2', strength: 0.85 },
        { from: 'related-1', to: 'related-3', strength: 0.7 }
      ]
    }

    res.json(associations)
  } catch (error) {
    next(error)
  }
})

export default router