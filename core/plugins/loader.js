// SimplyKI Plugin Loader
// Lädt und verwaltet Plugin-Lifecycle

const PluginRegistry = require('./registry');

class PluginLoader {
  constructor(config = {}) {
    this.registry = new PluginRegistry();
    this.config = config;
    this.activePlugins = new Map();
  }
  
  // Alle Plugins initialisieren
  async initialize() {
    console.log('🔧 Initializing SimplyKI Plugin System...');
    
    // Auto-Discovery falls aktiviert
    if (this.config.autoDiscovery) {
      await this.registry.discoverPlugins(this.config.toolsDirectory);
    }
    
    // Enabled Tools laden
    if (this.config.enabledTools) {
      for (const toolName of this.config.enabledTools) {
        try {
          await this.loadPlugin(toolName);
        } catch (error) {
          console.warn(`⚠️ Failed to load enabled tool: ${toolName}`, error.message);
        }
      }
    }
    
    console.log(`✅ Plugin System initialized. ${this.activePlugins.size} plugins active.`);
  }
  
  // Einzelnes Plugin laden
  async loadPlugin(pluginName) {
    try {
      const plugin = await this.registry.load(pluginName);
      this.activePlugins.set(pluginName, plugin);
      
      // Plugin aktivieren
      if (plugin.onActivate) {
        await plugin.onActivate();
      }
      
      return plugin;
    } catch (error) {
      console.error(`Failed to load plugin: ${pluginName}`, error);
      throw error;
    }
  }
  
  // Plugin deaktivieren
  async unloadPlugin(pluginName) {
    const plugin = this.activePlugins.get(pluginName);
    if (!plugin) return;
    
    try {
      if (plugin.onDeactivate) {
        await plugin.onDeactivate();
      }
      
      this.activePlugins.delete(pluginName);
      console.log(`🔌 Plugin unloaded: ${pluginName}`);
    } catch (error) {
      console.error(`Failed to unload plugin: ${pluginName}`, error);
    }
  }
  
  // Plugin-Status abrufen
  getStatus() {
    return {
      total: this.registry.plugins.size,
      active: this.activePlugins.size,
      plugins: this.registry.list(),
      activePlugins: Array.from(this.activePlugins.keys())
    };
  }
}

module.exports = PluginLoader;
