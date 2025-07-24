# SimplyKI Web UI Konzept
<!-- Erstellt: 2025-07-24 14:40:00 CEST -->

## 🎯 Vision

Eine moderne, responsive Web-Oberfläche für SimplyKI, die alle Module zentral zugänglich macht und Echtzeit-Einblicke in AI-Entwicklungsprozesse bietet.

## 🏗️ Architektur

### Frontend Stack
- **Framework**: React 18+ mit TypeScript
- **UI Library**: Tailwind CSS + shadcn/ui
- **State Management**: Zustand
- **Real-time**: WebSockets für Live-Updates
- **Charts**: Recharts für Visualisierungen

### Backend Integration
- **API**: REST + WebSocket (Axum)
- **Auth**: JWT-basiert
- **Database**: SQLite für Persistenz
- **Cache**: In-Memory für Performance

## 📱 Core Features

### 1. Dashboard
```
┌─────────────────────────────────────────┐
│ SimplyKI Dashboard                   ⚙️ │
├─────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│ │ Active  │ │ Cost    │ │ Memory  │   │
│ │ Sessions│ │ Today   │ │ Usage   │   │
│ │   12    │ │ $3.45   │ │ 2.3 GB  │   │
│ └─────────┘ └─────────┘ └─────────┘   │
│                                         │
│ Recent Activities          Performance  │
│ ├─ Query processed        ┌──────────┐ │
│ ├─ Model selected         │ Chart    │ │
│ └─ Context cached         └──────────┘ │
└─────────────────────────────────────────┘
```

### 2. Module Manager
- **Übersicht** aller installierten Module
- **Status** (Active, Inactive, Error)
- **Controls** (Start, Stop, Configure)
- **Logs** in Echtzeit

### 3. BrainMemory Explorer
- **Working Memory** Visualisierung
- **Context History** Timeline
- **Association Network** Graph
- **Performance Metrics** Live

### 4. Cost Analytics
- **Budget Tracking** mit Alerts
- **Model Usage** Breakdown
- **ROI Analysis** pro Projekt
- **Forecast** basierend auf Trends

### 5. Session Manager
- **Active Sessions** Liste
- **Session History** mit Suche
- **Restore** vergangene Sessions
- **Export** Session-Daten

## 🎨 UI Components

### Design System
```typescript
// Farbschema
const colors = {
  primary: '#3B82F6',    // Blue
  secondary: '#10B981',  // Green
  danger: '#EF4444',     // Red
  warning: '#F59E0B',    // Amber
  dark: '#1F2937',       // Gray-800
  light: '#F9FAFB'       // Gray-50
}

// Komponenten
- Button (Primary, Secondary, Ghost)
- Card (Module, Metric, Activity)
- Chart (Line, Bar, Pie)
- Table (Sortable, Filterable)
- Modal (Confirm, Form, Info)
- Toast (Success, Error, Info)
```

### Responsive Layout
- **Desktop**: Full Dashboard mit Sidebar
- **Tablet**: Collapsible Sidebar
- **Mobile**: Bottom Navigation

## 🔌 API Endpoints

### REST API
```
GET    /api/status          # System status
GET    /api/modules         # List modules
POST   /api/modules/:id     # Control module
GET    /api/sessions        # List sessions
GET    /api/costs           # Cost data
GET    /api/memory          # Memory stats
```

### WebSocket Events
```
ws://localhost:3000/ws

// Server → Client
{ type: "module_status", data: { id, status } }
{ type: "memory_update", data: { stats } }
{ type: "cost_alert", data: { message } }

// Client → Server
{ type: "subscribe", channel: "memory" }
{ type: "module_action", data: { id, action } }
```

## 🚀 Implementation Plan

### Phase 1: MVP (2 Wochen)
- [ ] Basic React Setup
- [ ] Dashboard mit Mock-Daten
- [ ] Module Liste (Read-only)
- [ ] Simple Cost Display

### Phase 2: Integration (2 Wochen)
- [ ] REST API in Rust
- [ ] Real Module Control
- [ ] Session Management
- [ ] Basic Auth

### Phase 3: Advanced (2 Wochen)
- [ ] WebSocket Integration
- [ ] BrainMemory Visualizer
- [ ] Advanced Analytics
- [ ] Export Features

### Phase 4: Polish (1 Woche)
- [ ] Performance Optimization
- [ ] Error Handling
- [ ] Documentation
- [ ] Deploy Scripts

## 🛠️ Development Setup

```bash
# Frontend
cd web-ui
npm install
npm run dev

# Backend (Rust API)
cd api
cargo run

# Full Stack
docker-compose up
```

## 📊 Success Metrics

- **Page Load**: < 1s
- **API Response**: < 100ms
- **Memory Usage**: < 50MB
- **Accessibility**: WCAG 2.1 AA

## 🔒 Security

- HTTPS only
- JWT mit Refresh Tokens
- Rate Limiting
- Input Validation
- XSS Protection

## 🎯 Next Steps

1. **Prototype** mit Figma/Excalidraw
2. **Tech Stack** finalisieren
3. **API Design** dokumentieren
4. **Start MVP** Development

---

**Geschätzte Zeit**: 7 Wochen für Full Implementation
**Team**: 1-2 Entwickler
**Budget**: Hauptsächlich Zeit-Investment