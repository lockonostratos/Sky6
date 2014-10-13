Package.describe({
  summary: "System package for skyEngine",
  version: "1.0.0",
  git: ""
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.1.1');

  api.addFiles([
    'lib/3rds/soundjs.js',
    'lib/3rds/animate.css',
    'lib/3rds/moment.js',
    'lib/3rds/slimscroll.js',
    'lib/3rds/jquery.hotkeys.js',
    'lib/3rds/jquery.bootstrap-touchspin.css',
    'lib/3rds/jquery.bootstrap-touchspin.js',
    'lib/3rds/switchery.css',
    'lib/3rds/switchery.js',
    'lib/3rds/bootstrap-timepicker.css',
    'lib/3rds/bootstrap-timepicker.js',
    'lib/3rds/jquery.event.drag-2.2.js',
    'lib/3rds/jquery.event.drag.live-2.2.js',
    'lib/3rds/notify.js',
    'lib/3rds/jquery.knob.js',
    'lib/3rds/jquery.cookie.js'
    ]
  , 'client');

  api.addFiles([
    'lib/3rds/accounting.js']
  , ['client', 'server']);

  api.addFiles([
    'lib/sky.coffee',
    'lib/menu.coffee',
    'lib/notification.coffee',
    'lib/template.coffee']
  , ['client', 'server']);

  api.use(['coffeescript', 'underscore'], ['client', 'server']);
  api.use(['jquery'], 'client');
});