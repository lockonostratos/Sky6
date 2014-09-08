Sky.template.extends Template.customerPopover,
  error: -> Session.get 'errorCustomerPopover'
  customerList: -> Session.get 'personalNewCustomers'

  events:
    'click .createCustomer': (event, template)->
      customer =
        currentMerchant : Session.get('currentMerchant')._id
        creator         : Meteor.userId()
        name            : template.find(".name").value
        companyName     : template.find(".companyName").value
        phone           : template.find(".phone").value
        email           : template.find(".email").value
        address         : template.find(".address").value
        sex             : false

      Schema.customers.insert customer, (e,r)->
        console.log e
        console.log r
        if r
          template.find(".name").value = null
          template.find(".companyName").value = null
          template.find(".phone").value = null
          template.find(".email").value = null
          template.find(".address").value = null
        else
          Session.set 'errorCustomerPopover', 'Có lỗi trong quá trình tạo'

    'click .removeCustomer': (event, template)->
      Schema.customers.remove @_id
