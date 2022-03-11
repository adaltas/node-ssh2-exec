
exec = require '../src/index'
{connect, they} = require './test'

describe 'exec', ->

  they 'handle a command', connect ({ssh}, next) ->
    exec
      ssh: ssh
      command: "echo 'ok' && echo 'ko' >&2"
    , (err, stdout, stderr, code) ->
      stdout.should.eql 'ok\n'
      stderr.should.eql 'ko\n'
      code.should.eql 0
      next()

  they 'exec with error', connect ({ssh}, next) ->
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
