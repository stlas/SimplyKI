// SimplyKI API - Rate Limiter Middleware
// Erstellt: 2025-07-24 16:25:00 CEST

import rateLimit from 'express-rate-limit'
import { RateLimitError } from './errorHandler.js'

export const rateLimiter = rateLimit({
  windowMs: (process.env.RATE_LIMIT_WINDOW || 15) * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX || 100), // 100 requests per window
  message: 'Too many requests from this IP',
  standardHeaders: true, // Return rate limit info in headers
  legacyHeaders: false,
  handler: (req, res, next) => {
    next(new RateLimitError())
  }
})

// Stricter rate limiter for auth endpoints
export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  skipSuccessfulRequests: true,
  handler: (req, res, next) => {
    next(new RateLimitError('Too many authentication attempts'))
  }
})