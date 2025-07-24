// SimplyKI API - Authentication Middleware
// Erstellt: 2025-07-24 16:24:00 CEST

import jwt from 'jsonwebtoken'
import { UnauthorizedError } from './errorHandler.js'

export function authMiddleware(req, res, next) {
  // Skip auth in development mode if configured
  if (process.env.NODE_ENV === 'development' && process.env.SKIP_AUTH === 'true') {
    req.user = { id: 'dev-user', role: 'admin' }
    return next()
  }

  // Extract token from header
  const authHeader = req.headers.authorization
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new UnauthorizedError('No token provided'))
  }

  const token = authHeader.substring(7)

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dev-secret')
    req.user = decoded
    next()
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return next(new UnauthorizedError('Token expired'))
    } else if (error.name === 'JsonWebTokenError') {
      return next(new UnauthorizedError('Invalid token'))
    }
    return next(error)
  }
}

// Generate token helper
export function generateToken(payload) {
  return jwt.sign(payload, process.env.JWT_SECRET || 'dev-secret', {
    expiresIn: process.env.JWT_EXPIRY || '7d'
  })
}

// API Key validation for external services
export function validateApiKey(apiKey, service) {
  const validKeys = {
    anthropic: process.env.ANTHROPIC_API_KEY,
    openai: process.env.OPENAI_API_KEY
  }

  return apiKey === validKeys[service]
}