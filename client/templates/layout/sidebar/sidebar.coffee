messengerHeight = 298;

Sky.template.extends Template.sidebar,
  myProfile: -> Schema.userProfiles.findOne({user: Meteor.userId()})
  friends: -> Schema.userProfiles.find({user: {$not : Meteor.userId()}}).fetch()

  events:
    "click .chat-avatar:not(.me)": (event, template)->
      Session.set('currentChatTarget', @user)
      Session.set('messengerVisibility', true)

      $target = $(event.target)
      $messenger = $(template.find("#messenger"))
      bottomAnchor = $target.offset().top + $target.outerHeight() - 40
      nextPosition = bottomAnchor - messengerHeight
      nextPosition = -43 if nextPosition < -43
      $messenger.css('top', "#{nextPosition}px")