// SimplyKI Web UI - Main App Component
// Erstellt: 2025-07-24 16:00:00 CEST

import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import BrainMemory from './pages/BrainMemory'
import CostOptimizer from './pages/CostOptimizer'
import Sessions from './pages/Sessions'
import Projects from './pages/Projects'
import Settings from './pages/Settings'

export default function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/brain" element={<BrainMemory />} />
          <Route path="/cost" element={<CostOptimizer />} />
          <Route path="/sessions" element={<Sessions />} />
          <Route path="/projects" element={<Projects />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Layout>
    </Router>
  )
}