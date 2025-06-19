// SimplyKI Plugin Registry
// Zentrale Verwaltung aller verfügbaren Plugins

class PluginRegistry {
  constructor() {
    this.plugins = new Map();
    this.loadedPlugins = new Set();
  }
  
  // Plugin registrieren
  register(pluginDefinition) {
    const { name, version, config } = pluginDefinition;
    
    if (!name) {
      throw new Error('Plugin name is required');
    }
    
    this.plugins.set(name, {
      ...pluginDefinition,
      registeredAt: new Date(),
      status: 'registered'
    });
    
    console.log(`✅ Plugin registered: ${name} v${version}`);
    return true;
  }
  
  // Plugin laden
  async load(pluginName) {
    const plugin = this.plugins.get(pluginName);
    if (!plugin) {
      throw new Error(`Plugin not found: ${pluginName}`);
    }
    
    try {
      // Plugin-Initialisierung
      if (plugin.onInit) {
        await plugin.onInit();
      }
      
      plugin.status = 'loaded';
      this.loadedPlugins.add(pluginName);
      
      console.log(`🚀 Plugin loaded: ${pluginName}`);
      return plugin;
    } catch (error) {
      plugin.status = 'error';
      console.error(`❌ Plugin load failed: ${pluginName}`, error);
      throw error;
    }
  }
  
  // Alle verfügbaren Plugins auflisten
  list() {
    return Array.from(this.plugins.entries()).map(([name, plugin]) => ({
      name,
      version: plugin.version,
      description: plugin.description,
      status: plugin.status,
      registeredAt: plugin.registeredAt
    }));
  }
  
  // Plugin-Auto-Discovery
  async discoverPlugins(toolsDirectory = './tools') {
    const fs = require('fs').promises;
    const path = require('path');
    
    try {
      const toolDirs = await fs.readdir(toolsDirectory);
      
      for (const toolDir of toolDirs) {
        const pluginPath = path.join(toolsDirectory, toolDir, 'simplyKI-plugin.js');
        
        try {
          await fs.access(pluginPath);
          const plugin = require(path.resolve(pluginPath));
          
          if (plugin.default || plugin.name) {
            this.register(plugin.default || plugin);
          }
        } catch (err) {
          // Plugin-Datei nicht gefunden oder ungültig - überspringen
          continue;
        }
      }
      
      console.log(`🔍 Auto-discovery completed. Found ${this.plugins.size} plugins.`);
    } catch (error) {
      console.error('Plugin auto-discovery failed:', error);
    }
  }
}

module.exports = PluginRegistry;
