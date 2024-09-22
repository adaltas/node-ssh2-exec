import { exec } from "../lib/index.js";
import { connect, they } from "./test.js";

const __filename = new URL("", import.meta.url).pathname;

describe("exec.api", () => {
  they(
    "ssh, command, callback",
    connect(({ ssh }, next) => {
      exec(ssh, `cat ${__filename}`, (err, stdout, stderr) => {
        if (err) return next(err);
        stdout.should.containEql("myself");
        next();
      });
    }),
  );

  they(
    "options, callback",
    connect(({ ssh }, next) => {
      exec(
        { ssh: ssh, command: `cat ${__filename}` },
        (err, stdout, stderr) => {
          if (err) return next(err);
          stdout.should.containEql("myself");
          next();
        },
      );
    }),
  );

  they(
    "multiple options, callback",
    connect(({ ssh }, next) => {
      exec(
        { ssh: ssh },
        { command: "invalid" },
        { command: `cat ${__filename}` },
        (err, stdout, stderr) => {
          if (err) return next(err);
          stdout.should.containEql("myself");
          next();
        },
      );
    }),
  );
});
