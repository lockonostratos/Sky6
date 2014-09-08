Package.describe({
  summary: "Font Awesome 4.1's LESS sources",
  version: "1.0.0",
  git: ""
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.1.1');

  api.use('less','client');
  api.addFiles([
    'lib/fonts/fontawesome-webfont.eot',
    'lib/fonts/fontawesome-webfont.svg',
    'lib/fonts/fontawesome-webfont.ttf',
    'lib/fonts/fontawesome-webfont.woff']
    , 'client');
});
