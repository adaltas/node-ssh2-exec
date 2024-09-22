import connect from "ssh2-connect";
import configure from "mocha-they";

// Configure and return they
const they = configure([
  { label: "local" },
  {
    label: "remote",
    ssh: { host: "127.0.0.1", username: process.env.USER },
  },
]);
const wrap = (handler) => {
  if (handler.length === 1) {
    return (conf) => {
      return new Promise((resolve, reject) => {
        const ssh = conf.ssh;
        if (!ssh) {
          handler.call(this, conf).then(resolve).catch(reject);
        } else {
          connect(ssh)
            .then((conn) => {
              if (conn) conf.ssh = conn;
              return handler.call(this, conf);
            })
            .then(() => {
              conf.ssh.end();
              resolve();
            })
            .catch((err) => {
              if (conf.ssh) conf.ssh.end();
              reject(err);
            });
        }
      });
    };
  } else if (handler.length === 2) {
    return (conf, callback) => {
      const ssh = conf.ssh;
      if (!ssh) {
        handler.call(this, conf, callback);
      } else {
        connect(ssh)
          .then((conn) => {
            conf.ssh = conn;
            handler.call(this, conf, (err) => {
              if (conn) conn.end();
              callback(err);
            });
          })
          .catch((err) => {
            callback(err);
          });
      }
    };
  }
};

export { wrap as connect, they };
