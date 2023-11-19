
exec = require '../src/promises'
{connect, they} = require './test'

describe 'promise', ->

  they 'handle a successful command', connect ({ssh}) ->
    {stdout, stderr, code} = await exec
      ssh: ssh
      command: 'echo ok && echo ko >&2 && exit 0'
    stdout.should.eql 'ok\n'
    stderr.should.eql 'ko\n'
    code.should.eql 0

  they 'handle a successful command', connect ({ssh}) ->
    try
      await exec
        ssh: ssh
        command: 'echo ok && echo ko >&2 && exit 42'
    catch err
      err.stdout.should.eql 'ok\n'
      err.stderr.should.eql 'ko\n'
      err.code.should.eql 42
  
