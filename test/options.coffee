
exec = require '../lib/index'
{connect, they} = require './test'

describe 'options', ->

  they 'env', connect ({ssh}, next) ->
    return next() if ssh and process.env.CI_DISABLE_SSH_ENV
    # Note, accepted environment variables 
    # is determined by the AcceptEnv server setting
    # default values are "LANG,LC_*"
    # Note, PermitUserEnvironment must equal `yes`
    stdout = ''
    child = exec
      ssh: ssh
      env: 'LANG': 'tv'
      command: 'env | grep LANG'
    child.stdout.on 'data', (data) ->
      stdout += data
    child.on 'exit', (code) ->
      stdout.trim().should.eql 'LANG=tv'
      next()
