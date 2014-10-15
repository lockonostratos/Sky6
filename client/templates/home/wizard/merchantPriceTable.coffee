Sky.template.extends Template.merchantPriceTable,
  showExtension: ->
    Session.get('merchantPackage') is @options.packageClass and @options.packageClass isnt 'free'
