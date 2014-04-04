
stream = require 'stream'
should = require 'should'
exec = require if process.env.SSH2_EXEC_COV then '../lib-cov/index' else '../lib/index'
connect = require if process.env.SSH2_EXEC_COV then '../lib-cov/connect' else '../lib/connect'
they = require if process.env.SSH2_EXEC_COV then '../lib-cov/they' else '../lib/they'

describe 'child', ->

  they 'handle a failed command', (ssh, next) ->
      stderr = ''
      child = exec 
        ssh: ssh
        cmd: 'ls -l ~/doesntexist'
      child.stderr.on 'data', (data) ->
        stderr += data
      child.on 'exit', (code) ->
        stderr.should.include 'ls:'
        code.should.be.above 0
        next()

  they 'provide stream reader as stdout', (ssh, next) ->
    data = ''
    out = exec
      ssh: ssh
      cmd: "cat #{__filename}"
    out.stdout.on 'readable', ->
      while d = out.stdout.read()
        data += d.toString()
    out.stdout.on 'end', ->
      data.should.include 'myself'
      next()

  they 'throw error when running an invalid command', (ssh, next) ->
    child = exec
      ssh: ssh
      cmd: "invalidcommand"
    child.on 'error', (err) ->
      next new Error 'Should not be called'
    child.on 'exit', (code) ->
      code.should.eql 127
      next()

  they 'stop command execution', (ssh, next) ->
    child = exec 
      ssh: ssh
      cmd: 'while true; do echo toto; sleep 1; done; exit 2'
    child.on 'error', next
    child.on 'exit', (code, signal) ->
      signal.should.eql 'SIGTERM' unless ssh
      signal.should.eql 'SIGPIPE' if ssh
      next()
    setTimeout ->
      child.kill()
    , 1000