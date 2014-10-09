Sky.template.extends Template.warehousePopover,
  error:      -> Session.get 'errorProviderWarehouse'
  warehouseList:  -> Session.get 'personalNewWarehouses'
  events:
    'click .createWarehouse': (event, template)->
      name = template.find(".name").value
      if Schema.warehouses.findOne({name: name})
        Session.set 'errorProviderWarehouse', 'Tên kho bị trùng lặp'
      else
        Session.set 'errorProviderWarehouse'
        warehouse =
          parentMerchant   : Session.get('currentProfile').parentMerchant
          merchant         : Session.get('currentProfile').currentMerchant
          creator          : Meteor.userId()
          name             : name
          isRoot           : false
          checkingInventory : false
          location         : {address: [template.find(".address").value]}

        Schema.warehouses.insert warehouse, (e,r)->
          console.log e if e
          if r
            template.find(".name").value = null
            template.find(".address").value = null
            Session.set 'errorProviderWarehouse'
          else
            Session.set 'errorProviderWarehouse', 'Có lỗi trong quá trình tạo'

    'click .removeWarehouse': (event, template)->
      unless Schema.products.findOne({warehouse: @_id})
        Schema.warehouses.remove @_id

  rendered: ->