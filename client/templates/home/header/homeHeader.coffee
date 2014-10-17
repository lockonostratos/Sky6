loginErrors = [
  matchFailed        = { reason: "Match failed",        message: "đăng nhập thất bại",       isPasswordError: false}
  userNotFound       = { reason: "User not found",      message: "tài khoản không tồn tại",  isPasswordError: false}
  incorrectPassword  = { reason: "Incorrect password",  message: "mật khẩu chưa chính xác",  isPasswordError: true }
]

Sky.template.extends Template.homeHeader,
  loginValid: -> Session.get('loginValid')
  authenticated: -> Meteor.userId() isnt null

  created: -> Session.setDefault('loginValid', 'invalid')
  rendered: -> $(@find("#authAlias")).val($.cookie('lastAuthAlias'))

  events:
    "click #authButton.valid": (event, template)->
      $login    = $(template.find("#authAlias"))
      $password = $(template.find("#authSecret"))
      $.cookie('lastAuthAlias', $login.val())


      Meteor.loginWithPassword $login.val(), $password.val(), (error) ->
        currentReason = error?.reason

        if !error
          Router.go('/dashboard')
          return

        for currentLoginError in loginErrors
          console.log currentReason, currentLoginError.reason
          if currentLoginError.reason is currentReason
            if currentLoginError.isPasswordError
              $password.notify(currentLoginError.message, {position: "bottom right"})
            else
              $login.notify(currentLoginError.message)

    "blur #authAlias": (event, template)->
      $login = $(template.find("#authAlias"))
      console.log 'blur'
      unless Sky.helpers.regEx($login.val()) then $login.notify('Tên đăng nhập không hợp lệ')

    "click #logoutButton": ->
      Meteor.logout()
      Session.set("currentProfile")

    "click #gotoMerchantButton": -> Router.go('/dashboard')
    "click .logo-text": -> Router.go('/dashboard') if Meteor.userId() isnt null

    "keypress .login-field": (event, template) ->
      $(template.find("#authButton")).click() if event.which is 13 and Session.get('loginValid') is 'valid'

    "input .login-field": (event, template) ->
      $login    = $(template.find("#authAlias"))
      $password = $(template.find("#authSecret"))
      if $login.val().length > 0 and $password.val().length > 0
        Session.set('loginValid', 'valid')
      else
        Session.set('loginValid', 'invalid')

