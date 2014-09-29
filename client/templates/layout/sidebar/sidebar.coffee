Sky.template.extends Template.sidebar,
  myProfile: -> Schema.userProfiles.findOne({user: Meteor.userId()})
  friends: -> Schema.userProfiles.find({user: {$not : Meteor.userId()}}).fetch()

  events:
    "click .chat-avatar:not(.me)": (event, template)->
      console.log 'activating chat'
      Session.set('currentChatTarget', @user)
      Session.set('messengerVisibility', true)
      $("#messenger input").focus()

      $target = $(event.target)
      $messenger = $("#messenger")
      messengerHeight = $messenger.outerHeight()
      bottomAnchor = $target.offset().top + ($target.outerHeight()/2)
      nextPosition = bottomAnchor - messengerHeight/2
      nextPosition = 43 if nextPosition < 43
      $messenger.css('top', "#{nextPosition}px")