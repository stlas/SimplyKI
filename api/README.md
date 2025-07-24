# SimplyKI API

RESTful API Backend für das SimplyKI Framework mit WebSocket Support für Echtzeit-Updates.

## Features

- **RESTful API**: Vollständige API für alle SimplyKI-Funktionen
- **WebSocket Support**: Echtzeit-Updates für Dashboard und Monitoring
- **Authentication**: JWT-basierte Authentifizierung
- **Rate Limiting**: Schutz vor Überlastung
- **CORS Support**: Konfigurierbar für Web UI
- **Error Handling**: Konsistente Fehlerbehandlung
- **Caching**: Intelligentes Caching für Performance

## Endpoints

### System Status
- `GET /health` - Health Check
- `GET /api/status` - System Status
- `GET /api/status/metrics` - Detaillierte Metriken

### Sessions
- `GET /api/sessions` - Alle Sessions abrufen
- `GET /api/sessions/:id` - Einzelne Session
- `POST /api/sessions` - Neue Session erstellen
- `PUT /api/sessions/:id` - Session aktualisieren
- `DELETE /api/sessions/:id` - Session löschen
- `POST /api/sessions/:id/restore` - Session wiederherstellen
- `POST /api/sessions/:id/snapshot` - Snapshot erstellen

### Cost Optimization
- `POST /api/cost/optimize` - Optimale Modellauswahl
- `GET /api/cost/stats` - Kostenstatistiken
- `GET /api/cost/history` - Kostenverlauf
- `POST /api/cost/template/:name` - Template anwenden

### BrainMemory
- `GET /api/brain/status` - BrainMemory Status
- `GET /api/brain/memory` - Speicherstatistiken
- `GET /api/brain/performance` - Performance-Metriken
- `POST /api/brain/benchmark` - Benchmark ausführen
- `POST /api/brain/store` - Daten speichern
- `GET /api/brain/retrieve/:key` - Daten abrufen
- `POST /api/brain/search` - Suche durchführen
- `GET /api/brain/associations/:key` - Assoziationen abrufen

### Projects
- `GET /api/projects` - Alle Projekte
- `GET /api/projects/:id` - Einzelnes Projekt
- `POST /api/projects` - Projekt hinzufügen
- `PUT /api/projects/:id` - Projekt aktualisieren
- `DELETE /api/projects/:id` - Projekt entfernen
- `GET /api/projects/:id/files` - Projektdateien

### Settings
- `GET /api/settings` - Einstellungen abrufen
- `PUT /api/settings` - Einstellungen aktualisieren
- `GET /api/settings/:category/:key` - Einzelne Einstellung
- `POST /api/settings/validate-api-key` - API-Key validieren
- `GET /api/settings/export` - Einstellungen exportieren
- `POST /api/settings/import` - Einstellungen importieren
- `POST /api/settings/reset` - Einstellungen zurücksetzen

## WebSocket Events

### Channels
- `status` - System-Status Updates
- `sessions` - Session-Änderungen
- `brain-memory` - BrainMemory Updates
- `brain-benchmark` - Benchmark-Ergebnisse
- `cost` - Kosten-Updates

### Subscription
```javascript
ws.send(JSON.stringify({
  type: 'subscribe',
  channels: ['status', 'brain-memory']
}))
```

## Installation

```bash
cd api
npm install
```

## Konfiguration

Erstellen Sie eine `.env` Datei basierend auf `.env.example`:

```env
NODE_ENV=development
PORT=8080
JWT_SECRET=your-secret-key
CORS_ORIGIN=http://localhost:3000
```

## Entwicklung

```bash
# Entwicklungsserver mit Auto-Reload
npm run dev

# Production Server
npm start

# Tests ausführen
npm test

# Linting
npm run lint
```

## Authentication

### Token generieren
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'
```

### Token verwenden
```bash
curl http://localhost:8080/api/sessions \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Development Mode

Im Development Mode kann Authentication übersprungen werden:

```env
NODE_ENV=development
SKIP_AUTH=true
```

## Error Response Format

```json
{
  "error": {
    "status": 400,
    "message": "Validation Error",
    "details": [...],
    "timestamp": "2025-07-24T14:00:00.000Z"
  }
}
```

## Rate Limiting

- Standard: 100 Requests pro 15 Minuten
- Auth Endpoints: 5 Requests pro 15 Minuten

## CORS

Konfigurierbar über `CORS_ORIGIN` Environment Variable.

## Deployment

### Docker

```bash
docker build -t simplyKI-api .
docker run -p 8080:8080 simplyKI-api
```

### PM2

```bash
pm2 start server.js --name simplyKI-api
pm2 save
pm2 startup
```

## Monitoring

- Health Check: `/health`
- Metrics: `/api/status/metrics`
- Logs: Konfigurierbar über `LOG_LEVEL`

## Sicherheit

- Helmet.js für Security Headers
- Rate Limiting gegen DDoS
- Input Validation mit Joi
- JWT Token Expiry
- API Key Masking
- CORS Protection

## Contributing

1. Feature Branch erstellen
2. Tests schreiben
3. Linting beachten
4. Pull Request erstellen

## Lizenz

MIT - Teil des SimplyKI Projekts