# SimplyKI Web UI

Moderne Web-Oberfläche für das SimplyKI Framework mit React, Vite und Tailwind CSS.

## Features

- **Dashboard**: Echtzeit-Übersicht über System-Status, Kosten und Aktivitäten
- **BrainMemory Monitor**: Visualisierung der Speichernutzung und Performance-Metriken
- **Kostenoptimierung**: Intelligente Modellauswahl basierend auf Aufgabe und Budget
- **Session-Management**: Persistente Sessions mit Parameter-Speicherung
- **Projekt-Verwaltung**: Übersicht und Verwaltung aller SimplyKI-Projekte
- **Einstellungen**: Zentrale Konfiguration von API-Keys, Defaults und UI

## Tech Stack

- **Frontend**: React 18 mit Hooks und Function Components
- **Build Tool**: Vite für schnelle Entwicklung und optimierte Builds
- **Styling**: Tailwind CSS mit Dark Mode Support
- **State Management**: Zustand für globalen State
- **Data Fetching**: TanStack Query (React Query) für Server State
- **Icons**: Lucide React für konsistente Icons
- **Routing**: React Router v6

## Installation

```bash
cd web-ui
npm install
```

## Entwicklung

```bash
# Entwicklungsserver starten
npm run dev

# Build erstellen
npm run build

# Preview des Builds
npm run preview

# Tests ausführen
npm run test

# Code formatieren
npm run format
```

## Projekt-Struktur

```
web-ui/
├── src/
│   ├── components/     # Wiederverwendbare Komponenten
│   ├── pages/         # Seiten-Komponenten
│   ├── lib/           # Utilities und Helper
│   ├── styles/        # Globale Styles
│   ├── hooks/         # Custom React Hooks
│   ├── store/         # Zustand Store
│   ├── App.jsx        # Haupt-App Komponente
│   └── main.jsx       # Entry Point
├── public/            # Statische Assets
├── index.html         # HTML Template
├── vite.config.js     # Vite Konfiguration
├── tailwind.config.js # Tailwind Konfiguration
└── package.json       # Dependencies

```

## API Integration

Die Web UI kommuniziert mit dem SimplyKI Backend über folgende Endpoints:

- `/api/*` - Hauptframework API (Port 8080)
- `/brain/*` - BrainMemory API (Port 5000)

## Entwicklungs-Richtlinien

1. **Komponenten**: Funktionale Komponenten mit Hooks verwenden
2. **Styling**: Tailwind CSS Klassen, keine inline styles
3. **State**: Lokaler State mit useState, globaler State mit Zustand
4. **TypeScript**: Vorbereitet für zukünftige Migration
5. **Performance**: React.memo für teure Komponenten, useMemo/useCallback wo sinnvoll

## Deployment

### Docker

```bash
# In Hauptverzeichnis
docker-compose up web-ui
```

### Standalone

```bash
npm run build
# Serve dist/ Verzeichnis mit einem Web-Server
```

## Konfiguration

Umgebungsvariablen in `.env`:

```env
VITE_API_URL=http://localhost:8080
VITE_BRAIN_URL=http://localhost:5000
```

## Geplante Features

- [ ] Echtzeit-Updates mit WebSockets
- [ ] Erweiterte Visualisierungen mit D3.js
- [ ] Export-Funktionen (PDF, CSV)
- [ ] Multi-Language Support
- [ ] PWA Support
- [ ] Keyboard Shortcuts
- [ ] Command Palette

## Contributing

1. Feature Branch erstellen
2. Änderungen committen
3. Tests schreiben/anpassen
4. Pull Request erstellen

## Lizenz

MIT - Teil des SimplyKI Projekts