// SimplyKI BrainMemory - Library Interface
// Erstellt: 2025-07-24 16:48:00 CEST

pub mod memory;
pub mod server;

pub use memory::{BrainMemory, MemoryStats};

/// Version information
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// Performance improvement factor over shell implementation
pub const PERFORMANCE_BOOST: f64 = 102.5;