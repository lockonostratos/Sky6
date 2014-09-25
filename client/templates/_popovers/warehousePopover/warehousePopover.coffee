Sky.template.extends Template.warehousePopover,
  error:      -> Session.get 'errorProviderWarehouse'
  warehouseList:  -> Session.get 'personalNewWarehouses'
  events:
    'click .createWarehouse': (event, template)->
      warehouse =
        merchant         : Session.get('currentMerchant')._id
        creator          : Meteor.userId()
        name             : template.find(".name").value
        isRoot         : false
        location         : {address: [template.find(".address").value]}

      Schema.warehouses.insert warehouse, (e,r)->
        console.log e
        console.log r
        if r
          template.find(".name").value = null
          template.find(".address").value = null
          Session.set 'errorProviderWarehouse'
        else
          Session.set 'errorProviderWarehouse', 'Có lỗi trong quá trình tạo'

    'click .removeWarehouse': (event, template)->
      Schema.warehouses.remove @_id

  rendered: ->