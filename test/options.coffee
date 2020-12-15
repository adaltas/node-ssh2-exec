
exec = require '../src/index'
config = require '../test'
they = require('ssh2-they').configure config

describe 'options', ->

  they 'env', ({ssh}, next) ->
    # Note, accepted environment variables 
    # is determined by the AcceptEnv server setting
    # default values are "LANG,LC_*"
    stdout = ''
    child = exec
      ssh: ssh
      env: 'LANG': 'fr'
      command: 'env | grep LANG'
    child.stdout.on 'data', (data) ->
      stdout += data
    child.on 'exit', (code) ->
      stdout.trim().should.eql 'LANG=fr'
      next()
