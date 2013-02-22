
ssh2 = require 'ssh2'
fs = require 'fs'

module.exports = (options, callback) ->
    options.username ?= process.env['USER']
    options.port ?= 22
    if not options.password and not options.privateKey
      options.privateKey = fs.readFileSync("#{process.env['HOME']}/.ssh/id_rsa")
    connection = new ssh2()
    connection.on 'error', (err) ->
      callback err
    connection.on 'ready', ->
      callback null, connection
    connection.connect options