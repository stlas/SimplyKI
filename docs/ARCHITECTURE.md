# SimplyKI Architektur

## Überblick

SimplyKI ist als modulares Ecosystem konzipiert, bei dem jede Komponente eigenständig funktioniert, aber optimal im Verbund arbeitet.

## System-Architektur

```
┌─────────────────────────────────────────────────────────────────┐
│                        SimplyKI Ecosystem                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   ai-collab │  │ SmartKI-web  │  │   RemoteKI   │         │
│  │     (CLI)   │  │  (Frontend)  │  │ (Mobile App) │         │
│  └──────┬──────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                  │                  │
│         └─────────────────┴──────────────────┘                 │
│                           │                                     │
│                    ┌──────▼───────┐                           │
│                    │ SmartKI Core │                           │
│                    │  (API Gateway)│                           │
│                    └──────┬───────┘                           │
│         ┌─────────────────┼─────────────────┐                 │
│         │                 │                 │                 │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐         │
│  │ SmartKI-PM  │  │SmartKI-Obsid│  │SmartKI-Pango│         │
│  │ (Proj. Mgmt)│  │(Knowledge)  │  │  (Gateway)  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Komponenten-Details

### 1. ai-collab - KI-Entwicklungsassistent
- **Rolle**: Kern-Engine für KI-gestützte Entwicklung
- **Technologie**: Bash, Node.js
- **Schnittstellen**: CLI, File-based API
- **Datenfluss**: Sessions → SmartKI Core → PM/Obsidian

### 2. SmartKI Core - Backend Services
- **Rolle**: Zentrale API und Service-Orchestrierung
- **Technologie**: Node.js, Express, PostgreSQL
- **Services**:
  - API Gateway (Port 3200)
  - Service Discovery (Port 3201)
  - AI Orchestrator (Port 3202)
- **Protokolle**: REST, WebSocket, gRPC

### 3. SmartKI-web - Web Interface
- **Rolle**: Benutzeroberfläche für alle Services
- **Technologie**: React, TypeScript, Redux
- **Features**: Real-time Updates, Dashboards, Multi-Language

### 4. SmartKI-PM - Projektmanagement
- **Rolle**: Task und Projekt-Verwaltung
- **Technologie**: PHP (Kanboard), MySQL
- **Integration**: Webhook, REST API

### 5. SmartKI-Obsidian - Knowledge Base
- **Rolle**: Dokumentation und Wissensmanagement
- **Technologie**: Obsidian, REST API Plugin
- **Features**: Auto-Documentation, Cross-Linking

### 6. SmartKI-Pangolin - Internet Gateway
- **Rolle**: Sichere Exposition lokaler Services
- **Technologie**: Docker, WireGuard, Nginx
- **Features**: SSL, Domain Routing, Tunneling

### 7. RemoteKI - Mobile App
- **Rolle**: Mobiler Zugriff auf SimplyKI
- **Technologie**: React Native
- **Plattformen**: Android (iOS geplant)

## Datenflüsse

### Session-Lifecycle
1. User startet Session in ai-collab
2. ai-collab erstellt Session-Daten
3. SmartKI Core empfängt Session-Event
4. PM-System erstellt automatisch Task
5. Obsidian dokumentiert Session
6. Web-UI zeigt Real-time Updates

### API-Kommunikation
- Alle Services kommunizieren über SmartKI Core
- JWT-basierte Authentifizierung
- Rate Limiting und Caching
- Event-basierte Updates via WebSocket

## Deployment-Optionen

### 1. Standalone (Entwicklung)
- Jede Komponente läuft einzeln
- Lokale Entwicklung und Tests
- Minimal-Setup für einzelne Features

### 2. Docker Compose (Empfohlen)
- Alle Services in Containern
- Automatische Netzwerk-Konfiguration
- Ein-Klick-Deployment

### 3. Kubernetes (Enterprise)
- Skalierbare Microservices
- Load Balancing
- High Availability

### 4. Cloud-Native
- Serverless Functions
- Managed Databases
- Auto-Scaling

## Sicherheitsarchitektur

### Authentifizierung
- JWT Tokens mit Refresh-Mechanismus
- OAuth2 Support (geplant)
- API-Key Management

### Autorisierung
- Role-Based Access Control (RBAC)
- Service-zu-Service Auth
- Ressourcen-basierte Permissions

### Netzwerksicherheit
- TLS/SSL für alle Verbindungen
- VPN-Tunnels für Remote-Access
- Firewall-Regeln pro Service

## Performance-Optimierung

### Caching-Strategie
- Redis für Session-Cache
- CDN für statische Assets
- Database Query Cache

### Skalierung
- Horizontal: Mehr Service-Instanzen
- Vertikal: Größere Server
- Edge: Verteilte Deployments

## Monitoring & Observability

### Metrics
- Prometheus für System-Metrics
- Custom Metrics für Business-KPIs
- Real-time Dashboards

### Logging
- Zentralisiertes Logging (ELK Stack)
- Structured Logging
- Log Aggregation

### Tracing
- OpenTelemetry Integration
- Distributed Tracing
- Performance Profiling