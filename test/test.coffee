
connect = require 'ssh2-connect'

# Configure and return they
they = require('mocha-they') [
  label: 'local'
,
  label: 'remote'
  ssh: host: '127.0.0.1', username: process.env.USER
]

wrap = (handler) ->
  if handler.length is 1
    (conf) ->
      new Promise (resolve, reject) ->
        conn = null
        ssh = conf.ssh
        unless ssh
          handler.call @, conf
          .then resolve
          .catch reject
        else
          connect ssh
          .then (conn) ->
            conf.ssh = conn if conn
            handler.call @, conf
            .then ->
              conn.end()
              resolve()
            .catch (err) ->
              conn.end()
              reject err
          .catch (err) ->
            reject err
  else if handler.length is 2
    (conf, callback) ->
      ssh = conf.ssh
      unless ssh
        handler.call @, conf, callback
      else
        connect ssh
        .then (conn) ->
          conf.ssh = conn
          handler.call @, conf, (err) ->
            conn.end() if conn
            callback err
        .catch (err) ->
          reject err

module.exports =
  connect: wrap
  they: they
