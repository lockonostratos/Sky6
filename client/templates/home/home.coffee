Sky.appTemplate.extends Template.home,
  cooldownOptions:
    startAt: new Date(new Date - 0 * 60000)
    buget: 0.5
    others:
      fgColor: "#7caa22"
  avatarImages: -> AvatarImages.find()

  created: -> Router.go('/dashboard') unless Meteor.userId() is null or (Session.get('autoNatigateDashboardOff'))
  rendered: -> $("body").css("overflow", "auto"); Sky.helpers.animateUsing("body", "bounceInDown")

  events:
    'click input': -> console.log 'Fuck YOU!'
    'click h1': -> console.log 'text clicked'
    'change #fileUpload': (event, template) ->
      files = event.target.files
      if files.length > 0
        AvatarImages.insert files[0], (error, fileObj) ->
          console.log error, fileObj