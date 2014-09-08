Sky.template.extends Template.providerPopover,
  error:      -> Session.get 'errorProviderPopover'
  providerList:  -> Session.get 'personalNewProviders'
  events:
    'click .createProvider': (event, template)->
      provider =
        merchant         : Session.get('currentMerchant')._id
        creator          : Meteor.userId()
        name             : template.find(".name").value
        representative   : template.find(".representative").value
        phone            : template.find(".phone").value
        location         : {address: [template.find(".address").value]}
        status           : false

      Schema.providers.insert provider, (e,r)->
        console.log e
        console.log r
        if r
          template.find(".name").value = null
          template.find(".representative").value = null
          template.find(".address").value = null
          template.find(".phone").value = null
        else
          Session.set 'errorProviderPopover', 'Có lỗi trong quá trình tạo'

    'click .removeProvider': (event, template)->
        Schema.providers.remove @_id


  rendered: ->