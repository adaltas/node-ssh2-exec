import { connect } from "ssh2-connect";
import { configure } from "mocha-they";

// Configure and return they
const they = configure(
  [
    { label: "local" },
    {
      label: "remote",
      ssh: { host: "127.0.0.1", username: process.env.USER },
    },
  ],
  async (config) => {
    if (!config.ssh) return config;
    config.ssh = await connect(config.ssh);
    return config;
  },
  (config) => {
    if (!config.ssh) return;
    config.ssh.end();
  },
);

export { they };
