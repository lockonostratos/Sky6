Schema.add 'roles', class Role
  @addRolesFor: (profileId, roles) ->
    Schema.userProfiles.update profileId, {$set: {roles: roles}}

  @isInRole: (userId, name) ->

  @rolesOf: (permissions)->
    roles = []
    for role in @schema.find({permissions: {$elemMatch: {$in:[permissions, Sky.system.merchantPermissions.su.key]}}}).fetch()
      roles.push role.name
    roles

  @permissionsOf: (profile) ->
    if typeof profile isnt 'string'
      currentProfile = profile
    else
      currentProfile = Schema.userProfiles.findOne profile
      return [] if !currentProfile

    permissions = []
    if currentProfile.roles
      for role in currentProfile.roles
        currentRole = @schema.findOne({name: role})
        permissions = _.union permissions, currentRole.permissions if currentRole
    permissions

  @hasPermission: (profileId, name) ->
    currentProfile = Schema.userProfiles.findOne profileId
    return [] if !currentProfile

    permissions = @permissionsOf currentProfile
    return _.contains(currentProfile.roles, 'admin') || _.contains(permissions, name)



