(function() {
  var components, loadedComponents, pluginSetting;

  pluginSetting = {};

  loadedComponents = Object.keys(pluginSetting);

  components = loadedComponents.map(function(component) {
    return pluginSetting[component].repo;
  });

  define('forum/components/components_loader', components, function() {
    var c, i, _i, _len;
    components = Array.prototype.slice.call(arguments, 0);
    for (i = _i = 0, _len = components.length; _i < _len; i = ++_i) {
      c = components[i];
      c['name'] = loadedComponents[i];
    }
    return {
      components: components,
      config: {}
    };
  });

}).call(this);
