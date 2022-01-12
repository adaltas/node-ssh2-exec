
# Module `exec`

`exec(sshOrNull, command, [options], [callback])`
`exec(options..., [callback])`

    {EventEmitter} = require 'events'
    stream = require 'stream'
    {exec, spawn} = require 'child_process'

## Options

* `ssh`   
  SSH connection if the command must run remotely   
* `command`   
  Command to run unless provided as first argument   
* `cwd`   
  Current working directory   
* `end`   
  Close the SSH connection on exit, default to true if an ssh connection
  instance is provided.   
* `env`   
  An environment to use for the execution of the command.   
* `pty`   
  Set to true to allocate a pseudo-tty with defaults, or an object containing
  specific pseudo-tty settings. Apply only to SSH remote commands.   
* `cwd`   
  Apply only to local commands.   
* `uid`   
  Apply only to local commands.   
* `gid`   
  Apply only to local commands.  

## Source Code

    module.exports = () ->
      args = [].slice.call(arguments)
      options = {}
      for arg, i in args
        if arg is null or arg is undefined
          throw Error "Invalid Argument: argument #{i} cannot be null, the connection is already set" if 'ssh' in options
          options.ssh = arg
        else if is_ssh_connection arg
          throw Error "Invalid Argument: argument #{i} cannot be an SSH connection, the connection is already set" if 'ssh' in options
          options.ssh = arg
        else if is_object arg
          if arg.cmd
            arg.command = arg.cmd
            console.warn('Option `cmd` is deprecated in favor of `command`')
          for k, v of arg
            options[k] = v
        else if typeof arg is 'string'
          throw Error "Invalid Argument: argument #{i} cannot be a string, a command already exists" if 'command' in options
          options.command = arg
        else if typeof arg is 'function'
          throw Error "Invalid Argument: argument #{i} cannot be a function, a callback already exists" if callback
          callback = arg
        else
          throw Error "Invalid arguments: argument #{i} is invalid, got #{JSON.stringify arg}"
      if options.ssh
        remote options, callback
      else
        local options, callback

    remote = module.exports.remote = (options, callback) ->
      child = new EventEmitter
      child.stdout = new stream.Readable
      child.stdout._read = (_size) ->
      child.stderr = new stream.Readable
      child.stderr._read = ->
      child.kill = (signal='KILL') ->
        # IMPORTANT: doesnt seem to work, test is skipped
        # child.stream.write '\x03'
        # child.stream.end '\x03'
        child.stream.signal signal if child.stream
      stdout = stderr = ''
      options.command = "cd #{options.cwd}; #{options.command}" if options.cwd
      commandOptions = {}
      commandOptions.env = options.env if options.env
      commandOptions.pty = options.pty if options.pty
      commandOptions.x11 = options.x11 if options.x11
      options.ssh.exec options.command, commandOptions, (err, stream) ->
        return callback err if err and callback
        return child.emit 'error', err if err
        child.stream = stream
        stream.stderr.on 'data', (data) ->
          child.stderr.push data
          stderr += data if callback
        stream.on 'data', (data) ->
          child.stdout.push data
          stdout += data if callback
        code = signal = null
        exitCalled = stdoutCalled = stderrCalled = false
        exit = ->
          return unless exitCalled and stdoutCalled and stderrCalled
          child.stdout.push null
          child.stderr.push null
          child.emit 'close', code, signal
          child.emit 'exit', code, signal
          if code isnt 0
            if stderr.trim().length
              debug = stderr.trim().split(/\r\n|[\n\r\u0085\u2028\u2029]/g)[0]
            err = Error [
              'Child process exited unexpectedly: '
              "code #{JSON.stringify code}"
              if signal
              then ", signal #{JSON.stringify signal}"
              else ", no signal"
              ", got #{JSON.stringify debug}" if debug
            ].join ''
            err.code = code
            err.signal = signal
          if options.end
            connection.end()
            connection.on 'error', (err) ->
              callback err
            connection.on 'close', ->
              callback err, stdout, stderr, code if callback
          else
            callback err, stdout, stderr, code if callback
        stream.on 'error', (err) ->
          console.error 'error', err
        stream.on 'exit', ->
          exitCalled = true
          [code, signal] = arguments
          exit()
        stream.on 'end', ->
          stdoutCalled = true
          exit()
        stream.stderr.on 'end', ->
          stderrCalled = true
          exit()
      child

    local = module.exports.local = (options, callback) ->
      commandOptions = {}
      commandOptions.env = options.env or process.env
      commandOptions.cwd = options.cwd or null
      commandOptions.uid = options.uid if options.uid
      commandOptions.gid = options.gid if options.gid
      commandOptions.stdio = options.stdio if options.stdio
      if callback
        exec options.command, commandOptions, (err, stdout, stderr, args...) ->
          if err
            if stderr.trim().length
              debug = stderr.trim().split(/\r\n|[\n\r\u0085\u2028\u2029]/g)[0]
            {code, signal} = err
            err = Error [
              "Child process exited unexpectedly: "
              "code #{JSON.stringify err.code}, "
              if err.signal
              then "signal #{JSON.stringify err.signal}"
              else "no signal"
              ", got #{JSON.stringify debug}" if debug
            ].join ''
            err.code = code
            err.signal = signal
          callback err, stdout, stderr, err?.code or 0, args...
      else
        spawn options.command, [], Object.assign commandOptions, shell: options.shell or true

## Utilities

    is_ssh_connection = (obj) ->
      !!obj?.config?.host
      
    is_object = (obj) ->
      obj and typeof obj is 'object' and not Array.isArray obj
