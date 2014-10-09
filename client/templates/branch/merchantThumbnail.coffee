Sky.template.extends Template.merchantThumbnail,
  isntDelete: ->
    if Session.get('currentProfile')?.parentMerchant == @_id then false
    else
      metroSummary = Schema.metroSummaries.findOne(merchant: @_id)
      if !metroSummary || (metroSummary.productCount == metroSummary.customerCountMerchant == metroSummary.staffCountMerchant == 0)
        return true
      else
        return false
  events:
    "dblclick .full-desc.trash": ->
      UserProfile.findOne({user: Meteor.userId()}).removeBranch(@_id)
