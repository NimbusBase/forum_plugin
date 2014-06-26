define([], ()->
	{
		showName: 'New1'
		icon: "icon-star"
		models: [
			{name: "Component", fields: ["name", "text"]}
		]
		topicModel:  "Component"
		onViewLoaded: ($scope) ->
			# do something when display changes to current topic
			# alert "Component view loaded!"
		onForumLoaded: ($scope) ->
			# do something when forum app loaded
			#alert "new1 call back on Forum loaded"
		formConfig: {
			fields: {
				name: 
					type: 'input'
					label: 'Name'
				text:
					type: 'editor'
					label: 'Description'
			}
		}
		view: {
			createModal:{
				title: 'Add Component Instance'
				cssClass: 'component_post'
			}
			updateModal:{
				title: 'Edit Component Instance'
				cssClass: 'update_component'
			}
		}
	}
)
###
	what's inside the $scope?
	displayed_topic: instance of current topic model
###