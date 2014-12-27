require('coffee-script/register');
require('coffee-script');
require('./api/link/index');


require('sails').lift(require('optimist').argv);
