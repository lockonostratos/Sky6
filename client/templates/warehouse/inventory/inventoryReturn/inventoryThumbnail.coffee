Sky.template.extends Template.inventoryThumbnail,
  colorClasses: 'none'
  status: ->
    if @submit == false and @success == false then return 'Checking'
    if @submit == true and @success == false then return 'Fail'
    if @submit == true and @success == true then return 'Success'


  creatorName: (id) -> (Schema.userProfiles.findOne({user: id}))?.fullName
  createDate: (date) -> date.toDateString('dd/MM/yy')

  hideDetail: -> return "display: none" if !(@submit == true and @success == false)