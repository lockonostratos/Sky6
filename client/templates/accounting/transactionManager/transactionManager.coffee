runInitTransactionManagerTracker = (context) ->
  return if Sky.global.transactionMangagerTracker
  Sky.global.transactionMangagerTracker = Tracker.autorun ->
    if Session.get('currentMerchant') && Session.get('receivable') && Session.get('transactionFilter')
      merchant = {merchant: Session.get('currentMerchant')._id}
      receivableFilter = if Session.get('receivable') then {receivable: true} else {receivable: false}
#      transactionFilter =
##        if Session.get('transactionFilter') is '1' then return {debitCash: {$gt: 0}}
#        if Session.get('transactionFilter') is '3' then return {debitCash: 0}
#      console.log merchant
#      console.log receivableFilter
#      console.log transactionFilter

      Session.set 'transactionDetailFilter', Schema.transactions.find({$and:[merchant,receivableFilter]}).fetch()

Sky.appTemplate.extends Template.transactionManager,
  activeReceivable: (receivable)-> return 'active' if Session.get('receivable') is receivable
  activeTransactionFilter: (filter)-> return 'active' if Session.get('transactionFilter') is filter

  created: ->
    Session.setDefault('receivable', true)
    Session.setDefault('transactionFilter', '1')

  rendered: -> runInitTransactionManagerTracker()

  events:
    "click [data-receivable]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'receivable', $element.attr("data-receivable")
    "click [data-filter]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'transactionFilter', $element.attr("data-filter")

  transactionDetailOptions:
    itemTemplate: 'transactionThumbnail'
    reactiveSourceGetter: -> Session.get("transactionDetailFilter") ? []
    wrapperClasses: 'detail-grid row'
