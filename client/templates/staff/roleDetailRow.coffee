Sky.template.extends Template.roleDetailRow,
  permissionDesc: ->
    return 'CHƯA PHÂN QUYỀN' if !@roles
    Schema.roles.findOne(@roles[0])?.description ? 'KHÔNG TÌM THẤY'
  email: ->
    Meteor.users.findOne(@user).emails[0].address
