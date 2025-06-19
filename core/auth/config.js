// SimplyKI Authentication Configuration

module.exports = {
  jwt: {
    algorithm: 'HS256',
    expiresIn: '1h',
    issuer: 'SimplyKI',
    audience: 'simplyKI-users'
  },
  
  users: {
    defaultRole: 'user',
    adminRole: 'admin',
    requiredPermissions: {
      'tools': ['read', 'execute'],
      'admin': ['read', 'write', 'execute', 'admin'],
      'api': ['read', 'write']
    }
  },
  
  security: {
    bcryptRounds: 12,
    sessionTimeout: 3600,
    maxLoginAttempts: 5,
    lockoutDuration: 900 // 15 Minuten
  }
};
