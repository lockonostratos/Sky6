Package.describe({
    summary: 'Select2 is a jQuery based replacement for select boxes.'
});

Package.onUse(function (api) {
    api.use('jquery', 'client');

    api.addFiles([
        'lib/select2/select2.js',
        'lib/select2/select2_locale_vi.js'
    ], 'client', {bare: true});

    api.addFiles([
        'lib/select2/select2.css',
        'lib/select2/select2.png',
        'lib/select2/select2x2.png',
        'lib/select2/select2-spinner.gif',
        'path-override.css'
    ], 'client');
});