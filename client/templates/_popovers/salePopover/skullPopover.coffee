Sky.template.extends Template.providerPopover,
  error:      -> Session.get 'errorSkullPopover'
  providers:  -> Session.get 'currentProviders'
  events:
    'click .create': (event, template)->
      skull =
        merchant         : currentMerchant._id
        warehouse        : currentWarehouse._id
        creator          : Meteor.userId()
        name             : template.find(".name").value
        representative   : template.find(".representative").value
        phone            : template.find(".phone").value
        location         : {address: [template.find(".address").value]}
        status           : false
      console.log provider
      Schema.skulls.insert provider, (e,r)->
        console.log e
        console.log r
        if r
          template.find(".name").value = null
          template.find(".representative").value = null
          template.find(".address").value = null
          template.find(".phone").value = null
        else
          Session.set 'errorSkullPopover', 'Có lỗi trong quá trình tạo'

    'click .providerRemove': (event, template)->
      if !@status
        Schema.skulls.remove @_id
      else
        console.log 'Loi, Khong The Xoa Duoc'

  rendered: ->