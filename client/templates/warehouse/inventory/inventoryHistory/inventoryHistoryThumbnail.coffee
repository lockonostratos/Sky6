Sky.template.extends Template.inventoryHistoryThumbnail,
  colorClass: ->
    if @status is true then 'lime' else 'pumpkin'
  status: ->
    if @status then return 'Success'
    else
      return 'Fail'

  createDate: (date) -> date.toDateString('dd/MM/yy')
#  Schema.userProfiles.update Session.get('currentProfile')._id, $set:{currentInventoryHistory: e.added._id}

