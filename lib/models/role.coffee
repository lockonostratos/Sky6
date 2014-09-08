Schema.add 'roles', class Role
  @addRolesFor: (userId, roles) ->
    Meteor.users.update userId, {$set: {roles: roles}}
  @isInRole: (userId, name) ->
  @permissionsOf: (user) ->
    if typeof user isnt 'string'
      currentUser = user
    else
      currentUser = Meteor.users.findOne user
      return [] if !currentUser

    permissions = []
    for name in currentUser.roles
      currentRole = @schema.findOne {name: name}
      permissions = _.union permissions, currentRole.permissions if currentRole
    permissions

  @hasPermission: (userId, name) ->
    currentUser = Meteor.users.findOne userId
    return [] if !currentUser

    permissions = @permissionsOf currentUser
    return _.contains(currentUser.roles, 'admin') || _.contains(permissions, name)