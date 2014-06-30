# configure new component here
# component name defined here must be the same as 
# the component's floder's name
pluginSetting = {}
#enterprise.get_setting("plugins")
loadedComponents = Object.keys(pluginSetting)
# 
components = loadedComponents.map (component) -> 
	pluginSetting[component].repo

define('forum/components/components_loader', components, () ->
	# do something
	components = Array.prototype.slice.call(arguments,0)
	# component's name is injected to each component
	c['name'] = loadedComponents[i] for c, i in components
	{
		components: components
		config: {}
	})