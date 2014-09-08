Sky.template.extends Template.skullPopover,
  error:      -> Session.get 'errorSkullPopover'
  skullList:  -> Session.get 'personalNewSkulls'
  events:
    'click .createSkull': (event, template)->
      if template.find(".name").value.length < 1
        Session.set 'errorSkullPopover', 'Tên không đươc để trống'
        return

      skull =
        merchant         : Session.get('currentMerchant')._id
        creator          : Meteor.userId()
        name             : template.find(".name").value

      Schema.skulls.insert skull, (e,r)->
        console.log e
        console.log r
        if r
          template.find(".name").value = null
          Session.set 'errorSkullPopover'
        else
          Session.set 'errorSkullPopover', 'Có lỗi trong quá trình tạo'

    'click .removeSkull': (event, template)->
      Schema.skulls.remove @_id
