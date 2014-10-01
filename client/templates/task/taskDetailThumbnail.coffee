Sky.template.extends Template.taskDetailThumbnail,
  colorClass: ->
    if @status is 0 then 'lime' else 'pumpkin'
