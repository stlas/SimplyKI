// SimplyKI API - Error Handler Middleware
// Erstellt: 2025-07-24 16:22:00 CEST

export function errorHandler(err, req, res, next) {
  // Log error
  console.error('Error:', err)

  // Default error
  let status = err.status || 500
  let message = err.message || 'Internal Server Error'
  let details = null

  // Handle specific error types
  if (err.name === 'ValidationError') {
    status = 400
    message = 'Validation Error'
    details = err.details
  } else if (err.name === 'UnauthorizedError') {
    status = 401
    message = 'Unauthorized'
  } else if (err.name === 'ForbiddenError') {
    status = 403
    message = 'Forbidden'
  } else if (err.name === 'NotFoundError') {
    status = 404
    message = 'Not Found'
  } else if (err.name === 'ConflictError') {
    status = 409
    message = 'Conflict'
  } else if (err.name === 'RateLimitError') {
    status = 429
    message = 'Too Many Requests'
  }

  // Send error response
  res.status(status).json({
    error: {
      status,
      message,
      details,
      timestamp: new Date().toISOString(),
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  })
}

// Custom error classes
export class ValidationError extends Error {
  constructor(message, details) {
    super(message)
    this.name = 'ValidationError'
    this.status = 400
    this.details = details
  }
}

export class UnauthorizedError extends Error {
  constructor(message = 'Unauthorized') {
    super(message)
    this.name = 'UnauthorizedError'
    this.status = 401
  }
}

export class ForbiddenError extends Error {
  constructor(message = 'Forbidden') {
    super(message)
    this.name = 'ForbiddenError'
    this.status = 403
  }
}

export class NotFoundError extends Error {
  constructor(message = 'Not Found') {
    super(message)
    this.name = 'NotFoundError'
    this.status = 404
  }
}

export class ConflictError extends Error {
  constructor(message = 'Conflict') {
    super(message)
    this.name = 'ConflictError'
    this.status = 409
  }
}

export class RateLimitError extends Error {
  constructor(message = 'Too Many Requests') {
    super(message)
    this.name = 'RateLimitError'
    this.status = 429
  }
}