
stream = require 'stream'
should = require 'should'
exec = require if process.env.SSH2_EXEC_COV then '../lib-cov/index' else '../lib/index'
connect = require if process.env.SSH2_EXEC_COV then '../lib-cov/connect' else '../lib/connect'
they = require if process.env.SSH2_EXEC_COV then '../lib-cov/they' else '../lib/they'

describe 'exec', ->

  they 'handle a command', (ssh, next) ->
    exec
      ssh: ssh
      cmd: "cat #{__filename}"
    , (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they 'handle a command string', (ssh, next) ->
    exec "cat #{__filename}", ssh: ssh, (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they 'exec with error', (ssh, next) ->
    exec
      ssh: ssh
      cmd: "invalidcommand"
    , (err, stdout, stderr) ->
      err.message.should.be.a.String
      next()








