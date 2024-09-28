import { Client } from "ssh2";
import { connect, ConnectConfig } from "ssh2-connect";
import { configure } from "mocha-they";

interface Config {
  label: string;
  ssh: ConnectConfig | null;
}
interface ConfigConnected {
  label: string;
  ssh: Client | null;
}

// Configure and return they
const they = configure<Config, ConfigConnected>(
  [
    { label: "local", ssh: null },
    {
      label: "remote",
      ssh: { host: "127.0.0.1", username: process.env.USER },
    },
  ],
  async (config: Config): Promise<ConfigConnected> => {
    if (!config.ssh) return config as ConfigConnected;
    return {
      ...config,
      ssh: await connect(config.ssh),
    };
  },
  (config: ConfigConnected) => {
    config.ssh?.end();
  },
);

export { they };
