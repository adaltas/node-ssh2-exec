
util = require 'util'
ssh2 = require 'ssh2'
connect = require './connect'
{EventEmitter} = require 'events'
Stream = require 'stream'
{exec} = require 'child_process'

ProxyStream = () ->
ProxyStream::pause = ->
  @paused = true
ProxyStream::resume = ->
  @paused = false
  @emit 'drain'
  # do nothing
util.inherits ProxyStream, Stream

module.exports = (options, callback) ->
  if options.ssh
    child = new EventEmitter
    child.stdout = new ProxyStream
    child.stderr = new ProxyStream
    connection = null
    run = ->
      stdout = stderr = ''
      connection.exec options.cmd, (err, stream) ->
        if err
          console.log 'error'
          callback err if callback
          return
        stream.on 'data', (data, extended) ->
          if extended is 'stderr'
            type = 'stderr'
            stderr += data if callback
          else
            type = 'stdout'
            stdout += data if callback
          child[type].emit 'data', data
        stream.on 'exit', (code, signal) ->
          if code isnt 0
            err = new Error 'Error'
            err.code = code
            err.signal = signal
          child.emit 'exit', code
          callback null, stdout, stderr if callback
    if options.ssh instanceof ssh2
      connection = options.ssh
      run()
    else
      connect options.ssh, (err, ssh2) ->
        if err
          callback err if callback
          return
        connection = ssh2
        run()
    child
  else
    cmdOptions = {}
    cmdOptions.env = options.env or process.env
    cmdOptions.cwd = options.cwd or null
    cmdOptions.uid = options.uid if options.uid
    cmdOptions.gid = options.gid if options.gid
    exec options.cmd, cmdOptions, callback


