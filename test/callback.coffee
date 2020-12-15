
exec = require '../src/index'
config = require '../test'
they = require('ssh2-they').configure config

describe 'exec', ->

  they 'handle a command', ({ssh}, next) ->
    exec
      ssh: ssh
      command: "cat #{__filename}"
    , (err, stdout, stderr) ->
      return next err if err
      stdout.should.containEql 'myself'
      next()

  they 'exec with error', ({ssh}, next) ->
    exec
      ssh: ssh
      command: "invalidcommand"
    , (err, stdout, stderr) ->
      err.message.should.be.a.String()
      err.message.should.match /^Child process exited unexpectedly: code \d+, no signal, got ".*invalidcommand.*"$/
      next()
