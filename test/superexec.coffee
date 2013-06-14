
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
        stderr.should.include 'No such file or directory'
        code.should.eql 1
        next()

  they 'handle a command string as first argument', (ssh, next) ->
    superexec "cat #{__filename}", ssh: ssh, (err, stdout, stderr) ->
      return next err if err
      stdout.should.include 'myself'
      next()

  they.skip 'local', 'provide stream reader as stdout', (ssh, next) ->
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






