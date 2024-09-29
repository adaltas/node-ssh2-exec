[![Build Status](https://secure.travis-ci.org/adaltas/node-ssh2-exec.svg)][travis]

# Node.js ssh2-exec

The Node.js `ssh2-exec` package extends the [`ssh2`][ssh2] module to provide transparent usage between the `child_process.exec` and `ssh2.prototype.exec` functions. It was originally developped for and is still use by [Nikita](https://nikita.js.org) to run actions both locally and over SSH.

## Installation

This is OSS and licensed under the [new BSD license][license].

```bash
npm install ssh2-exec
```

## `ssh2-exec` module usage

The default module expose an API similar to the native NodeJS API. Its signature is:

`exec(sshOrNull, command, [options], [callback])`

Or

`exec(options, [callback])`

Like in the native NodeJS API, the callback is not required in case you wish to work with the returned child stream. The "sshOrNull" and "command" arguments are also facultative because they could be provided respectively as the "ssh" and "command" property of the options object.

Valid `options` properties are:

- `ssh`  
  SSH connection if the command must run remotely
- `command`  
  Command to run unless provided as first argument
- `cwd`  
  Current working directory
- `end`  
  Close the SSH connection on exit, default to true if an ssh connection instance is provided.
- `env`  
  An environment to use for the execution of the command.
- `pty`  
  Set to true to allocate a pseudo-tty with defaults, or an object containing specific pseudo-tty settings. Apply only to SSH remote commands.
- `cwd`  
  Apply only to local commands.
- `uid`  
  Apply only to local commands.
- `gid`  
  Apply only to local commands.

See the [ssh2] and [ssh2-connect] modules on how to create a new SSH connection.

## `ssh2-exec/promises` module usage

Note, until version `0.7.3`, the module was named `ssh2-exec/promise`. The `promise` resolution is still working. However, it will be removed in an upcoming version in favor of `ssh2-exec/promises` in order to be consistent with the Node.js `node:fs/promises` module.

The promise module is an alternative to the callback usage. Like with the callback, use it if `stdout` and `stderr` are not too large and fit in memory.

`const {stdout, stderr, code} = await exec(sshOrNull, command, [options])`

Or

`const {stdout, stderr, code} = await exec(options)`

If the exit code is not `0`, the thrown error object contains the `stdout`, `stderr`, and `code` properties.

## Examples

A command, a configuration object and a callback:

```js
import { connect } from "ssh2-connect";
import { exec } from "ssh2-exec";
connect({ host: localhost }, (err, ssh) => {
  exec("ls -la", { ssh: ssh }, (err, stdout, stderr, code) => {
    console.info(stdout, stderr, code);
  });
});
```

A configuration object with a ssh2 connection and working a the return child object:

```js
import { connect } from "ssh2-connect";
import { exec } from "ssh2-exec";
connect({ host: localhost }, function (err, ssh) {
  child = exec(
    {
      command: "ls -la",
      ssh: ssh,
    },
    function (err, stdout, stderr, code) {
      console.info(stdout);
    },
  );
  child.stdout.on("data", function (data) {
    console.info(data);
  });
  child.stderr.on("data", function (data) {
    console.error(data);
  });
  child.on("exit", function (code) {
    console.info("Exit", code);
  });
});
```

## Development

Tests are executed with mocha. To install it, simple run `npm install`, it will install mocha and its dependencies in your project "node_modules" directory.

To run the tests:

```bash
npm test
```

## Release

Versions are incremented using semantic versioning. To create a new version and publish it to NPM, run:

```bash
npm run release
```

The publication is handled by the GitHub action.

## Contributors

The project is sponsored by [Adaltas](https://www.adaltas.com) based in Paris, France. Adaltas offers support and consulting on distributed systems, big data and open source.

[ssh2]: https://github.com/mscdex/ssh2
[ssh2-connect]: https://github.com/adaltas/node-ssh2-connect
[license]: https://github.com/adaltas/node-ssh2-exec/blob/master/LICENSE.md
