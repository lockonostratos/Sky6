Sky.template.extends Template.sidebar,
  leftCollapseIcon: ->
    if Session.get('collapse') is 'collapsed'
      'fa fa-angle-double-right'
    else
      'fa fa-angle-double-left'
  myAvatar: -> if @user is Meteor.userId() then 'me' else ''
  avatar: ->
    if Meteor.userId() is @user then 'avatar'
    else @avatar

  avatarLetter: ->
    fullLetters = @fullName ? Meteor.users.findOne(@user).emails[0].address
    fullLetters.substring(0,1).toUpperCase()

  friends: -> Schema.userProfiles.find().fetch()

  events:
    "click .chat-avatar > a:not(a.me)": ->
      Session.set('currentChatTarget', @user)
      Session.set('messengerVisibility', true)