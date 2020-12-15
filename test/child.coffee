
exec = require '../src/index'
config = require '../test'
they = require('ssh2-they').configure config

describe 'child', ->

  they 'handle a failed command', ({ssh}, next) ->
    stderr = ''
    child = exec
      ssh: ssh
      command: 'ls -l ~/doesntexist'
    child.stderr.on 'data', (data) ->
      stderr += data
    child.on 'exit', (code) ->
      stderr.should.containEql 'ls:'
      code.should.be.above 0
      next()

  they 'provide stream reader as stdout', ({ssh}, next) ->
    data = ''
    out = exec
      ssh: ssh
      command: "cat #{__filename}"
    out.stdout.on 'readable', ->
      while d = out.stdout.read()
        data += d.toString()
    out.stdout.on 'end', ->
      data.should.containEql 'myself'
      next()

  they 'throw error when running an invalid command', ({ssh}, next) ->
    child = exec
      ssh: ssh
      command: "invalidcommand"
    child.on 'error', (err) ->
      next new Error 'Should not be called'
    child.on 'exit', (code) ->
      code.should.eql 127
      next()

  they.skip 'stop command execution', ({ssh}, next) ->
    child = exec
      ssh: ssh
      command: 'while true; do echo toto; sleep 1; done; exit 2'
    child.on 'error', next
    child.on 'exit', (code, signal) ->
      signal.should.eql 'SIGTERM' unless ssh
      signal.should.eql 'SIGPIPE' if ssh
      next()
    setTimeout ->
      child.kill()
    , 100
