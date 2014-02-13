
stream = require 'stream'
should = require 'should'
superexec = require if process.env.SUPEREXEC_COV then '../lib-cov/index' else '../lib/index'
connect = require if process.env.SUPEREXEC_COV then '../lib-cov/connect' else '../lib/connect'
they = require if process.env.SUPEREXEC_COV then '../lib-cov/they' else '../lib/they'

describe 'exec', ->

  they 'handle a command', (ssh, next) ->
    superexec
      ssh: ssh
      cmd: "cat #{__filename}"
    , (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they 'handle a command string', (ssh, next) ->
    superexec "cat #{__filename}", ssh: ssh, (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they 'exec with error', (ssh, next) ->
    superexec
      ssh: ssh
      cmd: "invalidcommand"
    , (err, stdout, stderr) ->
      err.message.should.be.a.String
      next()








