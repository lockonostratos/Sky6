Schema.add 'roles', class Role
  @addRolesFor: (profileId, roles) ->
    Schema.userProfiles.update profileId, {$set: {roles: roles}}

  @isInRole: (userId, name) ->
  @permissionsOf: (profile) ->
    if typeof profile isnt 'string'
      currentProfile = profile
    else
      currentProfile = Schema.userProfiles.findOne profile
      return [] if !currentProfile

    permissions = []
    for role in currentProfile.roles
      currentRole = @schema.findOne(role)
      permissions = _.union permissions, currentRole.permissions if currentRole
    permissions

  @hasPermission: (profileId, name) ->
    currentProfile = Schema.userProfiles.findOne profileId
    return [] if !currentProfile

    permissions = @permissionsOf currentProfile
    return _.contains(currentProfile.roles, 'admin') || _.contains(permissions, name)