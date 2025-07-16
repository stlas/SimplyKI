# SimplyKI Quick Start Guide

## 🚀 In 5 Minuten zum ersten KI-Projekt

### 1. Installation (2 Minuten)

```bash
# SimplyKI herunterladen und installieren
curl -sSL https://raw.githubusercontent.com/stlas/SimplyKI/main/install.sh | bash
```

Oder manuell:
```bash
git clone https://github.com/stlas/SimplyKI.git
cd SimplyKI
./install.sh
```

### 2. Konfiguration (1 Minute)

```bash
# In das SimplyKI Verzeichnis wechseln
cd ~/SimplyKI

# API-Key konfigurieren
cp config/.env.template config/.env
nano config/.env

# Füge deinen Anthropic API-Key ein:
# ANTHROPIC_API_KEY=sk-ant-api03-...
```

### 3. Start (30 Sekunden)

```bash
# SimplyKI starten
./start-simplyki.sh
```

### 4. Erste KI-Session (1,5 Minuten)

```bash
# Wechsle zu deinem Projekt
cd ~/mein-projekt

# Starte eine KI-Session
~/SimplyKI/components/ai-collab/core/src/ai-collab.sh optimize "Erstelle eine REST API mit Express.js"
```

### 5. Web Interface öffnen (30 Sekunden)

Öffne deinen Browser: http://localhost:3000

---

## 🎯 Was du jetzt kannst

✅ **KI-gestützte Entwicklung** - Lass dir von der KI beim Coden helfen  
✅ **Kosten sparen** - Automatische Modellauswahl spart bis zu 90%  
✅ **Sessions verwalten** - Dein Kontext bleibt erhalten  
✅ **Projekte tracken** - Siehe Fortschritt im Web Interface  

## 📚 Nächste Schritte

### Projekt hinzufügen
```bash
~/SimplyKI/components/ai-collab/core/src/ai-collab.sh add-project /pfad/zu/projekt "Projektname"
```

### Templates nutzen
```bash
# Zeige verfügbare Templates
~/SimplyKI/components/ai-collab/core/src/ai-collab.sh template list

# Template verwenden
~/SimplyKI/components/ai-collab/core/src/ai-collab.sh template code-review
```

### Session wiederherstellen
```bash
# Letzte Session fortsetzen
~/SimplyKI/components/ai-collab/core/src/ai-collab.sh start
```

## 🆘 Hilfe

- **Dokumentation**: https://github.com/stlas/SimplyKI/wiki
- **Issues**: https://github.com/stlas/SimplyKI/issues
- **Community**: Coming soon!

## 💡 Pro-Tipps

1. **Alias erstellen** für schnelleren Zugriff:
   ```bash
   echo "alias ski='~/SimplyKI/components/ai-collab/core/src/ai-collab.sh'" >> ~/.bashrc
   source ~/.bashrc
   # Jetzt kannst du einfach 'ski optimize "..."' verwenden
   ```

2. **Budget setzen** um Kosten zu kontrollieren:
   ```bash
   ski set-budget 50.00  # $50 Budget
   ```

3. **Status prüfen** jederzeit:
   ```bash
   ski status
   ```

---

**Fertig!** Du nutzt jetzt SimplyKI für intelligente Softwareentwicklung 🎉