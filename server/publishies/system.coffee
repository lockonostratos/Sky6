Meteor.publish 'tasks', -> Schema.tasks.find {}
Schema.tasks.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'systems', -> Schema.systems.find {}
Schema.systems.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'migrations', -> Schema.migrations.find {}
Schema.migrations.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'avatarImages', -> AvatarImages.find {}
AvatarImages.allow
  insert: -> true
  update: -> true
  remove: -> true
  download: -> true