import * as childProcess from "node:child_process";
import { ExecException } from "node:child_process";
import { EventEmitter } from "node:events";
import * as stream from "node:stream";
// import NodeJS from "node:process";
import { Client, ExecOptions as Ssh2ExecOptions } from "ssh2";

export const local = function (
  options: ExecLocalOptions,
  callback: ExecCallback,
): childProcess.ChildProcess {
  options.env ??= process.env;
  if (callback) {
    return childProcess.exec(
      options.command,
      options,
      function (err, stdout, stderr) {
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
        callback(err, stdout, stderr, (err != null ? err.code : void 0) || 0);
      },
    );
  } else {
    return childProcess.spawn(
      options.command,
      [],
      Object.assign(options, {
        shell: options.shell || true,
      }),
    );
  }
};

export const remote = function (
  options: ExecRemoteOptions,
  callback: ExecCallback,
): childProcess.ChildProcess {
  const child = new childProcess.ChildProcess();
  child.stdout = new stream.Readable();
  child.stdout._read = function () {};
  child.stderr = new stream.Readable();
  child.stderr._read = function () {};
  // kill(signal?: NodeJS.Signals | number): boolean;
  child.kill = function (signal?: NodeJS.Signals | number): boolean {
    console.warn(`Not implemented, called kill ${signal}`);
    // if (child.stream) {
    //   // IMPORTANT: doesnt seem to work, test is skipped
    //   // child.stream.write '\x03'
    //   // child.stream.end '\x03'
    //   child.stream.signal(signal);
    // }
    return true;
  };
  let stdout = "";
  let stderr = "";
  if (options.cwd) {
    options.command = `cd ${options.cwd}; ${options.command}`;
  }
  options.ssh.exec(options.command, options, function (errArg, stream) {
    if (errArg && callback) {
      return callback(errArg, "", "", NaN);
    }
    if (errArg) {
      return child.emit("error", errArg);
    }
    let err: ExecException | null = null;
    // child.stream = stream;
    stream.stderr.on("data", function (data) {
      child.stderr?.push(data);
      stderr += data;
    });
    stream.on("data", function (data: string) {
      child.stdout?.push(data);
      stdout += data;
    });
    let code = 0;
    let signal: NodeJS.Signals | null = null;
    let exitCalled = false;
    let stdoutCalled = false;
    let stderrCalled = false;
    const exit = function () {
      if (!(exitCalled && stdoutCalled && stderrCalled)) {
        return;
      }
      child.stdout?.push(null);
      child.stderr?.push(null);
      child.emit("close", code, signal);
      child.emit("exit", code, signal);
      if (code !== 0) {
        let debug;
        if (stderr.trim().length) {
          debug = stderr.trim().split(/\r\n|[\n\r\u0085\u2028\u2029]/g)[0];
        }
        err = new Error(
          [
            "Child process exited unexpectedly: ",
            `code ${JSON.stringify(code)}`,
            signal ? `, signal ${JSON.stringify(signal)}` : ", no signal",
            debug ? `, got ${JSON.stringify(debug)}` : void 0,
          ].join(""),
        ) as ExecException;
        err.code = code;
        // err.signal = signal;
      }
      if (options.end) {
        options.ssh.end();
        options.ssh.on("error", function (err) {
          callback(err, "", "", NaN);
        });
        options.ssh.on("close", function () {
          if (callback) {
            callback(err || null, stdout, stderr, code);
          }
        });
      } else {
        if (callback) {
          callback(err || null, stdout, stderr, code);
        }
      }
    };
    stream.on("error", function (code: number) {
      console.error("error", code);
    });
    stream.on("exit", function (codeArg: number, signalArg: NodeJS.Signals) {
      exitCalled = true;
      code = codeArg;
      signal = signalArg;
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

// interface ExecOptions {
//   shell: string | undefined;
//   signal: AbortSignal | undefined;
//   maxBuffer: number | undefined;
//   killSignal: number | Signals | undefined;
//   windowsHide: boolean | undefined;
//   timeout: number | undefined;
//   uid: number | undefined;
//   gid: number | undefined;
//   cwd: string | URL | undefined;
//   env: ProcessEnv | undefined;
// }
// const Ssh2ExecOptions: {
//   env: ProcessEnv | undefined;
//   pty: boolean | PseudoTtyOptions | undefined;
//   x11: number | boolean | X11Options | undefined;
//   allowHalfOpen: boolean | undefined;
// }
type ExecLocalOptions = {
  ssh: null | undefined;
  command: string;
} & childProcess.ExecOptions;
type ExecRemoteOptions = {
  ssh: Client;
  command: string;
  cwd?: string | undefined;
  end?: boolean;
} & Ssh2ExecOptions;
export type ExecOptions = ExecLocalOptions | ExecRemoteOptions;

export type ExecCallback = (
  err: ExecException | null,
  stdout: string,
  stderr: string,
  code: number,
) => void;

function exec(
  options: ExecOptions,
  callback?: ExecCallback,
): childProcess.ChildProcess;
function exec(
  ssh: Client | null,
  command: string,
  callback?: ExecCallback,
): childProcess.ChildProcess;
function exec(
  ssh: Client | null,
  command: string,
  options: ExecOptions,
  callback?: ExecCallback,
): childProcess.ChildProcess;
function exec(
  arg1: Client | ExecOptions | null,
  arg2: string | ExecCallback | undefined,
  arg3?: ExecOptions | ExecCallback,
  arg4?: ExecCallback,
): EventEmitter {
  const options: ExecOptions =
    arg3 !== undefined ?
      // ssh and cmd separated
      typeof arg3 === "function" ?
        { ssh: arg1 as Client | undefined, command: arg2 as string }
      : (arg3 as ExecOptions)
    : (arg1 as ExecOptions);
  const callback: ExecCallback =
    arg3 !== undefined ?
      // ssh and cmd separated
      typeof arg3 === "function" ?
        (arg3 as ExecCallback)
      : (arg4 as ExecCallback)
    : (arg2 as ExecCallback);
  if (options.ssh) {
    return remote(options, callback);
  } else {
    return local(options, callback);
  }
}

export default exec;
export { exec };
