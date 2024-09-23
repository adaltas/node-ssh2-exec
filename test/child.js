import { exec } from "../lib/index.js";
import { they } from "./test.js";

const __filename = new URL("", import.meta.url).pathname;

describe("exec.child", function () {
  they("handle a failed command", function ({ ssh }, next) {
    let stderr = "";
    const child = exec({
      ssh: ssh,
      command: "ls -l ~/doesntexist",
    });
    child.stderr.on("data", (data) => {
      stderr += data;
    });
    child.on("exit", (code) => {
      stderr.should.containEql("ls:");
      code.should.be.above(0);
      next();
    });
  });

  they("provide stream reader as stdout", function ({ ssh }, next) {
    let data = "";
    const out = exec({
      ssh: ssh,
      command: `cat ${__filename}`,
    });
    out.stdout.on("readable", function () {
      let d;
      while ((d = out.stdout.read())) {
        data += d.toString();
      }
    });
    out.stdout.on("end", () => {
      data.should.containEql("myself");
      next();
    });
  });

  they("throw error when running an invalid command", function ({ ssh }, next) {
    const child = exec({
      ssh: ssh,
      command: "invalidcommand",
    });
    child.on("error", () => {
      next(new Error("Should not be called"));
    });
    child.on("exit", (code) => {
      code.should.eql(127);
      next();
    });
  });

  they.skip("stop command execution", function ({ ssh }, next) {
    const child = exec({
      ssh: ssh,
      command: "while true; do echo toto; sleep 1; done; exit 2",
    });
    child.on("error", next);
    child.on("exit", (code, signal) => {
      if (!ssh) {
        signal.should.eql("SIGTERM");
      }
      if (ssh) {
        signal.should.eql("SIGPIPE");
      }
      next();
    });
    setTimeout(() => {
      child.kill();
    }, 100);
  });
});
