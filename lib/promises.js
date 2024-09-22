import { exec as execCallback } from "./index.js";

export const exec = function (...args) {
  if (typeof args[args.length - 1] === "function") {
    throw Error("Last argument cannot be a callback function");
  }
  return new Promise(function (resolve, reject) {
    execCallback(...args, function (err, stdout, stderr, code) {
      if (err) {
        err.stdout = stdout;
        err.stderr = stderr;
        reject(err);
      } else {
        resolve({
          stdout: stdout,
          stderr: stderr,
          code: code,
        });
      }
    });
  });
};
