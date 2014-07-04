define([], ()->
	{
		# this name is only used in the 'Compose' button dropdown menu
		showName: 'Todo'
		# icon in 'Compose' button dropdown menu
		icon: "icon-list"
		# declare models and their fields used by this component
		# some fields are always available and you don't need to
		# write them down. They are defined in forum/index.coffee
		# such as "userid", "created_at", "timestamp"
		models: [
			{name: "Todolist", fields: ["name", "text", "pinned"]}
			{name: "Todo", fields: ["content", "status", "listid", "images", 'completed_at']}
			# {name: "TodoAttachment", fields: ["todoid","order"]}
		]
		# one of the models should be treated as topicModel
		topicModel:  "Todolist"
		###
		   this callback will be called when the change_display
		   invoked and view changed to current component
		   the scope refers to a private component scope
		   not the global Forum scope
		###
		onViewLoaded: ($scope) ->
			# do something when display changes to current topic
			# alert "Component view loaded!"
			$scope.todoList = $scope.getTodoList()
			return
		###
		  this callback will be called when the forum plugin
		  is loaded, you can do some init operation for
		  this component
		  the scope refers to a private component scope
		###
		onForumLoaded: ($scope, $enterprise, $filter) ->
			$scope.show_completed_todo = 1
			$scope.todoOrder = 'timestamp'
			$scope.reverseOrder = false

			# do something when forum app loaded
			todo_model = enterprise._models['Todo']
			user_model = enterprise._models['User']

			todo_model.onUpdate((mode, obj, isLocal)->
				# update todos
				$scope.todoList = $scope.getTodoList()

				$scope.$apply() if !isLocal
			)

			$scope.users = enterprise._models.User.all().filter (x) -> x.name
			$scope.addTodo = (content) ->
				if !content
					alert("You must type something todo :)")
					return
				todo_model.create({
					content: content
					status: false
					listid: $scope.displayed_topic.id
					created_at: Date().toString()
					timestamp: new Date().getTime()
				}) 
				$scope.todoContent = ""
				$scope.todoList = $scope.getTodoList()	

				# add comment for creating todo
				msg = "#{enterprise._current_user.name} added a new todo: <b>#{content}</b>"
				$scope.$parent.log_comment(msg)
				return
			$scope.change_todo_display = (display)->
				$scope.show_completed_todo = display

				if display is 1
					$scope.todoOrder = 'timestamp'
					$scope.reverseOrder = false

				else if display is 2
					$scope.reverseOrder = true
					$scope.todoOrder = 'completed_at'

			$scope.will_show_todo = (todo)->
				if $scope.show_completed_todo is 1
					if !todo.status
						return true
					else
						return false

				else if $scope.show_completed_todo is 2
					if todo.status
						return true
					else
						return false

			$scope.delTodo = (todo) ->
				todo_model.delete_from_cloud(todo['id'])
				$scope.todoList = $scope.getTodoList()

				# add comment for delete todo
				msg = "#{enterprise._current_user.name} deleted todo: <b>#{todo.content}</b>"
				$scope.$parent.log_comment(msg)

				$scope.$parent.load()

			$scope.changeStatus = (todo) ->
				result = todo_model.update(todo['id'],{status:todo.status});
				todo["status"] = result["status"]

			$scope.toggle = (todo)->
				todo.status = !todo.status
				# save completed timestamp
				if todo.status
					todo.completed_at = new Date().getTime()

				todo.save()

				status = if todo.status then 'completeted' else 'uncompleted'
				msg = "#{enterprise._current_user.name} marked <b>'#{todo.content}'</b> #{status}"
				# add comment for change status
				$scope.$parent.log_comment(msg)

			$scope.showStatus = (todo) ->
				if todo["status"] then "done" else ""

			$scope.assign = (todo, user) ->
				# if the user id is the same, then do nothing
				return if todo.userid is user.pid
				
				result = todo_model.update(todo['id'],{userid:user.pid});
				todo["userid"] = result["userid"]

				email = enterprise._user_list[todo["userid"]].email
				data = 
					subject : 'Forum Todo '
					content : "Todo '#{todo.content}' has been assigned to you"
				# send email after assign
				$scope.$parent.send_email_to(email, data)

			$scope.cancelAssign = (todo) ->
				result = todo_model.update(todo['id'],{userid:undefined});
				todo["userid"] = result["userid"]
			$scope.getTodoList = () ->
				todos = todo_model.findAllByAttribute('listid',$scope.displayed_topic.id)

				#  order the todos
				$filter('orderBy')(todos, $scope.todoOrder, $scope.reverseOrder)

			###
				get image path with id
			###
			$scope.get_image_path = (id)->
				enterprise._plugins.document._documents[id].webContentLink

			###
				input : (number) index
				input : (object) todo
				function : remove image at index for todo
			###
			$scope.remove_image_at = (index, todo)->
				todo.images.splice(index, 1)
				todo.save()
			###
			 this is for editing todo and upload image for todo
			 the idea is watching the todolist for changes

			###
			$scope.editing_todo = -1
			$scope.$watch('todoList', (changed)->
				if $scope.editing_todo isnt -1
					todo = changed[$scope.editing_todo]

					# upload image
					if todo.new_image and typeof todo.new_image isnt 'string'
						spinner = $scope.$parent.show_spinner('Uploading')
						Nimbus.Binary.upload_file(todo.new_image, (f)->
							# update document data with set method
							enterprise._plugins.document.set(f._file.id, f._file)
							image = 
								id : f._file.id
							if todo.images
								image.order = todo.images.length+1
							else
								todo.images = []
								image.order = 1
							todo.images.push(image)
							delete todo.new_image
							todo.save()
							# apply changes
							spinner.hide()
							$scope.$apply()
						)
					else
						# save the changes
						todo.save()
						# $scope.editing_todo = -1
					# $scope.getTodoList()
			,true)

			return

		# this method is for sending email to other user 
		# if new data is created

		email_for_creation : ($scope, data)->
			email = 
				subject : 'Forum Todo: '+data.name
				content : data.text
			$scope.send_email_to_all(email)

		# form fields shown when creating or editing
		# the component instance
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
		# this option is used to auto-generate
		# html of update modal and create modal
		view: {
			createModal:{
				title: 'Add Todolist'
				cssClass: 'todolist_post'
			}
			updateModal:{
				title: 'Edit Todolist'
				cssClass: 'update_todolist'
			}
		}
	}
)