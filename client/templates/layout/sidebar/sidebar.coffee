

Sky.template.extends Template.sidebar,
  myProfile: -> Schema.userProfiles.findOne({user: Meteor.userId()})
  friends: -> Schema.userProfiles.find({user: {$not : Meteor.userId()}})

  events:
    "click .chat-avatar:not(.me)": (event, template) ->
      if Session.get('messengerVisibility') and @user is Session.get('currentChatTarget')
        Session.set('messengerVisibility', false)
        return

      $target = $(event.target)
      $messenger = $("#messenger")
      Session.set('currentChatTarget', @user)
      Session.set('messengerVisibility', true)

      $messenger.addClass('active')
      $messenger.find('input').focus()

#      messengerHeight = $messenger.outerHeight()
#      bottomAnchor = $target.offset().top + ($target.outerHeight()/2)
#      console.log 'bottomAnchor ', bottomAnchor
#      nextPosition = bottomAnchor - $target.outerHeight()/2
#      console.log 'nextPosition ', nextPosition
#      $messenger.css('top', "#{nextPosition}px")