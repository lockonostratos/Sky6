Sky.template.extends Template.taskDetailAside,
  rendered: ->
    @ui.$taskDetailDuration.timepicker
      showMeridian: false
      defaultTime: '00:00'
