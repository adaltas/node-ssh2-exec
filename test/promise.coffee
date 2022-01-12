
exec = require '../src/promise'
config = require '../test'
they = require('ssh2-they').configure config

describe 'promise', ->

  they 'handle a successful command', ({ssh}) ->
    {stdout, stderr, code} = await exec
      ssh: ssh
      command: 'echo ok && echo ko >&2 && exit 0'
    stdout.should.eql 'ok\n'
    stderr.should.eql 'ko\n'
    code.should.eql 0

  they 'handle a successful command', ({ssh}) ->
    try
      await exec
        ssh: ssh
        command: 'echo ok && echo ko >&2 && exit 42'
    catch err
      err.stdout.should.eql 'ok\n'
      err.stderr.should.eql 'ko\n'
      err.code.should.eql 42
  
