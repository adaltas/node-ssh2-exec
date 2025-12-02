import "should";
import { exec } from "../src/index.js";
import { they } from "./test.js";

describe("exec.options", function () {
  they("env", function ({ ssh }, next) {
    if (ssh && process.env.CI_DISABLE_SSH_ENV) {
      return next();
    }
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!     Read the README.md      !!!!!!!!!!!
    // !!!!!!!!!! to configure the SSH server !!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    let stdout = "";
    const child = exec({
      ssh: ssh,
      env: { LANG: "tv" },
      command: "env | grep LANG",
    });
    child.stdout?.on("data", (data) => {
      stdout += data;
    });
    child.on("exit", () => {
      stdout.trim().should.eql("LANG=tv");
      next();
    });
  });
});
