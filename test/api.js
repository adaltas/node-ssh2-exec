const exec = require("../lib/index");
const { connect, they } = require("./test");

describe("exec", () => {
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
