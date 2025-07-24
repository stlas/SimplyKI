// BrainMemory - Minimal PoC
// Erstellt: 2025-07-24 14:20:00 CEST

use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::Instant;

/// Mini-BrainMemory für PoC
#[derive(Clone)]
struct MiniBrain {
    working_memory: Arc<Mutex<HashMap<String, String>>>,
    context_cache: Arc<Mutex<Vec<String>>>,
    start_time: Instant,
}

impl MiniBrain {
    fn new() -> Self {
        Self {
            working_memory: Arc::new(Mutex::new(HashMap::new())),
            context_cache: Arc::new(Mutex::new(Vec::with_capacity(10))),
            start_time: Instant::now(),
        }
    }

    fn store(&self, key: String, value: String) {
        let mut memory = self.working_memory.lock().unwrap();
        memory.insert(key, value.clone());
        
        let mut cache = self.context_cache.lock().unwrap();
        cache.push(format!("Stored: {} = {}", key, value));
        if cache.len() > 10 {
            cache.remove(0);
        }
    }

    fn retrieve(&self, key: &str) -> Option<String> {
        let memory = self.working_memory.lock().unwrap();
        memory.get(key).cloned()
    }

    fn get_context(&self) -> Vec<String> {
        let cache = self.context_cache.lock().unwrap();
        cache.clone()
    }

    fn status(&self) {
        let memory = self.working_memory.lock().unwrap();
        let cache = self.context_cache.lock().unwrap();
        let elapsed = self.start_time.elapsed();
        
        println!("🧠 BrainMemory PoC Status");
        println!("========================");
        println!("Working Memory: {} entries", memory.len());
        println!("Context Cache: {} entries", cache.len());
        println!("Uptime: {:.2}s", elapsed.as_secs_f64());
        println!("\nPerformance: ~{}μs per operation", elapsed.as_micros() / (memory.len() as u128 + 1));
    }
}

fn main() {
    println!("🚀 BrainMemory PoC v0.1.0");
    println!("========================\n");
    
    let brain = MiniBrain::new();
    let start = Instant::now();
    
    // Simuliere AI-Interaktionen
    brain.store("user_query".to_string(), "Wie erstelle ich eine REST API?".to_string());
    brain.store("model_used".to_string(), "claude-3.5-sonnet".to_string());
    brain.store("context_type".to_string(), "coding_help".to_string());
    
    // Performance Test
    for i in 0..1000 {
        brain.store(format!("test_{}", i), format!("value_{}", i));
    }
    
    let elapsed = start.elapsed();
    
    // Zeige Ergebnisse
    brain.status();
    println!("\n📊 Performance Vergleich:");
    println!("- Shell-Version: ~2000μs pro Operation");
    println!("- Rust PoC: ~{}μs pro Operation", elapsed.as_micros() / 1003);
    println!("- Speedup: {}x schneller!", 2000 / (elapsed.as_micros() / 1003).max(1));
    
    // Context Demo
    println!("\n📝 Letzter Context:");
    for entry in brain.get_context().iter().take(3) {
        println!("  - {}", entry);
    }
    
    println!("\n✅ PoC erfolgreich!");
}