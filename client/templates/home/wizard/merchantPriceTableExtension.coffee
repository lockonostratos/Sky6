Sky.template.extends Template.merchantPriceTableExtension,

  accountLimitOptions:
    reactiveSetter: (val) ->
    reactiveValue: -> 0
    reactiveMax: -> 9999
    reactiveMin: -> 10
    reactiveStep: -> 1

  branchLimitOptions:
    reactiveSetter: (val) ->
    reactiveValue: -> 0
    reactiveMax: -> 500
    reactiveMin: -> 0
    reactiveStep: -> 1

  warehouseLimitOptions:
    reactiveSetter: (val) ->
    reactiveValue: -> 0
    reactiveMax: -> 999
    reactiveMin: -> 0
    reactiveStep: -> 1