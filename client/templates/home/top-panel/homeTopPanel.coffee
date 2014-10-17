registerErrors = [
  incorrectPassword  = { reason: "Incorrect password",  message: "tài khoản tồn tại"}
]

Session.set('topPanelMinimize', true)
toggleTopPanel = -> Session.set('topPanelMinimize', !Session.get('topPanelMinimize'))

Sky.template.extends Template.homeTopPanel,
  minimizeClass: -> if Session.get('topPanelMinimize') then 'minimize' else ''
  toggleIcon: -> if Session.get('topPanelMinimize') then 'fa-chevron-up' else 'fa-chevron-down'
  showRegisterToggle: -> Meteor.userId() is null

  registerValid: ->
    if Session.get('registerAccountValid') == Session.get('registerSecretValid') == 'valid'
      'valid'
    else
      'invalid'

  created: ->
    Session.setDefault('registerAccountValid', 'invalid')
    Session.setDefault('registerSecretValid', 'invalid')

  events:
    "click .top-panel-toggle": -> toggleTopPanel(); console.log Session.get('topPanelMinimize')
    "click #merchantRegister.valid": (event, template)->
      $companyName    = $(template.find("#companyName"))
      $companyPhone   = $(template.find("#companyPhone"))
      $account        = $(template.find("#account"))
      $secret         = $(template.find("#secret"))

      Meteor.call "registerMerchant", $account.val(), $secret.val(), (error, result)->
        if !error
          user = result
          Schema.userProfiles.insert UserProfile.newDefault(user), (error, result)-> console.log error if error
          Schema.merchantPackages.insert({merchantRegistered: false, user: user, companyName: $companyName.val(), companyPhone: $companyPhone.val()})
          Session.set('topPanelMinimize', true)
          Meteor.loginWithPassword $account.val(), $secret.val(), (error) -> Router.go('/merchantWizard') if !error

#    "keypress #secretConfirm": (event, template) ->
#      $(template.find("#merchantRegister")).click() if event.which is 13 and Template.homeTopPanel.registerValid is 'valid'
#    "input #secretConfirm": (event, template) ->
#      $secret  = $(template.find("#secret"))
#      $secretConfirm = $(template.find("#secretConfirm"))
#      if $secretConfirm.val().length > 0 or $secret.val().length > 0 or $secretConfirm.val() is $secret.val()
#        Session.set('registerSecretValid', 'valid')
#      else
#        Session.set('registerSecretValid', 'invalid')


    "blur #account": (event, template) ->
      $account = $(template.find("#account"))
      if $account.val().length > 0
        if Sky.helpers.regEx($account.val())
          Meteor.loginWithPassword $account.val(), '', (error) ->
            if error?.reason is "Incorrect password"
              $account.notify("tài khoản đã tồn tại", {position: "right"})
              Session.set('registerAccountValid', 'invalid')
            else
              Session.set('registerAccountValid', 'valid')
        else
          $account.notify('Email không hợp lệ.', {position: "right"})
          Session.set('registerAccountValid', 'invalid')
      else
        Session.set('registerAccountValid', 'invalid')

    "blur #secret": (event, template) ->
      $secret  = $(template.find("#secret"))
      $secretConfirm = $(template.find("#secretConfirm"))
      if $secretConfirm.val().length > 0 or $secret.val().length > 0 or $secretConfirm.val() is $secret.val()
        Session.set('registerSecretValid', 'invalid')
      else
        Session.set('registerSecretValid', 'valid')

    "blur #secretConfirm": (event, template) ->
      $secret  = $(template.find("#secret"))
      $secretConfirm = $(template.find("#secretConfirm"))
      if $secret.val().length > 0 and  $secretConfirm.val() is $secret.val()
        Session.set('registerSecretValid', 'valid')
      else
        unless $secret.val() is $secretConfirm.val()
          $secretConfirm.notify('mật khẩu không chính xác !', {position: "right"})
        Session.set('registerSecretValid', 'invalid')
