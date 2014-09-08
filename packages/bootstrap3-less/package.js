Package.describe({
  summary: 'Less version of Bootstrap 3 for Meteor.js',
  version: "1.0.0",
  git: ""
});

Package.onUse(function(api){

  api.use('jquery', 'client');

    // javascript
  api.addFiles([
    'lib/fonts/glyphicons-halflings-regular.eot',
    'lib/fonts/glyphicons-halflings-regular.svg',
    'lib/fonts/glyphicons-halflings-regular.ttf',
    'lib/fonts/glyphicons-halflings-regular.woff',

    'lib/js/transition.js',
    'lib/js/alert.js',
    'lib/js/button.js',
    'lib/js/carousel.js',
    'lib/js/collapse.js',
    'lib/js/dropdown.js',
    'lib/js/modal.js',
    'lib/js/tooltip.js',
    'lib/js/popover.js',
    'lib/js/modal-popover.js',
    'lib/js/scrollspy.js',
    'lib/js/tab.js',
    'lib/js/affix.js'
  ],'client');

});