import * as process from "node:child_process";
import { EventEmitter } from "node:events";
import stream from "node:stream";

// Utilities
const is_ssh_connection = function (obj) {
  return !!obj?.config?.host;
};
const is_object = function (obj) {
  return obj && typeof obj === "object" && !Array.isArray(obj);
};

export const local = function (options, callback) {
  const commandOptions = {};
  commandOptions.env = options.env || process.env;
  commandOptions.cwd = options.cwd || null;
  if (options.uid) {
    commandOptions.uid = options.uid;
  }
  if (options.gid) {
    commandOptions.gid = options.gid;
  }
  if (options.stdio) {
    commandOptions.stdio = options.stdio;
  }
  if (callback) {
    return process.exec(
      options.command,
      commandOptions,
      function (err, stdout, stderr, ...args) {
        if (err) {
          let debug;
          if (stderr.trim().length) {
            debug = stderr.trim().split(/\r\n|[\n\r\u0085\u2028\u2029]/g)[0];
          }
          const { code, signal } = err;
          err = Error(
            [
              "Child process exited unexpectedly: ",
              `code ${JSON.stringify(err.code)}, `,
              err.signal ? `signal ${JSON.stringify(err.signal)}` : "no signal",
              debug ? `, got ${JSON.stringify(debug)}` : void 0,
            ].join(""),
          );
          err.code = code;
          err.signal = signal;
        }
        callback(
          err,
          stdout,
          stderr,
          (err != null ? err.code : void 0) || 0,
          ...args,
        );
      },
    );
  } else {
    return process.spawn(
      options.command,
      [],
      Object.assign(commandOptions, {
        shell: options.shell || true,
      }),
    );
  }
};

export const remote = function (options, callback) {
  const child = new EventEmitter();
  child.stdout = new stream.Readable();
  child.stdout._read = function (_size) {};
  child.stderr = new stream.Readable();
  child.stderr._read = function () {};
  child.kill = function (signal = "KILL") {
    if (child.stream) {
      // IMPORTANT: doesnt seem to work, test is skipped
      // child.stream.write '\x03'
      // child.stream.end '\x03'
      child.stream.signal(signal);
    }
  };
  let stdout = "";
  let stderr = "";
  if (options.cwd) {
    options.command = `cd ${options.cwd}; ${options.command}`;
  }
  const commandOptions = {};
  if (options.env) {
    commandOptions.env = options.env;
  }
  if (options.pty) {
    commandOptions.pty = options.pty;
  }
  if (options.x11) {
    commandOptions.x11 = options.x11;
  }
  options.ssh.exec(options.command, commandOptions, function (err, stream) {
    if (err && callback) {
      return callback(err);
    }
    if (err) {
      return child.emit("error", err);
    }
    child.stream = stream;
    stream.stderr.on("data", function (data) {
      child.stderr.push(data);
      if (callback) {
        stderr += data;
      }
    });
    stream.on("data", function (data) {
      child.stdout.push(data);
      if (callback) {
        stdout += data;
      }
    });
    let code = null;
    let signal = null;
    let exitCalled = false;
    let stdoutCalled = false;
    let stderrCalled = false;
    const exit = function () {
      if (!(exitCalled && stdoutCalled && stderrCalled)) {
        return;
      }
      child.stdout.push(null);
      child.stderr.push(null);
      child.emit("close", code, signal);
      child.emit("exit", code, signal);
      if (code !== 0) {
        let debug;
        if (stderr.trim().length) {
          debug = stderr.trim().split(/\r\n|[\n\r\u0085\u2028\u2029]/g)[0];
        }
        err = Error(
          [
            "Child process exited unexpectedly: ",
            `code ${JSON.stringify(code)}`,
            signal ? `, signal ${JSON.stringify(signal)}` : ", no signal",
            debug ? `, got ${JSON.stringify(debug)}` : void 0,
          ].join(""),
        );
        err.code = code;
        err.signal = signal;
      }
      if (options.end) {
        connection.end();
        connection.on("error", function (err) {
          callback(err);
        });
        connection.on("close", function () {
          if (callback) {
            callback(err, stdout, stderr, code);
          }
        });
      } else {
        if (callback) {
          callback(err, stdout, stderr, code);
        }
      }
    };
    stream.on("error", function (err) {
      console.error("error", err);
    });
    stream.on("exit", function () {
      exitCalled = true;
      [code, signal] = arguments;
      exit();
    });
    stream.on("end", function () {
      stdoutCalled = true;
      exit();
    });
    stream.stderr.on("end", function () {
      stderrCalled = true;
      exit();
    });
  });
  return child;
};

export const exec = function (...args) {
  let callback;
  const options = {};
  for (const i in args) {
    const arg = args[i];
    if (arg == null) {
      if (options.ssh != null) {
        throw Error(
          `Invalid Argument: argument ${i} cannot be null, the connection is already set`,
        );
      }
      options.ssh = arg;
    } else if (is_ssh_connection(arg)) {
      if (options.ssh != null) {
        throw Error(
          `Invalid Argument: argument ${i} cannot be an SSH connection, the connection is already set`,
        );
      }
      options.ssh = arg;
    } else if (is_object(arg)) {
      if (arg.cmd) {
        arg.command = arg.cmd;
        console.warn("Option `cmd` is deprecated in favor of `command`");
      }
      for (const k in arg) {
        options[k] = arg[k];
      }
    } else if (typeof arg === "string") {
      if (options.command != null) {
        throw Error(
          `Invalid Argument: argument ${i} cannot be a string, a command already exists`,
        );
      }
      options.command = arg;
    } else if (typeof arg === "function") {
      if (callback) {
        throw Error(
          `Invalid Argument: argument ${i} cannot be a function, a callback already exists`,
        );
      }
      callback = arg;
    } else {
      throw Error(
        `Invalid arguments: argument ${i} is invalid, got ${JSON.stringify(arg)}`,
      );
    }
  }
  if (options.ssh) {
    return remote(options, callback);
  } else {
    return local(options, callback);
  }
};
