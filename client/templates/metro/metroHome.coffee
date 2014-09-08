_.extend Template.metroHome,
  events:
    "click .app-navigator": (event, template) -> Router.go $(event.currentTarget).attr('data-app')