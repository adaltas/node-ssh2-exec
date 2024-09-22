const exec = require('../lib/index');
const { connect, they } = require('./test');

describe("exec.options", () => {
  they(
    "env",
    connect(({ ssh }, next) => {
      if (ssh && process.env.CI_DISABLE_SSH_ENV) {
        return next();
      }
      // Note, accepted environment variables
      // is determined by the AcceptEnv server setting
      // default values are "LANG,LC_*"
      // Note, PermitUserEnvironment must equal `yes`
      let stdout = "";
      const child = exec({
        ssh: ssh,
        env: { LANG: "tv" },
        command: "env | grep LANG",
      });

      child.stdout.on("data", (data) => {
        stdout += data;
      });

      child.on("exit", (code) => {
        stdout.trim().should.eql("LANG=tv");
        next();
      });
    }),
  );
});
