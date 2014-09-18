root = global ? window
root.application =
  toggleCollapse: -> Session.set 'collapse', if Template.layout.collapse() then '' else 'collapsed'