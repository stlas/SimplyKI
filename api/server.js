// SimplyKI API Server
// Erstellt: 2025-07-24 16:20:00 CEST

import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import compression from 'compression'
import { createServer } from 'http'
import { WebSocketServer } from 'ws'
import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'

// Import routes
import statusRouter from './src/routes/status.js'
import sessionsRouter from './src/routes/sessions.js'
import projectsRouter from './src/routes/projects.js'
import costRouter from './src/routes/cost.js'
import brainRouter from './src/routes/brain.js'
import settingsRouter from './src/routes/settings.js'

// Import middleware
import { errorHandler } from './src/middleware/errorHandler.js'
import { requestLogger } from './src/middleware/logger.js'
import { authMiddleware } from './src/middleware/auth.js'
import { rateLimiter } from './src/middleware/rateLimiter.js'

// Load environment variables
dotenv.config()

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const server = createServer(app)
const wss = new WebSocketServer({ server })

// Configuration
const PORT = process.env.PORT || 8080
const NODE_ENV = process.env.NODE_ENV || 'development'

// Middleware
app.use(helmet())
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}))
app.use(compression())
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true }))
app.use(requestLogger)

// Rate limiting for production
if (NODE_ENV === 'production') {
  app.use(rateLimiter)
}

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '0.1.0'
  })
})

// API Routes
app.use('/api/status', statusRouter)
app.use('/api/sessions', authMiddleware, sessionsRouter)
app.use('/api/projects', authMiddleware, projectsRouter)
app.use('/api/cost', authMiddleware, costRouter)
app.use('/api/brain', authMiddleware, brainRouter)
app.use('/api/settings', authMiddleware, settingsRouter)

// Static files for production
if (NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../web-ui/dist')))
  
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../web-ui/dist/index.html'))
  })
}

// WebSocket handling
const clients = new Set()

wss.on('connection', (ws, req) => {
  console.log('New WebSocket connection')
  clients.add(ws)

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message)
      console.log('WebSocket message:', data)
      
      // Handle different message types
      switch (data.type) {
        case 'subscribe':
          ws.subscriptions = data.channels || []
          break
        case 'ping':
          ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }))
          break
        default:
          console.log('Unknown message type:', data.type)
      }
    } catch (error) {
      console.error('WebSocket message error:', error)
    }
  })

  ws.on('close', () => {
    console.log('WebSocket connection closed')
    clients.delete(ws)
  })

  ws.on('error', (error) => {
    console.error('WebSocket error:', error)
  })

  // Send initial connection message
  ws.send(JSON.stringify({
    type: 'connected',
    timestamp: Date.now()
  }))
})

// Broadcast function for real-time updates
export function broadcast(channel, data) {
  const message = JSON.stringify({
    channel,
    data,
    timestamp: Date.now()
  })

  clients.forEach(client => {
    if (client.readyState === 1 && (!client.subscriptions || client.subscriptions.includes(channel))) {
      client.send(message)
    }
  })
}

// Error handling
app.use(errorHandler)

// Start server
server.listen(PORT, () => {
  console.log(`
🚀 SimplyKI API Server
━━━━━━━━━━━━━━━━━━━━━
Environment: ${NODE_ENV}
Port: ${PORT}
WebSocket: ws://localhost:${PORT}
━━━━━━━━━━━━━━━━━━━━━
  `)
})

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...')
  server.close(() => {
    console.log('Server closed')
    process.exit(0)
  })
})

process.on('SIGINT', () => {
  console.log('\nSIGINT received, shutting down gracefully...')
  server.close(() => {
    console.log('Server closed')
    process.exit(0)
  })
})