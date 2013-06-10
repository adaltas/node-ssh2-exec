
ssh2 = require 'ssh2'
fs = require 'fs'

module.exports = (options, callback) ->
  return callback null, options if options instanceof ssh2
  # Default options
  options.username ?= process.env['USER']
  options.port ?= 22
  if not options.password and not options.privateKey
    options.privateKeyPath ?= '~/.ssh/id_rsa'
    if options.privateKeyPath and match = /~(\/.*)/.exec options.privateKeyPath
      options.privateKeyPath = process.env.HOME + match[1]
  else
    options.privateKeyPath = null
  privateKeyPath = ->
    return connect() unless options.privateKeyPath
    fs.readFile options.privateKeyPath, 'ascii', (err, privateKey) ->
      options.privateKey = privateKey
      connect()
  connect = ->
    connection = new ssh2()
    connection.on 'error', (err) ->
      connection.end()
      callback err
    connection.on 'ready', ->
      callback null, connection
    connection.connect options
  privateKeyPath()