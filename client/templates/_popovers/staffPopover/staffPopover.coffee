Sky.template.extends Template.staffPopover,
  error:      -> Session.get 'errorStaffPopover'
  staffList:  -> Session.get 'personalNewStaffs'
  events:
    'click .create': (event, template)->

      user =
        username : template.find(".username").value
        email    : template.find(".email").value
        password : template.find(".password").value
        profile  : {
          merchant : Session.get('currentMerchant')._id
          creator  :  Meteor.userId()
        }


      Accounts.createUser user, (e,r)->
        console.log e
        console.log r
        if r
          template.find(".name").value = null
          template.find(".representative").value = null
          template.find(".address").value = null
          template.find(".phone").value = null
        else
          Session.set 'errorProviderPopover', 'Có lỗi trong quá trình tạo'

    'click .providerRemove': (event, template)->
      if !@status
        Schema.providers.remove @_id
      else
        console.log 'Loi, Khong The Xoa Duoc'

  rendered: ->