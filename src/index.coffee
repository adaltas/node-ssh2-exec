
util = require 'util'
ssh2 = require 'ssh2'
connect = require './connect'
{EventEmitter} = require 'events'
stream = require 'stream'
{exec} = require 'child_process'

###
`exec([command], options, [callback])`
------------------------------------

Valid `options` properties are:   
-   `ssh`   SSH connection if the command must run remotely   
-   `cmd`   Command to run unless provided as first argument   
-   `cwd`   Current working directory   
-   `end`   Close the SSH connection on exit, default to true if an ssh connection instance is provided.   
-   `env`   An environment to use for the execution of the command.   
-   `pty`   Set to true to allocate a pseudo-tty with defaults, or an object containing specific pseudo-tty settings. Apply only to SSH remote commands.   
-   `cwd`   Apply only to local commands.   
-   `uid`   Apply only to local commands.   
-   `gid`   Apply only to local commands.  
###
module.exports = (command, options, callback) ->
  if typeof arguments[0] is 'string'
    unless arguments.length is 3 or arguments.length is 2
      return callback new Error 'Invalid arguments'
  else
    if arguments.length is 2
      callback = options
      options = command
      command = options.cmd
    else if arguments.length is 1
      options = command
      command = options.cmd
    else
      return callback new Error 'Invalid arguments'
  if options.ssh
    child = new EventEmitter
    child.stdout = new stream.Readable
    child.stdout._read = (_size) ->
    child.stderr = new stream.Readable
    child.stderr._read = -> 
    connection = null
    run = ->
      stdout = stderr = ''
      exit = false # We've seen cases where data is emited after exit
      command = "cd #{options.cwd}; #{command}" if options.cwd
      cmdOptions = {}
      cmdOptions.env = options.env if options.env
      cmdOptions.pty = options.pty if options.pty
      connection.exec command, cmdOptions, (err, proc) ->
        return callback err if err and callback
        proc.on 'data', (data, extended) ->
          return if exit
          if extended is 'stderr'
            child.stderr.push data
            stderr += data if callback
          else
            child.stdout.push data
            stdout += data if callback
        proc.on 'exit', (code, signal) ->
          # We had problem where data was fired
          # after exit in wand
          process.nextTick ->
            if code isnt 0
              if stderr.trim().length
                err = stderr.trim().split('\n')
                err = err[err.length-1]
              else
                err = 'Child process exited abnormally'
              err = new Error err
              err.code = code
              err.signal = signal
            exit = true
            child.stdout.push null
            child.stderr.push null
            child.emit 'exit', code
            if options.end
              connection.end()
              connection.on 'error', ->
                callback err
              connection.on 'close', ->
                callback err, stdout, stderr if callback
            else
              callback err, stdout, stderr if callback
    if options.ssh instanceof ssh2
      connection = options.ssh
      options.end ?= false
      run()
    else
      connect options.ssh, (err, ssh2) ->
        if err
          callback err if callback
          return
        options.end ?= true
        connection = ssh2
        run()
    child
  else
    cmdOptions = {}
    cmdOptions.env = options.env or process.env
    cmdOptions.cwd = options.cwd or null
    cmdOptions.uid = options.uid if options.uid
    cmdOptions.gid = options.gid if options.gid
    # With Node 0.10.10, child is an instance of old stream
    stdout = new stream.Readable
    stderr = new stream.Readable
    child = exec command, cmdOptions, callback
    child.stdout = stdout.wrap child.stdout
    child.stderr = stderr.wrap child.stderr
    child


