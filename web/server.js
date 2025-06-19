// SimplyKI Development Server
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.SIMPLYKI_PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'dist')));

// API Routes
app.get('/api/v1/status', (req, res) => {
  res.json({
    status: 'ok',
    platform: 'SimplyKI',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

app.get('/api/v1/tools', (req, res) => {
  res.json({
    tools: [
      {
        name: 'ai-collab',
        version: '2.1.0',
        status: 'active',
        description: 'AI Development Collaboration Assistant'
      }
    ]
  });
});

// SPA Fallback
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`🌐 SimplyKI Web Server running on http://localhost:${PORT}`);
  console.log(`📊 API available at http://localhost:${PORT}/api/v1`);
});
