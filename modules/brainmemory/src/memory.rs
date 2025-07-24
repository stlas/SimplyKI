// SimplyKI BrainMemory - Core Memory Implementation
// Erstellt: 2025-07-24 16:42:00 CEST

use std::collections::{HashMap, VecDeque};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Debug, Clone)]
pub struct BrainMemory {
    working_memory: HashMap<String, MemoryEntry>,
    long_term_memory: HashMap<String, MemoryEntry>,
    context_cache: VecDeque<String>,
    associations: HashMap<String, Vec<String>>,
    stats: MemoryStats,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct MemoryEntry {
    value: Value,
    timestamp: Instant,
    access_count: u32,
    last_accessed: Instant,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemoryStats {
    pub working_memory: MemoryInfo,
    pub long_term_memory: MemoryInfo,
    pub context_cache: CacheInfo,
    pub associations: AssociationInfo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemoryInfo {
    pub used: usize,
    pub total: usize,
    pub entries: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CacheInfo {
    pub size: usize,
    pub hits: u64,
    pub misses: u64,
    pub hit_rate: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AssociationInfo {
    pub nodes: usize,
    pub edges: usize,
    pub avg_degree: f64,
}

impl BrainMemory {
    pub fn new() -> Self {
        Self {
            working_memory: HashMap::new(),
            long_term_memory: HashMap::new(),
            context_cache: VecDeque::with_capacity(1000),
            associations: HashMap::new(),
            stats: MemoryStats {
                working_memory: MemoryInfo {
                    used: 0,
                    total: 256 * 1024 * 1024, // 256MB
                    entries: 0,
                },
                long_term_memory: MemoryInfo {
                    used: 0,
                    total: 4 * 1024 * 1024 * 1024, // 4GB
                    entries: 0,
                },
                context_cache: CacheInfo {
                    size: 0,
                    hits: 0,
                    misses: 0,
                    hit_rate: 0.0,
                },
                associations: AssociationInfo {
                    nodes: 0,
                    edges: 0,
                    avg_degree: 0.0,
                },
            },
        }
    }

    pub fn store(&mut self, key: &str, value: Value) {
        let entry = MemoryEntry {
            value: value.clone(),
            timestamp: Instant::now(),
            access_count: 0,
            last_accessed: Instant::now(),
        };

        // Store in working memory first
        self.working_memory.insert(key.to_string(), entry.clone());
        self.stats.working_memory.entries = self.working_memory.len();
        
        // Update context cache
        self.context_cache.push_front(key.to_string());
        if self.context_cache.len() > 1000 {
            self.context_cache.pop_back();
        }
        
        // Update associations
        self.update_associations(key);
    }

    pub fn retrieve(&self, key: &str) -> Option<Value> {
        // Check working memory first
        if let Some(entry) = self.working_memory.get(key) {
            return Some(entry.value.clone());
        }
        
        // Check long-term memory
        if let Some(entry) = self.long_term_memory.get(key) {
            return Some(entry.value.clone());
        }
        
        None
    }

    pub fn search(&self, query: &str, limit: usize) -> Vec<(String, f64)> {
        let mut results = Vec::new();
        
        // Simple substring search for demo
        for (key, _) in &self.working_memory {
            if key.contains(query) {
                let score = 1.0 - (key.len() as f64 - query.len() as f64) / key.len() as f64;
                results.push((key.clone(), score));
            }
        }
        
        // Sort by score
        results.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
        results.truncate(limit);
        
        results
    }

    pub fn optimize_memory(&mut self) {
        // Move old entries from working to long-term memory
        let threshold = Duration::from_secs(300); // 5 minutes
        let now = Instant::now();
        
        let mut to_move = Vec::new();
        for (key, entry) in &self.working_memory {
            if now.duration_since(entry.last_accessed) > threshold {
                to_move.push(key.clone());
            }
        }
        
        for key in to_move {
            if let Some(entry) = self.working_memory.remove(&key) {
                self.long_term_memory.insert(key, entry);
            }
        }
        
        // Update stats
        self.stats.working_memory.entries = self.working_memory.len();
        self.stats.long_term_memory.entries = self.long_term_memory.len();
    }

    pub fn get_stats(&self) -> MemoryStats {
        self.stats.clone()
    }

    fn update_associations(&mut self, key: &str) {
        // Simple association: link with recent context
        let recent: Vec<String> = self.context_cache
            .iter()
            .take(5)
            .cloned()
            .collect();
        
        self.associations.insert(key.to_string(), recent);
        
        // Update stats
        self.stats.associations.nodes = self.associations.len();
        let total_edges: usize = self.associations.values().map(|v| v.len()).sum();
        self.stats.associations.edges = total_edges;
        self.stats.associations.avg_degree = if self.associations.is_empty() {
            0.0
        } else {
            total_edges as f64 / self.associations.len() as f64
        };
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_store_and_retrieve() {
        let mut brain = BrainMemory::new();
        let value = serde_json::json!({"test": "data"});
        
        brain.store("test_key", value.clone());
        let retrieved = brain.retrieve("test_key");
        
        assert!(retrieved.is_some());
        assert_eq!(retrieved.unwrap(), value);
    }

    #[test]
    fn test_search() {
        let mut brain = BrainMemory::new();
        
        brain.store("test_key_1", serde_json::json!({"id": 1}));
        brain.store("test_key_2", serde_json::json!({"id": 2}));
        brain.store("other_key", serde_json::json!({"id": 3}));
        
        let results = brain.search("test", 10);
        assert_eq!(results.len(), 2);
        assert!(results[0].1 > 0.5); // Score should be reasonable
    }

    #[test]
    fn test_memory_optimization() {
        let mut brain = BrainMemory::new();
        
        brain.store("old_key", serde_json::json!({"old": true}));
        assert_eq!(brain.stats.working_memory.entries, 1);
        assert_eq!(brain.stats.long_term_memory.entries, 0);
        
        // Note: In real implementation, we'd need to mock time
        // For now, just test the function runs
        brain.optimize_memory();
    }
}