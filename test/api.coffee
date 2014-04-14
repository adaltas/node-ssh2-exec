
should = require 'should'
exec = require if process.env.SSH2_EXEC_COV then '../lib-cov' else '../lib'
they = require 'ssh2-they'

describe 'exec', ->

  they 'ssh, cmd, no options, callback', (ssh, next) ->
    exec ssh, "cat #{__filename}", (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they 'options, callback', (ssh, next) ->
    exec ssh: ssh, cmd: "cat #{__filename}", (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()