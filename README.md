[![Build Status](https://secure.travis-ci.org/wdavidw/node-superexec.png)](http://travis-ci.org/wdavidw/node-superexec)

NodeJs SuperExec
================

SuperExec is a small NodeJs module to provide transparent usage between the `child_process.exec` and `ssh2.prototype.exec` functions.

Installation
------------

StartStop is open source and licensed under the new BSD license.

```bash
npm install superexec
```

Example
-------

```js
superexec 
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
