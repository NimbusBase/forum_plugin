(function() {
  define([], function() {
    return {
      showName: 'Todo',
      icon: "icon-list",
      models: [
        {
          name: "Todolist",
          fields: ["name", "text", "pinned"]
        }, {
          name: "Todo",
          fields: ["content", "status", "listid", "images", 'completed_at']
        }
      ],
      topicModel: "Todolist",

      /*
      		   this callback will be called when the change_display
      		   invoked and view changed to current component
      		   the scope refers to a private component scope
      		   not the global Forum scope
       */
      onViewLoaded: function($scope) {
        $scope.todoList = $scope.getTodoList();
      },

      /*
      		  this callback will be called when the forum plugin
      		  is loaded, you can do some init operation for
      		  this component
      		  the scope refers to a private component scope
       */
      onForumLoaded: function($scope, $enterprise, $filter) {
        var todo_model, user_model;
        $scope.show_completed_todo = 1;
        $scope.todoOrder = 'timestamp';
        $scope.reverseOrder = false;
        todo_model = enterprise._models['Todo'];
        user_model = enterprise._models['User'];
        todo_model.onUpdate(function(mode, obj, isLocal) {
          $scope.todoList = $scope.getTodoList();
          if (!isLocal) {
            return $scope.$apply();
          }
        });
        $scope.users = enterprise._models.User.all().filter(function(x) {
          return x.name;
        });
        $scope.addTodo = function(content) {
          var msg;
          if (!content) {
            alert("You must type something todo :)");
            return;
          }
          todo_model.create({
            content: content,
            status: false,
            listid: $scope.displayed_topic.id,
            created_at: Date().toString(),
            timestamp: new Date().getTime()
          });
          $scope.todoContent = "";
          $scope.todoList = $scope.getTodoList();
          msg = "" + enterprise._current_user.name + " added a new todo: <b>" + content + "</b>";
          $scope.$parent.log_comment(msg);
        };
        $scope.change_todo_display = function(display) {
          $scope.show_completed_todo = display;
          if (display === 1) {
            $scope.todoOrder = 'timestamp';
            return $scope.reverseOrder = false;
          } else if (display === 2) {
            $scope.reverseOrder = true;
            return $scope.todoOrder = 'completed_at';
          }
        };
        $scope.will_show_todo = function(todo) {
          if ($scope.show_completed_todo === 1) {
            if (!todo.status) {
              return true;
            } else {
              return false;
            }
          } else if ($scope.show_completed_todo === 2) {
            if (todo.status) {
              return true;
            } else {
              return false;
            }
          }
        };
        $scope.delTodo = function(todo) {
          var msg;
          todo_model.delete_from_cloud(todo['id']);
          $scope.todoList = $scope.getTodoList();
          msg = "" + enterprise._current_user.name + " deleted todo: <b>" + todo.content + "</b>";
          $scope.$parent.log_comment(msg);
          return $scope.$parent.load();
        };
        $scope.changeStatus = function(todo) {
          var result;
          result = todo_model.update(todo['id'], {
            status: todo.status
          });
          return todo["status"] = result["status"];
        };
        $scope.toggle = function(todo) {
          var msg, status;
          todo.status = !todo.status;
          if (todo.status) {
            todo.completed_at = new Date().getTime();
          }
          todo.save();
          status = todo.status ? 'completeted' : 'uncompleted';
          msg = "" + enterprise._current_user.name + " marked <b>'" + todo.content + "'</b> " + status;
          return $scope.$parent.log_comment(msg);
        };
        $scope.showStatus = function(todo) {
          if (todo["status"]) {
            return "done";
          } else {
            return "";
          }
        };
        $scope.assign = function(todo, user) {
          var data, email, result;
          if (todo.userid === user.pid) {
            return;
          }
          result = todo_model.update(todo['id'], {
            userid: user.pid
          });
          todo["userid"] = result["userid"];
          email = enterprise._user_list[todo["userid"]].email;
          data = {
            subject: 'Forum Todo ',
            content: "Todo '" + todo.content + "' has been assigned to you"
          };
          return $scope.$parent.send_email_to(email, data);
        };
        $scope.cancelAssign = function(todo) {
          var result;
          result = todo_model.update(todo['id'], {
            userid: void 0
          });
          return todo["userid"] = result["userid"];
        };
        $scope.getTodoList = function() {
          var todos;
          todos = todo_model.findAllByAttribute('listid', $scope.displayed_topic.id);
          return $filter('orderBy')(todos, $scope.todoOrder, $scope.reverseOrder);
        };

        /*
        				get image path with id
         */
        $scope.get_image_path = function(id) {
          return enterprise._plugins.document._documents[id].webContentLink;
        };

        /*
        				input : (number) index
        				input : (object) todo
        				function : remove image at index for todo
         */
        $scope.remove_image_at = function(index, todo) {
          todo.images.splice(index, 1);
          return todo.save();
        };

        /*
        			 this is for editing todo and upload image for todo
        			 the idea is watching the todolist for changes
         */
        $scope.editing_todo = -1;
        $scope.$watch('todoList', function(changed) {
          var spinner, todo;
          if ($scope.editing_todo !== -1) {
            todo = changed[$scope.editing_todo];
            if (todo.new_image && typeof todo.new_image !== 'string') {
              spinner = $scope.$parent.show_spinner('Uploading');
              return Nimbus.Binary.upload_file(todo.new_image, function(f) {
                var image;
                enterprise._plugins.document.set(f._file.id, f._file);
                image = {
                  id: f._file.id
                };
                if (todo.images) {
                  image.order = todo.images.length + 1;
                } else {
                  todo.images = [];
                  image.order = 1;
                }
                todo.images.push(image);
                delete todo.new_image;
                todo.save();
                spinner.hide();
                return $scope.$apply();
              });
            } else {
              return todo.save();
            }
          }
        }, true);
      },
      email_for_creation: function($scope, data) {
        var email;
        email = {
          subject: 'Forum Todo: ' + data.name,
          content: data.text
        };
        return $scope.send_email_to_all(email);
      },
      formConfig: {
        fields: {
          name: {
            type: 'input',
            label: 'Name'
          },
          text: {
            type: 'editor',
            label: 'Description'
          }
        }
      },
      view: {
        createModal: {
          title: 'Add Todolist',
          cssClass: 'todolist_post'
        },
        updateModal: {
          title: 'Edit Todolist',
          cssClass: 'update_todolist'
        }
      }
    };
  });

}).call(this);
