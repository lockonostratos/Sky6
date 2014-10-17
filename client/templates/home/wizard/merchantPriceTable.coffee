Sky.template.extends Template.merchantPriceTable,
  showExtension: ->
    Session.get("merchantPackages")?.packageClass is @options.packageClass and @options.packageClass isnt 'free'

  extendPrice: ->
    extendAccountPrice    = @options.extendAccountPrice * Session.get('extendAccountLimit')
    extendBranchPrice     = @options.extendBranchPrice * Session.get('extendBranchLimit')
    extendWarehousePrice  = @options.extendWarehousePrice * Session.get('extendWarehouseLimit')
    extendAccountPrice + extendBranchPrice + extendWarehousePrice

  accountLimitOptions:
    reactiveSetter: (val) ->
      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {extendAccountLimit: val}
    reactiveValue: -> Session.get('extendAccountLimit') ? 0
    reactiveMax: -> 9999
    reactiveMin: -> 0
    reactiveStep: -> 1

  branchLimitOptions:
    reactiveSetter: (val) ->
      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {extendBranchLimit: val}
    reactiveValue: -> Session.get('extendBranchLimit') ? 0
    reactiveMax: -> 500
    reactiveMin: -> 0
    reactiveStep: -> 1

  warehouseLimitOptions:
    reactiveSetter: (val) ->
      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {extendWarehouseLimit: val}
    reactiveValue: -> Session.get('extendWarehouseLimit') ? 0
    reactiveMax: -> 999
    reactiveMin: -> 0
    reactiveStep: -> 1