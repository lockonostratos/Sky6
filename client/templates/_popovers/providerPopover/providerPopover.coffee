createProvider= (event, template)->
  if template.find(".name").value.length < 1
    Session.set 'errorProviderPopover', 'Tên Công Ty không được để trống.'; return
  else
    Session.set 'errorProviderPopover'

  provider =
    merchant         : Session.get('currentMerchant')._id
    creator          : Meteor.userId()
    name             : template.find(".name").value
    representative   : template.find(".representative").value
    phone            : template.find(".phone").value
    location         : {address: [template.find(".address").value]}
    status           : false

  findProvider =  Schema.providers.findOne({
    merchant : provider.merchant
    name     : provider.name
    phone    : provider.phone
  })

  if findProvider
    Session.set 'errorProviderPopover', 'Tạo mới nhà phân phối bị trùng lặp.'
  else
    Schema.providers.insert provider, (e,r)->
      if e then console.log e
      if r
        template.find(".name").value = null
        template.find(".representative").value = null
        template.find(".address").value = null
        template.find(".phone").value = null
      else
        Session.set 'errorProviderPopover', 'Có lỗi trong quá trình tạo'

Sky.template.extends Template.providerPopover,
  error:      -> Session.get 'errorProviderPopover'
  providerList:  -> Session.get 'personalNewProviders'

  events:
    'click .createProvider': (event, template)-> createProvider(event, template)
    'click .removeProvider': (event, template)->
      if provider = Schema.providers.findOne(@_id)
        if findProduct = Schema.products.findOne({provider: provider._id})
          console.log 'Loi, Khong The Xoa Duoc'
        else
          Schema.providers.remove @_id
