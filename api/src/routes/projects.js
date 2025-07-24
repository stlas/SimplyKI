// SimplyKI API - Projects Routes
// Erstellt: 2025-07-24 16:30:00 CEST

import { Router } from 'express'
import { readFile, writeFile, readdir, stat } from 'fs/promises'
import { exec } from 'child_process'
import { promisify } from 'util'
import path from 'path'
import Joi from 'joi'
import { ValidationError, NotFoundError } from '../middleware/errorHandler.js'

const router = Router()
const execAsync = promisify(exec)
const PROJECTS_CONFIG = '/home/aicollab/local/config/projects.json'

// Validation schema
const projectSchema = Joi.object({
  path: Joi.string().required(),
  name: Joi.string().min(3).max(100),
  description: Joi.string().max(500),
  type: Joi.string().valid('framework', 'tool', 'web', 'integration', 'other')
})

// Get all projects
router.get('/', async (req, res, next) => {
  try {
    // Read projects config
    const content = await readFile(PROJECTS_CONFIG, 'utf-8')
    const projectsConfig = JSON.parse(content)
    
    // Enhance with live data
    const projects = await Promise.all(
      Object.entries(projectsConfig).map(async ([id, project]) => {
        const stats = await getProjectStats(project.path)
        return {
          id,
          ...project,
          ...stats
        }
      })
    )

    res.json(projects)
  } catch (error) {
    // Return mock data if config doesn't exist
    const mockProjects = [
      {
        id: 'simplyKI',
        name: 'SimplyKI',
        description: 'Gehirn-inspiriertes KI-Entwicklungsframework',
        path: '/home/aicollab/SimplyKI-repo',
        type: 'framework',
        language: 'Rust/Shell',
        lastModified: new Date().toISOString(),
        size: 45 * 1024 * 1024,
        status: 'active',
        github: 'https://github.com/stlas/SimplyKI'
      },
      {
        id: 'csv2actual',
        name: 'CSV2Actual',
        description: 'PowerShell CSV-Verarbeitungstool',
        path: '/home/aicollab/projects/CSV2Actual',
        type: 'tool',
        language: 'PowerShell',
        lastModified: new Date(Date.now() - 86400000).toISOString(),
        size: 12 * 1024 * 1024,
        status: 'active',
        github: 'https://github.com/stlas/CSV2Actual'
      }
    ]
    
    res.json(mockProjects)
  }
})

// Get project by ID
router.get('/:id', async (req, res, next) => {
  try {
    const content = await readFile(PROJECTS_CONFIG, 'utf-8')
    const projects = JSON.parse(content)
    
    const project = projects[req.params.id]
    if (!project) {
      return next(new NotFoundError('Project not found'))
    }

    const stats = await getProjectStats(project.path)
    const details = await getProjectDetails(project.path)

    res.json({
      id: req.params.id,
      ...project,
      ...stats,
      ...details
    })
  } catch (error) {
    if (error.code === 'ENOENT') {
      return next(new NotFoundError('Project not found'))
    }
    next(error)
  }
})

// Add new project
router.post('/', async (req, res, next) => {
  try {
    // Validate input
    const { error, value } = projectSchema.validate(req.body)
    if (error) {
      return next(new ValidationError('Invalid project data', error.details))
    }

    // Check if path exists
    try {
      await stat(value.path)
    } catch (error) {
      return next(new ValidationError('Project path does not exist'))
    }

    // Read existing projects
    let projects = {}
    try {
      const content = await readFile(PROJECTS_CONFIG, 'utf-8')
      projects = JSON.parse(content)
    } catch (error) {
      // File doesn't exist, start with empty object
    }

    // Generate ID
    const id = value.name ? 
      value.name.toLowerCase().replace(/\s+/g, '-') : 
      path.basename(value.path)

    // Detect project info
    const info = await detectProjectInfo(value.path)

    // Add project
    projects[id] = {
      ...value,
      ...info,
      added: new Date().toISOString()
    }

    // Save projects
    await writeFile(PROJECTS_CONFIG, JSON.stringify(projects, null, 2))

    res.status(201).json({
      id,
      ...projects[id]
    })
  } catch (error) {
    next(error)
  }
})

// Update project
router.put('/:id', async (req, res, next) => {
  try {
    const content = await readFile(PROJECTS_CONFIG, 'utf-8')
    const projects = JSON.parse(content)
    
    if (!projects[req.params.id]) {
      return next(new NotFoundError('Project not found'))
    }

    // Update project
    projects[req.params.id] = {
      ...projects[req.params.id],
      ...req.body,
      modified: new Date().toISOString()
    }

    await writeFile(PROJECTS_CONFIG, JSON.stringify(projects, null, 2))

    res.json({
      id: req.params.id,
      ...projects[req.params.id]
    })
  } catch (error) {
    next(error)
  }
})

// Delete project
router.delete('/:id', async (req, res, next) => {
  try {
    const content = await readFile(PROJECTS_CONFIG, 'utf-8')
    const projects = JSON.parse(content)
    
    if (!projects[req.params.id]) {
      return next(new NotFoundError('Project not found'))
    }

    delete projects[req.params.id]
    
    await writeFile(PROJECTS_CONFIG, JSON.stringify(projects, null, 2))

    res.status(204).send()
  } catch (error) {
    next(error)
  }
})

// Get project files
router.get('/:id/files', async (req, res, next) => {
  try {
    const content = await readFile(PROJECTS_CONFIG, 'utf-8')
    const projects = JSON.parse(content)
    
    const project = projects[req.params.id]
    if (!project) {
      return next(new NotFoundError('Project not found'))
    }

    // Get file tree
    const { stdout } = await execAsync(`find ${project.path} -type f -name "*.${getExtension(project.language)}" | head -100`)
    const files = stdout.trim().split('\n').filter(Boolean).map(file => ({
      path: file,
      name: path.basename(file),
      relative: file.replace(project.path + '/', '')
    }))

    res.json(files)
  } catch (error) {
    next(error)
  }
})

// Helper functions
async function getProjectStats(projectPath) {
  try {
    const stats = await stat(projectPath)
    
    // Get directory size
    const { stdout: sizeOutput } = await execAsync(`du -sb ${projectPath} | cut -f1`)
    const size = parseInt(sizeOutput.trim())

    // Get file count
    const { stdout: fileCount } = await execAsync(`find ${projectPath} -type f | wc -l`)

    return {
      size,
      fileCount: parseInt(fileCount.trim()),
      lastModified: stats.mtime.toISOString()
    }
  } catch (error) {
    return {
      size: 0,
      fileCount: 0,
      lastModified: new Date().toISOString()
    }
  }
}

async function getProjectDetails(projectPath) {
  try {
    // Get git info
    const { stdout: gitStatus } = await execAsync(`cd ${projectPath} && git status --porcelain | wc -l`)
    const { stdout: gitBranch } = await execAsync(`cd ${projectPath} && git branch --show-current`)
    const { stdout: gitCommits } = await execAsync(`cd ${projectPath} && git rev-list --count HEAD`)
    const { stdout: gitRemote } = await execAsync(`cd ${projectPath} && git remote get-url origin 2>/dev/null || echo ""`)

    return {
      git: {
        branch: gitBranch.trim(),
        uncommittedChanges: parseInt(gitStatus.trim()),
        totalCommits: parseInt(gitCommits.trim()),
        remote: gitRemote.trim()
      }
    }
  } catch (error) {
    return {
      git: {
        branch: 'main',
        uncommittedChanges: 0,
        totalCommits: 0,
        remote: ''
      }
    }
  }
}

async function detectProjectInfo(projectPath) {
  const info = {
    type: 'other',
    language: 'Unknown',
    github: ''
  }

  try {
    // Detect language
    const files = await readdir(projectPath)
    
    if (files.includes('Cargo.toml')) {
      info.language = 'Rust'
      info.type = 'tool'
    } else if (files.includes('package.json')) {
      const pkg = JSON.parse(await readFile(path.join(projectPath, 'package.json'), 'utf-8'))
      info.language = 'JavaScript/TypeScript'
      info.type = pkg.dependencies?.react ? 'web' : 'tool'
    } else if (files.includes('requirements.txt') || files.includes('setup.py')) {
      info.language = 'Python'
      info.type = 'tool'
    } else if (files.some(f => f.endsWith('.ps1'))) {
      info.language = 'PowerShell'
      info.type = 'tool'
    } else if (files.some(f => f.endsWith('.sh'))) {
      info.language = 'Shell'
      info.type = 'tool'
    }

    // Get GitHub URL
    try {
      const { stdout } = await execAsync(`cd ${projectPath} && git remote get-url origin`)
      info.github = stdout.trim().replace('.git', '')
    } catch (error) {
      // No git remote
    }
  } catch (error) {
    // Ignore errors
  }

  return info
}

function getExtension(language) {
  const extensions = {
    'Rust': 'rs',
    'JavaScript': 'js',
    'TypeScript': 'ts',
    'Python': 'py',
    'PowerShell': 'ps1',
    'Shell': 'sh'
  }
  
  return extensions[language.split('/')[0]] || '*'
}

export default router