import "should";
import { exec } from "../src/index.js";
import { they } from "./test.js";

const __filename = new URL("", import.meta.url).pathname;

describe("exec.api", function () {
  they("ssh, command, callback", function ({ ssh }, next) {
    exec(ssh, `cat ${__filename}`, (err, stdout) => {
      if (err) return next(err);
      stdout.should.containEql("myself");
      next();
    });
  });

  they("options, callback", function ({ ssh }, next) {
    exec({ ssh: ssh, command: `cat ${__filename}` }, (err, stdout) => {
      if (err) return next(err);
      stdout.should.containEql("myself");
      next();
    });
  });
});
