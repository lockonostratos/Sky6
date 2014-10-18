packageOption = (option)->
  packageClass          : option.packageClass
  price                 : option.price
  duration              : option.duration
  defaultAccountLimit   : option.accountLim
  defaultBranchLimit    : option.branchLim
  defaultWarehouseLimit : option.warehouseLim
  extendAccountPrice    : option.extendAccountPrice
  extendBranchPrice     : option.extendBranchPrice
  extendWarehousePrice  : option.extendBranchPrice


runInitMerchantWizardTracker = (context) ->
  return if Sky.global.merchantWizardTracker
  Sky.global.merchantWizardTracker = Tracker.autorun ->
    Router.go('/') if Meteor.userId() is null
    unless Session.get('merchantPackages')?.user is Meteor.userId() then Router.go('/dashboard')
    if Session.get('merchantPackages')?.merchantRegistered then Router.go('/dashboard')

    if Session.get("merchantPackages")
      Session.set 'extendAccountLimit',   Session.get("merchantPackages").extendAccountLimit ? 0
      Session.set 'extendBranchLimit',    Session.get("merchantPackages").extendBranchLimit ? 0
      Session.set 'extendWarehouseLimit', Session.get("merchantPackages").extendWarehouseLimit ? 0

      if Template.merchantWizard.trialPackageOption.packageClass is Session.get("merchantPackages").packageClass
        Session.set('merchantPackage', Template.merchantWizard.trialPackageOption)

      if Template.merchantWizard.oneYearsPackageOption.packageClass is Session.get("merchantPackages").packageClass
        Session.set('merchantPackage', Template.merchantWizard.oneYearsPackageOption)

      if Template.merchantWizard.threeYearsPackageOption.packageClass is Session.get("merchantPackages").packageClass
        Session.set('merchantPackage', Template.merchantWizard.threeYearsPackageOption)

      if Template.merchantWizard.fiveYearsPackageOption.packageClass is Session.get("merchantPackages").packageClass
        Session.set('merchantPackage', Template.merchantWizard.fiveYearsPackageOption)

      if Session.get("merchantPackages").companyName?.length > 0 then Session.set('companyNameValid', 'valid')
      else Session.set('companyNameValid', 'invalid')

      if Session.get("merchantPackages").companyPhone?.length > 0 then Session.set('companyPhoneValid', 'valid')
      else Session.set('companyPhoneValid', 'invalid')

      if Session.get("merchantPackages").merchantName?.length > 0 then Session.set('merchantNameValid', 'valid')
      else Session.set('merchantNameValid', 'invalid')

      if Session.get("merchantPackages").warehouseName?.length > 0 then Session.set('warehouseNameValid', 'valid')
      else Session.set('warehouseNameValid', 'invalid')

Sky.template.extends Template.merchantWizard,

  trialPackageOption:
    packageClass: 'free'
    title: 'TRẢI NGHIỆM'
    titlePrice: '0'
    titleDuration: '14 NGÀY'
    price: 0
    duration: 14
    hint: 'free hint'
    accountLim: 5
    branchLim: 1
    warehouseLim: 1
    footer: 'free footer'

  oneYearsPackageOption:
    packageClass: 'basic'
    title: 'KHỞI ĐỘNG'
    titlePrice: '11 triệu'
    titleDuration: '1 NĂM'
    price: 11000000
    duration: 365
    hint: 'basic hint'
    accountLim: 10
    branchLim: 1
    warehouseLim: 1
    extendAccountPrice: 200000
    extendBranchPrice: 300000
    extendWarehousePrice: 100000
    footer: 'basic footer'

  threeYearsPackageOption:
    packageClass: 'premium'
    title: 'TĂNG TRƯỞNG'
    titlePrice: '30 triệu'
    titleDuration: '3 NĂM'
    price: 30000000
    duration: 365*3
    hint: 'premium hint'
    accountLim: 15
    branchLim: 1
    warehouseLim: 2
    extendAccountPrice: 200000
    extendBranchPrice: 300000
    extendWarehousePrice: 100000
    footer: 'premium footer'

  fiveYearsPackageOption:
    packageClass: 'advance'
    title: 'BỀN VỮNG'
    titlePrice: '45 triệu'
    titleDuration: '5 NĂM'
    price: 45000000
    duration: 365*5
    hint: 'advance hint'
    accountLim: 20
    branchLim: 2
    warehouseLim: 4
    extendAccountPrice: 200000
    extendBranchPrice: 300000
    extendWarehousePrice: 100000
    footer: 'advance footer'

  merchantPackage: -> Session.get('merchantPackages')
  updateValid: ->
    if Session.get('companyNameValid') is 'invalid' then return 'invalid'
    if Session.get('companyPhoneValid') is 'invalid' then return 'invalid'
    if Session.get('merchantNameValid') is 'invalid' then return 'invalid'
    if Session.get('warehouseNameValid') is 'invalid' then return 'invalid'
    return 'valid'

  created: ->
    Router.go('/') if Meteor.userId() is null
    if Session.get("currentProfile")
      Router.go('/dashboard') if Session.get("currentProfile").merchantRegistered

    Session.setDefault('companyNameValid', 'invalid')
    Session.setDefault('companyPhoneValid', 'invalid')
    Session.setDefault('merchantNameValid', 'invalid')
    Session.setDefault('warehouseNameValid', 'invalid')

    Session.setDefault('extendAccountLimit', 0)
    Session.setDefault('extendBranchLimit', 0)
    Session.setDefault('extendWarehouseLimit', 0)

  rendered: -> runInitMerchantWizardTracker()

  events:
    "blur #companyName"  : (event, template) ->
      $companyName = $(template.find("#companyName"))
      if $companyName.val().length > 0
        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {companyName: $companyName.val()}
      else
        $companyName.notify('tên công ty không được để trống', {position: "right"})

    "blur #companyPhone" : (event, template) ->
      $companyPhone = $(template.find("#companyPhone"))
      if $companyPhone.val().length > 0
        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {companyPhone: $companyPhone.val()}
      else
        $companyPhone.notify('số điện thoại không được để trống!', {position: "right"})

    "blur #merchantName" : (event, template) ->
      $merchantName = $(template.find("#merchantName"))
      if $merchantName.val().length > 0
        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {merchantName: $merchantName.val()}
      else
        $merchantName.notify('tên chi nhánh không được để trống!', {position: "right"})

    "blur #warehouseName": (event, template) ->
      $warehouseName = $(template.find("#warehouseName"))
      if $warehouseName.val().length > 0
        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {warehouseName: $warehouseName.val()}
      else
        $warehouseName.notify('tên kho hàng không để trống!', {position: "right"})


    "click .package-block.free": (event, template)->
      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.trialPackageOption)

    "click .package-block.basic": (event, template)->
      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.oneYearsPackageOption)

    "click .package-block.premium": (event, template)->
      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.threeYearsPackageOption)

    "click .package-block.advance": (event, template)->
      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.fiveYearsPackageOption)

    "click #merchantUpdate.valid": (event, template)->
      UserProfile.findOne(Session.get('currentProfile')?._id).updateNewMerchant()
      Router.go('/dashboard')






