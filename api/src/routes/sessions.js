// SimplyKI API - Sessions Routes
// Erstellt: 2025-07-24 16:27:00 CEST

import { Router } from 'express'
import { readFile, writeFile, readdir } from 'fs/promises'
import path from 'path'
import Joi from 'joi'
import { ValidationError, NotFoundError } from '../middleware/errorHandler.js'
import { broadcast } from '../../server.js'

const router = Router()
const SESSIONS_DIR = '/home/aicollab/local/development/sessions'

// Validation schemas
const sessionSchema = Joi.object({
  name: Joi.string().required().min(3).max(100),
  project: Joi.string().required(),
  model: Joi.string().valid('claude-3.5-haiku', 'claude-3.5-sonnet', 'claude-4-opus', 'gpt-3.5-turbo', 'gpt-4'),
  parameters: Joi.object({
    max_tokens: Joi.number().min(256).max(32768),
    temperature: Joi.number().min(0).max(1),
    task_type: Joi.string()
  })
})

// Get all sessions
router.get('/', async (req, res, next) => {
  try {
    const files = await readdir(SESSIONS_DIR)
    const sessions = []

    for (const file of files) {
      if (file.endsWith('.json')) {
        const content = await readFile(path.join(SESSIONS_DIR, file), 'utf-8')
        const session = JSON.parse(content)
        sessions.push({
          id: path.basename(file, '.json'),
          ...session
        })
      }
    }

    // Sort by last active
    sessions.sort((a, b) => new Date(b.lastActive) - new Date(a.lastActive))

    res.json(sessions)
  } catch (error) {
    next(error)
  }
})

// Get session by ID
router.get('/:id', async (req, res, next) => {
  try {
    const sessionPath = path.join(SESSIONS_DIR, `${req.params.id}.json`)
    const content = await readFile(sessionPath, 'utf-8')
    const session = JSON.parse(content)

    res.json({
      id: req.params.id,
      ...session
    })
  } catch (error) {
    if (error.code === 'ENOENT') {
      return next(new NotFoundError('Session not found'))
    }
    next(error)
  }
})

// Create new session
router.post('/', async (req, res, next) => {
  try {
    // Validate input
    const { error, value } = sessionSchema.validate(req.body)
    if (error) {
      return next(new ValidationError('Invalid session data', error.details))
    }

    const sessionId = `${value.project}-${Date.now()}`
    const session = {
      ...value,
      created: new Date().toISOString(),
      lastActive: new Date().toISOString(),
      duration: 0,
      totalCost: 0,
      status: 'active',
      history: []
    }

    // Save session
    await writeFile(
      path.join(SESSIONS_DIR, `${sessionId}.json`),
      JSON.stringify(session, null, 2)
    )

    // Broadcast new session
    broadcast('sessions', {
      action: 'created',
      session: { id: sessionId, ...session }
    })

    res.status(201).json({
      id: sessionId,
      ...session
    })
  } catch (error) {
    next(error)
  }
})

// Update session
router.put('/:id', async (req, res, next) => {
  try {
    const sessionPath = path.join(SESSIONS_DIR, `${req.params.id}.json`)
    
    // Read existing session
    const content = await readFile(sessionPath, 'utf-8')
    const session = JSON.parse(content)

    // Update fields
    const updated = {
      ...session,
      ...req.body,
      lastActive: new Date().toISOString()
    }

    // Save updated session
    await writeFile(sessionPath, JSON.stringify(updated, null, 2))

    // Broadcast update
    broadcast('sessions', {
      action: 'updated',
      session: { id: req.params.id, ...updated }
    })

    res.json({
      id: req.params.id,
      ...updated
    })
  } catch (error) {
    if (error.code === 'ENOENT') {
      return next(new NotFoundError('Session not found'))
    }
    next(error)
  }
})

// Delete session
router.delete('/:id', async (req, res, next) => {
  try {
    const sessionPath = path.join(SESSIONS_DIR, `${req.params.id}.json`)
    await unlink(sessionPath)

    // Broadcast deletion
    broadcast('sessions', {
      action: 'deleted',
      sessionId: req.params.id
    })

    res.status(204).send()
  } catch (error) {
    if (error.code === 'ENOENT') {
      return next(new NotFoundError('Session not found'))
    }
    next(error)
  }
})

// Restore session
router.post('/:id/restore', async (req, res, next) => {
  try {
    const sessionPath = path.join(SESSIONS_DIR, `${req.params.id}.json`)
    const content = await readFile(sessionPath, 'utf-8')
    const session = JSON.parse(content)

    // Update session status
    session.status = 'active'
    session.lastActive = new Date().toISOString()

    await writeFile(sessionPath, JSON.stringify(session, null, 2))

    // Execute restore command
    const { exec } = await import('child_process')
    exec(`cd /home/aicollab/SimplyKI-repo && ./core/src/session-manager.sh restore ${req.params.id}`)

    res.json({
      message: 'Session restored',
      session: { id: req.params.id, ...session }
    })
  } catch (error) {
    if (error.code === 'ENOENT') {
      return next(new NotFoundError('Session not found'))
    }
    next(error)
  }
})

// Create snapshot
router.post('/:id/snapshot', async (req, res, next) => {
  try {
    const sessionPath = path.join(SESSIONS_DIR, `${req.params.id}.json`)
    const content = await readFile(sessionPath, 'utf-8')
    const session = JSON.parse(content)

    const snapshotId = `${req.params.id}-snapshot-${Date.now()}`
    const snapshotPath = path.join(SESSIONS_DIR, 'snapshots', `${snapshotId}.json`)

    // Create snapshot
    await writeFile(snapshotPath, JSON.stringify({
      ...session,
      snapshotId,
      snapshotCreated: new Date().toISOString()
    }, null, 2))

    res.json({
      message: 'Snapshot created',
      snapshotId
    })
  } catch (error) {
    if (error.code === 'ENOENT') {
      return next(new NotFoundError('Session not found'))
    }
    next(error)
  }
})

export default router