runInitTransactionManagerTracker = (context) ->
  return if Sky.global.transactionMangagerTracker
  Sky.global.transactionMangagerTracker = Tracker.autorun ->
    if Session.get('currentMerchant') && Session.get('receivable') && Session.get('transactionFilter')
      merchant = {merchant: Session.get('currentMerchant')._id}
      receivableFilter = if Session.get('receivable') is '0' then {receivable: true} else {receivable: false}
      transactionFilter =
        switch Session.get('transactionFilter')
          when '1' then {debitCash: {$gt: 0}}
          when '2' then {debitCash: 0}
          when '3' then {debitCash: 0}

      Session.set 'transactionDetailFilter', Schema.transactions.find({$and:[merchant,receivableFilter,transactionFilter]}).fetch()

Sky.appTemplate.extends Template.transactionManager,
  activeReceivable: (receivable)-> return 'active' if Session.get('receivable') is receivable
  activeTransactionFilter: (filter)-> return 'active' if Session.get('transactionFilter') is filter

  created: ->
    Session.setDefault('receivable', '0')
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
