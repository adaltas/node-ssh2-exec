
stream = require 'stream'
should = require 'should'
superexec = require if process.env.SUPEREXEC_COV then '../lib-cov/index' else '../lib/index'
connect = require if process.env.SUPEREXEC_COV then '../lib-cov/connect' else '../lib/connect'
they = require if process.env.SUPEREXEC_COV then '../lib-cov/they' else '../lib/they'

describe 'exec', ->

  they 'handle a command and a callback', (ssh, next) ->
    superexec
      ssh: ssh
      cmd: "cat #{__filename}"
    , (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they 'handle a failed command without a callback', (ssh, next) ->
      stderr = ''
      child = superexec 
        ssh: ssh
        cmd: 'ls -l ~/doesntexist'
      child.stderr.on 'data', (data) ->
        stderr += data
      child.on 'exit', (code) ->
        stderr.should.include 'ls:'
        code.should.be.above 0
        next()

  they 'handle a command string as first argument', (ssh, next) ->
    superexec "cat #{__filename}", ssh: ssh, (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they 'provide stream reader as stdout', (ssh, next) ->
    data = ''
    out = superexec
      ssh: ssh
      cmd: "cat #{__filename}"
    out.stdout.on 'readable', ->
      while d = out.stdout.read()
        data += d.toString()
    out.stdout.on 'end', ->
      data.should.include 'myself'
      next()

  they 'exec with error', (ssh, next) ->
    superexec
      ssh: ssh
      cmd: "invalidcommand"
    , (err, stdout, stderr) ->
      err.message.should.be.a.String
      next()

  they 'child with error', (ssh, next) ->
    # console.log '--'
    child = superexec
      ssh: ssh
      cmd: "invalidcommand"
    child.on 'error', (err) ->
      next new Error 'Should not be called'
    child.on 'exit', (code) ->
      code.should.eql 127
      next()








