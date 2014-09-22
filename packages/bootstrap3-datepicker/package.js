Package.describe({
  name: "rajit:bootstrap3-datepicker",
  git: "https://github.com/rajit/bootstrap3-datepicker.git",
  summary: "Meteor packaging of eternicode/bootstrap-datepicker for Bootstrap 3",
  "version": "1.3.1"
});

Package.onUse(function (api) {
  api.versionsFrom('0.9.0');
  api.use('jquery', 'client');
    
  api.addFiles(['lib/bootstrap-datepicker/js/bootstrap-datepicker.js',
                'lib/bootstrap-datepicker/js/locales/bootstrap-datepicker.vi.js'], 'client');
  api.addFiles('lib/bootstrap-datepicker/css/datepicker3.css', 'client');
});
