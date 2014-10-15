runInitMerchantWizardTracker = (context) ->
  return if Sky.global.merchantWizardTracker
  Sky.global.merchantWizardTracker = Tracker.autorun ->
#    if Session.get('currentProfile') thn


Sky.template.extends Template.merchantWizard,
  trialPackageOption:
    packageClass: 'free'
    title: 'TRẢI NGHIỆM'
    price: '0'
    duration: '14 NGÀY'
    hint: 'free hint'
    accountLim: 5
    branchLim: 1
    warehouseLim: 1
    footer: 'free footer'

  oneYearsPackageOption:
    packageClass: 'basic'
    title: 'KHỞI ĐỘNG'
    price: '11 triệu'
    duration: '1 NĂM'
    hint: 'basic hint'
    accountLim: 10
    branchLim: 1
    warehouseLim: 1
    footer: 'basic footer'

  threeYearsPackageOption:
    packageClass: 'premium'
    title: 'TĂNG TRƯỞNG'
    price: '30 triệu'
    duration: '3 NĂM'
    hint: 'premium hint'
    accountLim: 15
    branchLim: 1
    warehouseLim: 2
    footer: 'premium footer'

  fiveYearsPackageOption:
    packageClass: 'advance'
    title: 'BỀN VỮNG'
    price: '45 triệu'
    duration: '5 NĂM'
    hint: 'advance hint'
    accountLim: 20
    branchLim: 2
    warehouseLim: 4
    footer: 'advance footer'

  merchantWizard: -> Session.get('currentProfile')
  extendPriceTable: (merchantPackage)->
    console.log @
    if Session.get('merchantPackage') is merchantPackage then true else false
  updateValid: ->
    if Session.get('companyNameValid') is 'invalid' then return 'invalid'
    if Session.get('companyPhoneValid') is 'invalid' then return 'invalid'
    if Session.get('merchantNameValid') is 'invalid' then return 'invalid'
    if Session.get('warehouseNameValid') is 'invalid' then return 'invalid'
    return 'valid'

  created: ->
    if Schema.userProfiles.findOne(user: Meteor.userId())?.merchantRegistered then Router.go('/dashboard')
    else
      Session.setDefault('companyNameValid', 'invalid')
      Session.setDefault('companyPhoneValid', 'invalid')
      Session.setDefault('merchantNameValid', 'invalid')
      Session.setDefault('warehouseNameValid', 'invalid')
      Session.setDefault('merchantPackage', 'free')

  rendered: -> runInitMerchantWizardTracker()

  events:
    "blur #companyName"  : (event, template) ->
      $companyName = $(template.find("#companyName"))
      if $companyName.val().length > 0
        Session.set('companyNameValid', 'valid')
      else
        $companyName.notify('tên công ty không được để trống', {position: "right"})
        Session.set('companyNameValid', 'invalid')

    "blur #companyPhone" : (event, template) ->
      $companyPhone = $(template.find("#companyPhone"))
      if $companyPhone.val().length > 0
        Session.set('companyPhoneValid', 'valid')
      else
        $companyPhone.notify('số điện thoại không được để trống!', {position: "right"})
        Session.set('companyPhoneValid', 'invalid')

    "blur #merchantName" : (event, template) ->
      $merchantName = $(template.find("#merchantName"))
      if $merchantName.val().length > 0
        Session.set('merchantNameValid', 'valid')
      else
        $merchantName.notify('tên chi nhánh không được để trống!', {position: "right"})
        Session.set('merchantNameValid', 'invalid')

    "blur #warehouseName": (event, template) ->
      $warehouseName = $(template.find("#warehouseName"))
      if $warehouseName.val().length > 0
        Session.set('warehouseNameValid', 'valid')
      else
        $warehouseName.notify('tên kho hàng không để trống!', {position: "right"})
        Session.set('warehouseNameValid', 'invalid')

    "click .package-block.free": (event, template)-> Session.set('merchantPackage', 'free')
    "click .package-block.basic": (event, template)-> Session.set('merchantPackage', 'basic')
    "click .package-block.premium": (event, template)-> Session.set('merchantPackage', 'premium')
    "click .package-block.advance": (event, template)-> Session.set('merchantPackage', 'advance')

    "click #merchantUpdate.valid": (event, template)->
      $companyName   = $(template.find("#companyName"))
      $companyPhone  = $(template.find("#companyPhone"))
      $merchantName  = $(template.find("#merchantName"))
      $warehouseName = $(template.find("#warehouseName"))
      UserProfile.findOne(Session.get('currentProfile')?._id).updateNewMerchant(
        $companyName.val(),
        $companyPhone.val(),
        $merchantName.val(),
        $warehouseName.val()
      )
      Router.go('/dashboard')






