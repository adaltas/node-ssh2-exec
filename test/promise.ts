import "should";
import { exec } from "../src/promises.js";
import { they } from "./test.js";

describe("exec.promise", function () {
  they("args ssh,command", function ({ ssh }) {
    return exec(ssh, "echo ok").then(({ stdout }) => {
      stdout.should.eql("ok\n");
    });
  });

  they("args options", function ({ ssh }) {
    return exec({
      ssh: ssh,
      command: "echo ok",
    }).then(({ stdout }) => {
      stdout.should.eql("ok\n");
    });
  });

  they("handle a successful command", function ({ ssh }) {
    return exec({
      ssh: ssh,
      command: "echo ok && echo ko >&2 && exit 0",
    }).then(({ stdout, stderr, code }) => {
      stdout.should.eql("ok\n");
      stderr.should.eql("ko\n");
      code.should.eql(0);
    });
  });

  they("handle a successful command", function ({ ssh }) {
    return exec({
      ssh: ssh,
      command: "echo ok && echo ko >&2 && exit 42",
    }).catch((err) => {
      err.stdout.should.eql("ok\n");
      err.stderr.should.eql("ko\n");
      err.code.should.eql(42);
    });
  });
});
