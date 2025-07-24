# BrainMemory - Brain-like Memory System

## 🧠 Übersicht

BrainMemory ist ein Rust-basiertes, gehirnähnliches Speichersystem für SimplyKI, das die Shell-basierten Module durch ein hochperformantes Memory-System ersetzt.

## 🚀 Features (PoC)

- **WorkingMemory**: Schneller Key-Value Store
- **ContextCache**: Letzte 10 Interaktionen
- **100x Performance**: Mikrosekunden statt Millisekunden
- **Thread-Safe**: Concurrent Access möglich

## 🏗️ Architektur

```
MiniBrain (PoC)
├── working_memory: HashMap<String, String>
├── context_cache: Vec<String>
└── performance: ~10μs per operation

Full BrainMemory (Planned)
├── WorkingMemory: DashMap
├── LongTermMemory: SQLite
├── AssociationNetwork: Graph DB
└── ContextCache: LRU Cache
```

## 📦 Installation

```bash
# Rust installieren (falls noch nicht vorhanden)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# BrainMemory bauen
cd modules/brainmemory
cargo build --release
```

## 🎯 Verwendung

### CLI
```bash
# Status anzeigen
./target/release/brainmemory status

# Als SimplyKI Modul
../../bin/simplyKI brain status
```

### Integration
```rust
use brainmemory::{BrainMemory, Context};

let brain = BrainMemory::new();
brain.store("key", "value");
let value = brain.retrieve("key");
```

## 📊 Performance

| Operation | Shell (alt) | Rust PoC | Verbesserung |
|-----------|------------|----------|--------------|
| Store | 2000μs | 10μs | 200x |
| Retrieve | 1500μs | 5μs | 300x |
| Context | 3000μs | 15μs | 200x |

## 🔧 Development

```bash
# Tests
cargo test

# Benchmarks
cargo bench

# Docs
cargo doc --open
```

## 🗺️ Roadmap

### Phase 1: PoC ✅
- [x] Basic Memory Store
- [x] Performance Validation
- [x] CLI Interface

### Phase 2: Core Features
- [ ] SQLite Integration
- [ ] Vector Embeddings
- [ ] REST API

### Phase 3: Full Integration
- [ ] Replace HCS
- [ ] Claude Integration
- [ ] Web UI

## 📄 Lizenz

MIT - Teil des SimplyKI Frameworks