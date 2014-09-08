root = global ? window
Session.set('collapse', '');

root.application =
  toggleCollapse: -> Session.set 'collapse', if Template.layout.collapse() then '' else 'collapsed'