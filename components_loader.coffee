# configure new component here
# component name defined here must be the same as 
# the component's floder's name

loadedComponents = [
	#"new1"
	"todolist"
]
# 
components = loadedComponents.map (component) -> 
	"forum/components/#{component}/index"

define('forum/components/components_loader', components, () ->
	# do something
	components = Array.prototype.slice.call(arguments,0)
	# component's name is injected to each component
	c['name'] = loadedComponents[i] for c, i in components
	{
		components: components
		config: {}
	})