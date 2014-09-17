Sky.appTemplate.extends Template.navigation,
  unreadMessageCount: -> Session.get('unreadMessages')?.length ? 0
  messageClass: -> if Session.get('unreadMessages')?.length > 0 then 'active' else ''

  ui:
    unreadMessagePopover: "#unreadMessagePopover"

  rendered: ->
    console.log @ui.unreadMessagePopover
    $(@ui.unreadMessagePopover).modalPopover
      target: '#unreadMessageHandler'
      backdrop: true
      placement: 'bottom'

  events:
    "click #unreadMessageHandler": (event, template) ->
      Messenger.read(message._id) for message in Session.get('unreadMessages')
      $(template.ui.unreadMessagePopover).modalPopover('show')