Sky.template.extends Template.inventoryThumbnail,
  colorClass: ->
    if @submit == false and @success == false then return 'lime'
    if @submit == true and @success == false then return 'orange'
    if @submit == true and @success == true then return 'belize-hole'

  status: ->
    if @submit == false and @success == false then return 'Checking'
    if @submit == true and @success == false then return 'Fail'
    if @submit == true and @success == true then return 'Success'

  creatorName: (id) -> (Schema.userProfiles.findOne({user: id}))?.fullName
  createDate: (date) -> date.toDateString('dd/MM/yy')

  events:
    'mouseover .full-desc.trash': -> Schema.userProfiles.update Session.get('currentProfile')._id, $set:{currentInventoryHistory: @_id}
    'click .full-desc.trash': -> Schema.userProfiles.update Session.get('currentProfile')._id, $set:{currentInventoryHistory: @_id}