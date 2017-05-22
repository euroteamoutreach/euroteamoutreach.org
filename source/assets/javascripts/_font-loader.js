// https://www.npmjs.com/package/webfontloader

var WebFont = require('webfontloader');

WebFont.load({
  google: {
    families: ['PT+Serif:400,700',
               'Source+Sans+Pro:700,400,600,300',
               'Lato:700,400,300,100',
               'Cinzel:700'
    ]
  }
});
