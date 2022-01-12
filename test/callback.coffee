
exec = require '../src/index'
config = require '../test'
they = require('ssh2-they').configure config

describe 'exec', ->

  they 'handle a command', ({ssh}, next) ->
    exec
      ssh: ssh
      command: "echo 'ok' && echo 'ko' >&2"
    , (err, stdout, stderr, code) ->
      stdout.should.eql 'ok\n'
      stderr.should.eql 'ko\n'
      code.should.eql 0
      next()

  they 'exec with error', ({ssh}, next) ->
    exec
      ssh: ssh
      command: "echo 'ok' && echo 'ko' >&2 && exit 42"
    , (err, stdout, stderr, code) ->
      stdout.should.eql 'ok\n'
      stderr.should.eql 'ko\n'
      code.should.eql 42
      err.message.should.equal [
        'Child process exited unexpectedly:'
        'code 42, no signal,'
        'got "ko"'
      ].join ' '
      next()
