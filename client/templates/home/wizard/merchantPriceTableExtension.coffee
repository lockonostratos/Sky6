Sky.template.extends Template.merchantPriceTableExtension,

  accountLimitOptions:
    reactiveSetter: (val) ->
      Session.set('extendAccountLim', val)
    reactiveValue: -> Session.get('extendAccountLim') ? 0
    reactiveMax: -> 9999
    reactiveMin: -> 0
    reactiveStep: -> 1

  branchLimitOptions:
    reactiveSetter: (val) ->
      Session.set('extendBranchLim', val)
    reactiveValue: -> Session.get('extendBranchLim') ? 0
    reactiveMax: -> 500
    reactiveMin: -> 0
    reactiveStep: -> 1

  warehouseLimitOptions:
    reactiveSetter: (val) ->
      Session.set('extendWarehouseLim', val)
    reactiveValue: -> Session.get('extendWarehouseLim') ? 0
    reactiveMax: -> 999
    reactiveMin: -> 0
    reactiveStep: -> 1