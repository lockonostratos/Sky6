root = global ? window
Session.setDefault('collapse', 'collapsed');

root.application =
  toggleCollapse: -> Session.set 'collapse', if Template.layout.collapse() then '' else 'collapsed'