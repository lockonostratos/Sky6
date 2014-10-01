Meteor.publish 'tasks', -> Schema.tasks.find {}
Schema.tasks.allow
  insert: -> true
  update: -> true
  remove: -> true