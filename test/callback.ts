import should from "should";
import { exec } from "../src/index.js";
import { they } from "./test.js";

describe("exec.callback", function () {
  they("handle a command", function ({ ssh }, next) {
    exec(
      {
        ssh: ssh,
        command: "echo 'ok' && echo 'ko' >&2",
      },
      (err, stdout, stderr, code) => {
        stdout.should.eql("ok\n");
        stderr.should.eql("ko\n");
        code.should.eql(0);
        next();
      },
    );
  });

  they("exec with error", function ({ ssh }, next) {
    exec(
      {
        ssh: ssh,
        command: "echo 'ok' && echo 'ko' >&2 && exit 42",
      },
      (err, stdout, stderr, code) => {
        stdout.should.eql("ok\n");
        stderr.should.eql("ko\n");
        code.should.eql(42);
        should(err).not.be.undefined();
        err?.message.should.equal(
          [
            "Child process exited unexpectedly:",
            "code 42, no signal,",
            'got "ko"',
          ].join(" "),
        );
        next();
      },
    );
  });
});
