# Contributing to SimplyKI

Danke für dein Interesse, zu SimplyKI beizutragen! 🎉

## 🤝 Wie du beitragen kannst

### 1. Bugs melden
- Nutze das [Issue Template](https://github.com/stlas/SimplyKI/issues/new?template=bug_report.md)
- Beschreibe das Problem detailliert
- Füge Logs und Screenshots bei

### 2. Features vorschlagen
- Erstelle ein [Feature Request](https://github.com/stlas/SimplyKI/issues/new?template=feature_request.md)
- Erkläre den Use Case
- Diskutiere mit der Community

### 3. Code beitragen
- Fork das Repository
- Erstelle einen Feature Branch
- Schreibe Tests für neue Features
- Erstelle einen Pull Request

### 4. Dokumentation verbessern
- Korrigiere Tippfehler
- Füge Beispiele hinzu
- Übersetze in andere Sprachen

## 🔧 Development Setup

```bash
# Repository forken und clonen
git clone https://github.com/DEIN-USERNAME/SimplyKI.git
cd SimplyKI

# Upstream hinzufügen
git remote add upstream https://github.com/stlas/SimplyKI.git

# Dependencies installieren
./install.sh --dev

# Feature Branch erstellen
git checkout -b feature/mein-feature
```

## 📝 Code Style

### JavaScript/TypeScript
- ESLint Konfiguration befolgen
- Prettier für Formatierung
- TypeScript für neue Features

### Bash Scripts
- ShellCheck verwenden
- POSIX-kompatibel wenn möglich
- Ausführliche Kommentare

### Commits
- Conventional Commits Format
- Aussagekräftige Commit Messages
- Atomic Commits

Beispiele:
```
feat: Add user authentication to web interface
fix: Resolve memory leak in session manager
docs: Update installation guide for macOS
```

## 🧪 Testing

### Unit Tests
```bash
npm test
```

### Integration Tests
```bash
npm run test:integration
```

### E2E Tests
```bash
npm run test:e2e
```

## 📋 Pull Request Process

1. **Branch aktualisieren**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Tests ausführen**
   ```bash
   npm test
   npm run lint
   ```

3. **PR erstellen**
   - Nutze das PR Template
   - Referenziere related Issues
   - Beschreibe die Änderungen

4. **Review abwarten**
   - Mindestens 1 Approval nötig
   - CI Tests müssen grün sein
   - Feedback umsetzen

## 🏗️ Projekt-Struktur

```
SimplyKI/
├── components/          # Einzelne Komponenten
│   ├── ai-collab/      # KI-Assistent
│   ├── SmartKI/        # Core Backend
│   └── ...
├── docs/               # Dokumentation
├── tests/              # Test Suites
└── scripts/            # Build & Deploy Scripts
```

## 🌐 Übersetzungen

Hilf uns, SimplyKI international zu machen:

1. Kopiere `locales/en.json`
2. Übersetze in deine Sprache
3. Erstelle PR mit `i18n: Add [language] translation`

## 🎯 Fokus-Bereiche

Besonders gesucht:
- **Performance**: Optimierungen für große Projekte
- **Security**: Sicherheitsaudits und Fixes
- **UX**: Verbesserungen der Benutzerfreundlichkeit
- **Plugins**: Neue Integrationen

## 📜 Code of Conduct

Bitte beachte unseren [Code of Conduct](CODE_OF_CONDUCT.md).

## 📞 Kontakt

- **Discord**: [SimplyKI Dev Channel](https://discord.gg/simplyki-dev)
- **Email**: dev@simplyki.com
- **GitHub Discussions**: [Forum](https://github.com/stlas/SimplyKI/discussions)

## 🙏 Danke!

Jeder Beitrag macht SimplyKI besser. Danke für deine Zeit und Mühe!

---

**Happy Coding!** 🚀