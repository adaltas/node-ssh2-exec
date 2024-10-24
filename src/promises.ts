import { Client } from "ssh2";
import { exec as execCallback, ExecOptions } from "./index.js";

type ExecResolve = {
  stdout: string;
  stderr: string;
  code: number;
};

function exec(options: ExecOptions): Promise<ExecResolve>;
function exec(
  ssh: Client | null,
  command: string,
  options?: ExecOptions,
): Promise<ExecResolve>;
function exec(
  arg1: Client | null | ExecOptions,
  arg2?: string,
  arg3?: ExecOptions,
): Promise<ExecResolve> {
  const options =
    arg2 ?
      ({
        ssh: arg1,
        command: arg2,
        ...arg3,
      } as ExecOptions)
    : (arg1 as ExecOptions);
  return new Promise(function (resolve, reject) {
    execCallback(options, function (err, stdout, stderr, code) {
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
}

export default exec;
export { exec };
