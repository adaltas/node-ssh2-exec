
# Module `exec`

`exec(sshOrNull, command, [options], [callback])`
`exec(options, [callback])`

    {EventEmitter} = require 'events'
    stream = require 'stream'
    {exec} = require 'child_process'

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

    module.exports = () ->
      if arguments.length is 1
        options = arguments[0]
      else if arguments.length is 2
        if typeof arguments[1] is 'function'
          options = arguments[0]
          callback = arguments[1]
        else
          options = {}
          options.ssh = arguments[0]
          options.cmd = arguments[1]
      else if arguments.length is 3
        if typeof arguments[2] is 'function'
          callback = arguments[2]
          options = {}
        else
          options = arguments[2]
        options.ssh = arguments[0]
        options.cmd = arguments[1]
      else if arguments.length is 4
        options = arguments[2]
        options.ssh = arguments[0]
        options.cmd = arguments[1]
        callback = arguments[3]
      else 
        throw new Error 'Invalid arguments'
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
      options.cmd = "cd #{options.cwd}; #{options.cmd}" if options.cwd
      cmdOptions = {}
      cmdOptions.env = options.env if options.env
      cmdOptions.pty = options.pty if options.pty
      cmdOptions.x11 = options.x11 if options.x11
      options.ssh.exec options.cmd, cmdOptions, (err, stream) ->
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
          child.emit 'exit', code, signal
          if code isnt 0
            if stderr.trim().length
              err = stderr.trim().split('\n')
              err = err[err.length-1]
            else
              err = "Child process exited unexpectedly: #{JSON.stringify code}"
            err = new Error err
            err.code = code
            err.signal = signal
          if options.end
            connection.end()
            connection.on 'error', ->
              callback err
            connection.on 'close', ->
              callback err, stdout, stderr if callback
          else
            callback err, stdout, stderr if callback
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
      cmdOptions = {}
      cmdOptions.env = options.env or process.env
      cmdOptions.cwd = options.cwd or null
      cmdOptions.uid = options.uid if options.uid
      cmdOptions.gid = options.gid if options.gid
      # With Node 0.10.10, we wrap because child is an instance of old stream API
      stdout = new stream.Readable
      stderr = new stream.Readable
      child = exec options.cmd, cmdOptions, callback
      child.stdout = stdout.wrap child.stdout
      child.stderr = stderr.wrap child.stderr
      child


