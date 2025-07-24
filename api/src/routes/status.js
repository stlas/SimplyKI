// SimplyKI API - Status Routes
// Erstellt: 2025-07-24 16:26:00 CEST

import { Router } from 'express'
import { exec } from 'child_process'
import { promisify } from 'util'
import os from 'os'
import { broadcast } from '../../server.js'

const router = Router()
const execAsync = promisify(exec)

// Get system status
router.get('/', async (req, res, next) => {
  try {
    // Get system metrics
    const cpuUsage = os.loadavg()[0] // 1 minute load average
    const totalMemory = os.totalmem()
    const freeMemory = os.freemem()
    const usedMemory = totalMemory - freeMemory
    const memoryUsage = (usedMemory / totalMemory) * 100

    // Get SimplyKI status
    const simplyKIStatus = await getSimplyKIStatus()

    const status = {
      system: {
        platform: os.platform(),
        uptime: os.uptime(),
        loadAverage: os.loadavg(),
        cpuUsage: cpuUsage.toFixed(2),
        memory: {
          total: totalMemory,
          used: usedMemory,
          free: freeMemory,
          percentage: memoryUsage.toFixed(1)
        }
      },
      simplyKI: simplyKIStatus,
      services: {
        api: 'healthy',
        brainMemory: await checkBrainMemoryStatus(),
        hcs: await checkHCSStatus()
      },
      timestamp: new Date().toISOString()
    }

    // Broadcast status update
    broadcast('status', status)

    res.json(status)
  } catch (error) {
    next(error)
  }
})

// Get detailed metrics
router.get('/metrics', async (req, res, next) => {
  try {
    const metrics = {
      cpu: {
        cores: os.cpus().length,
        model: os.cpus()[0].model,
        speed: os.cpus()[0].speed,
        usage: process.cpuUsage()
      },
      memory: {
        rss: process.memoryUsage().rss,
        heapTotal: process.memoryUsage().heapTotal,
        heapUsed: process.memoryUsage().heapUsed,
        external: process.memoryUsage().external,
        arrayBuffers: process.memoryUsage().arrayBuffers
      },
      process: {
        pid: process.pid,
        version: process.version,
        uptime: process.uptime()
      }
    }

    res.json(metrics)
  } catch (error) {
    next(error)
  }
})

// Helper functions
async function getSimplyKIStatus() {
  try {
    const { stdout } = await execAsync('cd /home/aicollab/SimplyKI-repo && ./bin/simplyKI status --json')
    return JSON.parse(stdout)
  } catch (error) {
    return {
      status: 'error',
      message: error.message
    }
  }
}

async function checkBrainMemoryStatus() {
  try {
    const { stdout } = await execAsync('ps aux | grep brainmemory | grep -v grep')
    return stdout ? 'running' : 'stopped'
  } catch (error) {
    return 'stopped'
  }
}

async function checkHCSStatus() {
  try {
    const { stdout } = await execAsync('cd /home/aicollab/SimplyKI-repo && ./bin/simplyKI hcs status --json')
    const status = JSON.parse(stdout)
    return status.active ? 'active' : 'inactive'
  } catch (error) {
    return 'inactive'
  }
}

export default router