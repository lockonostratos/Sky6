Session.set('topPanelMinimize', true)
toggleTopPanel = -> Session.set('topPanelMinimize', !Session.get('topPanelMinimize'))

Sky.template.extends Template.homeTopPanel,
  minimizeClass: -> if Session.get('topPanelMinimize') then 'minimize' else ''
  toggleIcon: -> if Session.get('topPanelMinimize') then 'fa-chevron-up' else 'fa-chevron-down'
  showRegisterToggle: -> Meteor.userId() is null

  events:
    "click .top-panel-toggle": -> toggleTopPanel(); console.log Session.get('topPanelMinimize')
