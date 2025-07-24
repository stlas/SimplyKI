// SimplyKI API - Logger Middleware
// Erstellt: 2025-07-24 16:23:00 CEST

export function requestLogger(req, res, next) {
  const start = Date.now()
  
  // Log request
  console.log(`→ ${req.method} ${req.path}`)
  
  // Capture response
  const originalSend = res.send
  res.send = function(data) {
    res.send = originalSend
    res.send(data)
    
    const duration = Date.now() - start
    const status = res.statusCode
    const statusEmoji = status < 400 ? '✓' : '✗'
    
    console.log(`← ${statusEmoji} ${req.method} ${req.path} ${status} ${duration}ms`)
  }
  
  next()
}