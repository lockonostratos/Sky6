Sky.appTemplate.extends Template.navigation,
  unreadMessageCount: -> Sky.global.notification.unreadMessages.count()
  messageClass: -> if Sky.global.notification.unreadMessages.count() > 0 then 'active' else ''

  unreadNotificationCount: -> Sky.global.notification.unreadNotifications.count()
  notificationClass: -> if Sky.global.notification.unreadNotifications.count() > 0 then 'active' else ''

  unreadRequestCount: -> Sky.global.notification.unreadRequests.count()
  requestClass: -> if Sky.global.notification.unreadRequests.count() > 0 then 'active' else ''

  subMenus: -> Session.get('subMenus')
  currentSystemVersion: -> Schema.systems.findOne()?.version ? ''

  events:
    "click #logoutButton": (event, template) -> Meteor.logout(); Router.go('/')
    "click a.branding": -> Router.go('/')