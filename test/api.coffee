
exec = require if process.env.SSH2_EXEC_COV then '../lib-cov' else '../lib'
config = require '../test'
they = require('ssh2-they').configure config

describe 'exec', ->

  they 'ssh, command, callback', ({ssh}, next) ->
    exec ssh, "cat #{__filename}", (err, stdout, stderr) ->
      return next err if err
      stdout.should.containEql 'myself'
      next()

  they 'options, callback', ({ssh}, next) ->
    exec ssh: ssh, command: "cat #{__filename}", (err, stdout, stderr) ->
      return next err if err
      stdout.should.containEql 'myself'
      next()

  they 'multiple options, callback', ({ssh}, next) ->
    exec {ssh: ssh}, {command: 'invalid'}, {command: "cat #{__filename}"}, (err, stdout, stderr) ->
      return next err if err
      stdout.should.containEql 'myself'
      next()
