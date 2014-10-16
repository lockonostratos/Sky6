runInitMerchantWizardTracker = (context) ->
  return if Sky.global.merchantWizardTracker
  Sky.global.merchantWizardTracker = Tracker.autorun ->
    Router.go('/') if Meteor.userId() is null
    if Session.get("currentProfile")
      Router.go('/dashboard') if Session.get("currentProfile").merchantRegistered

      if Template.merchantWizard.trialPackageOption.packageClass is Session.get("currentProfile").packageClass
        Session.set('merchantPackage', Template.merchantWizard.trialPackageOption)

      if Template.merchantWizard.oneYearsPackageOption.packageClass is Session.get("currentProfile").packageClass
        Session.set('merchantPackage', Template.merchantWizard.oneYearsPackageOption)

      if Template.merchantWizard.threeYearsPackageOption.packageClass is Session.get("currentProfile").packageClass
        Session.set('merchantPackage', Template.merchantWizard.threeYearsPackageOption)

      if Template.merchantWizard.fiveYearsPackageOption.packageClass is Session.get("currentProfile").packageClass
        Session.set('merchantPackage', Template.merchantWizard.fiveYearsPackageOption)


      Session.set 'extendAccountLimit',   Session.get("currentProfile").extendAccountLimit ? 0
      Session.set 'extendBranchLimit',    Session.get("currentProfile").extendBranchLimit ? 0
      Session.set 'extendWarehouseLimit', Session.get("currentProfile").extendWarehouseLimit ? 0


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

  merchantWizard: -> Session.get('currentProfile')
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
        Session.set('companyNameValid', 'valid')
        Schema.userProfiles.update Session.get("currentProfile")._id, $set: {companyName: $companyName.val()}
      else
        $companyName.notify('tên công ty không được để trống', {position: "right"})
        Session.set('companyNameValid', 'invalid')


    "blur #companyPhone" : (event, template) ->
      $companyPhone = $(template.find("#companyPhone"))
      if $companyPhone.val().length > 0
        Session.set('companyPhoneValid', 'valid')
        Schema.userProfiles.update Session.get("currentProfile")._id, $set: {companyPhone: $companyPhone.val()}
      else
        $companyPhone.notify('số điện thoại không được để trống!', {position: "right"})
        Session.set('companyPhoneValid', 'invalid')

    "blur #merchantName" : (event, template) ->
      $merchantName = $(template.find("#merchantName"))
      if $merchantName.val().length > 0
        Session.set('merchantNameValid', 'valid')
        Schema.userProfiles.update Session.get("currentProfile")._id, $set: {merchantName: $merchantName.val()}
      else
        $merchantName.notify('tên chi nhánh không được để trống!', {position: "right"})
        Session.set('merchantNameValid', 'invalid')

    "blur #warehouseName": (event, template) ->
      $warehouseName = $(template.find("#warehouseName"))
      if $warehouseName.val().length > 0
        Session.set('warehouseNameValid', 'valid')
        Schema.userProfiles.update Session.get("currentProfile")._id, $set: {warehouseName: $warehouseName.val()}
      else
        $warehouseName.notify('tên kho hàng không để trống!', {position: "right"})
        Session.set('warehouseNameValid', 'invalid')

    "click .package-block.free": (event, template)->
      Schema.userProfiles.update Session.get("currentProfile")._id, $set: {packageClass: Template.merchantWizard.trialPackageOption.packageClass}

    "click .package-block.basic": (event, template)->
      Schema.userProfiles.update Session.get("currentProfile")._id, $set: {packageClass: Template.merchantWizard.oneYearsPackageOption.packageClass}

    "click .package-block.premium": (event, template)->
      Schema.userProfiles.update Session.get("currentProfile")._id, $set: {packageClass: Template.merchantWizard.threeYearsPackageOption.packageClass}

    "click .package-block.advance": (event, template)->
      Schema.userProfiles.update Session.get("currentProfile")._id, $set: {packageClass: Template.merchantWizard.fiveYearsPackageOption.packageClass}

    "click #merchantUpdate.valid": (event, template)->
      $companyName   = $(template.find("#companyName"))
      $companyPhone  = $(template.find("#companyPhone"))
      $merchantName  = $(template.find("#merchantName"))
      $warehouseName = $(template.find("#warehouseName"))

      optionMerchant=
        companyName: $companyName.val()
        companyPhone: $companyPhone.val()
        merchantName: $merchantName.val()
        warehouseName: $warehouseName.val()

      optionMerchantPackage=
        packageClass: Session.get('merchantPackage').packageClass
        price: Session.get('merchantPackage').price
        duration: Session.get('merchantPackage').duration

        defaultAccountLimit:   Session.get('merchantPackage').accountLim
        defaultBranchLimit:    Session.get('merchantPackage').branchLim
        defaultWarehouseLimit: Session.get('merchantPackage').warehouseLim

        extendAccountPrice:   Session.get('merchantPackage').extendAccountPrice
        extendBranchPrice:    Session.get('merchantPackage').extendBranchPrice
        extendWarehousePrice: Session.get('merchantPackage').extendWarehousePrice

        extendAccountLimit:   Session.get('extendAccountLimit')
        extendBranchLimit:    Session.get('extendBranchLimit')
        extendWarehouseLimit: Session.get('extendWarehouseLimit')

      UserProfile.findOne(Session.get('currentProfile')?._id).updateNewMerchant(optionMerchant, optionMerchantPackage)
      Router.go('/dashboard')






