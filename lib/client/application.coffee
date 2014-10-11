root = global ? window
root.application =
  toggleCollapse: -> Session.set 'collapse', if Template.merchantLayout.collapse() then '' else 'collapsed'