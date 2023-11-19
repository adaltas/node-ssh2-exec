
# Module `exec/promise`

    exec = require '.'

    module.exports = (...args) ->
      if typeof args[args.length - 1] is 'function'
        throw Error 'Last argument cannot be a callback function'
      new Promise (resolve, reject) ->
        exec ...args, (err, stdout, stderr, code) ->
          if err
            err.stdout = stdout
            err.stderr = stderr
            reject err
          else
            resolve stdout: stdout, stderr: stderr, code: code
