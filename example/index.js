(function() {
  define([], function() {
    return {
      name: 'example',
      showName: 'Eg',
      icon: "icon-star",
      models: [
        {
          name: "Component",
          fields: ["name", "text"]
        }
      ],
      topicModel: "Component",
      onViewLoaded: function($scope) {},
      onForumLoaded: function($scope) {},
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
          title: 'Add Component Instance',
          cssClass: 'component_post'
        },
        updateModal: {
          title: 'Edit Component Instance',
          cssClass: 'update_component'
        }
      }
    };
  });


  /*
  	what's inside the $scope?
  	displayed_topic: instance of current topic model
   */

}).call(this);
