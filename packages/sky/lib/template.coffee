class Sky.template
  @extends: (source, destination) ->
    exceptions = ['ui', 'rendered']
    source[name] = value for name, value of destination when !_(exceptions).contains(name)

    rendered = ->
      if destination.ui
        @ui = {}
        @ui[name] = @find(value) for name, value of destination.ui when typeof value is 'string'

      destination.rendered.apply(@, arguments) if destination.rendered

    source.rendered = rendered
    source

#var oldDoSomething = doSomething;
#doSomething = function() {
#// Do what you need to do.
#return oldDoSomething.apply(oldDoSomething, arguments);
#}