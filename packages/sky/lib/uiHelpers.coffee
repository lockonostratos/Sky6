routeUtils =
  context: -> Router.current()
  regex: (expression) -> new RegExp(expression, 'i')
  testRoutes: (routeNames) ->
    reg = @regex(routeNames)
    @context() && reg.test(@context().route.name)
  testPaths: (paths) ->
    reg = @regex(paths)
    @context() && reg.test(@context().path);

UI.registerHelper 'isActiveRoute', (routes, className) ->
  className = 'active' if className.hash
  routeUtils.testRoutes(routes) ? className : ''

UI.registerHelper 'isActivePath', (paths, className) ->
  className = 'active' if className.hash
  routeUtils.testPaths(paths) ? className : ''

UI.registerHelper 'isNotActiveRoute', (routes, className) ->
  className = 'disabled' if className.hash
  !routeUtils.testRoutes(routes) ? className : ''

UI.registerHelper 'isNotActivePath', (paths, className) ->
  className = 'disabled' if className.hash
  routeUtils.testPaths(paths) ? className : ''
