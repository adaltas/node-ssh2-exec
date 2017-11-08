
exec = require if process.env.SSH2_EXEC_COV then '../lib-cov/index' else '../lib/index'
they = require 'ssh2-they'

describe 'exec', ->

  they 'handle a command', (ssh, next) ->
    exec
      ssh: ssh
      cmd: "cat #{__filename}"
    , (err, stdout, stderr) ->
      return next err if err
      stdout.should.containEql 'myself'
      next()

  they 'exec with error', (ssh, next) ->
    exec
      ssh: ssh
      cmd: "invalidcommand"
    , (err, stdout, stderr) ->
      err.message.should.be.a.String()
      err.message.should.match /^Child process exited unexpectedly: code \d+, no signal, got ".*command not found.*"/
      next()
