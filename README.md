[![Build Status](https://secure.travis-ci.org/wdavidw/node-superexec.png)](http://travis-ci.org/wdavidw/node-superexec)

Node.js SuperExec
================

SuperExec is a small Node.js module to provide transparent usage between the `child_process.exec` and `ssh2.prototype.exec` functions.

Installation
------------

StartStop is open source and licensed under the new BSD license.

```bash
npm install superexec
```

Usage
-----

Requiring the module export a single function expecting 1, 2 or 3 arguments. The function signature is `exec([command], options, [callback])`.

Like in the native NodeJS API, the callback is not required in case you with to work with the returned child stream. The command argument is also facultative since it could be provided under the "cmd" property of the options object.

Options include:   

*   `username` SSH user   
*   `privateKey` String representing the private key, required when no password is provided and no private is found   
*   `privateKeyPath` Path from where to read the private key, default to "~/.ssh/id_rsa"   
*   `port` SSH port, default to 22   
*   `password` SSH password, required when no private key is provided or found   

Example
-------

A command, a configuration object and a callback:

```js
exec = require('superexec');
exec('ls -la', {ssh: {host: 'localhost'}}, (err, stdout, stderr){
  console.log(stdout);
});
```

A configuration object with a ssh2 connection and working a the return child object:

```js
exec = require('superexec');
child = exec({cmd: 'ls -la', ssh: passSSH2Connection}, function(err, stdout, stderr){
  console.log(stdout);
});
child.stdout.on('data', function(data){
  console.log(stdout);
});
child.on('exit', function(code){
  console.log('Exit', code);
});
```

Development
-----------

Tests are executed with mocha. To install it, simple run `npm install`, it will install
mocha and its dependencies in your project "node_modules" directory.

To run the tests:
```bash
npm test
```

The tests run against the CoffeeScript source files.

To generate the JavaScript files:
```bash
make build
```

The test suite is run online with [Travis][travis] against Node.js version 0.6, 0.7, 0.8 and 0.9.

Contributors
------------

*   David Worms: <https://github.com/wdavidw>

[travis]: https://travis-ci.org/#!/wdavidw/node-csv-parser
