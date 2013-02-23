
should = require 'should'
superexec = if process.env.SUPEREXEC_COV then require '../lib-cov/index' else require '../lib/index'
connect = if process.env.SUPEREXEC_COV then require '../lib-cov/connect' else require '../lib/connect'

describe 'exec', ->

  it 'handle a command and a callback', (next) ->
    connect host: 'localhost', (err, connection) ->
      return next err if err
      superexec
        ssh: connection
        cmd: 'ls -l'
      , (err, ssh2out, ssh2err) ->
        return next err if err
        superexec
          ssh: host: 'localhost'
          cmd: 'ls -l'
        , (err, sshout, ssherr) ->
          return next err if err
          ssh2out.should.eql sshout
          ssh2err.should.eql ssherr
          superexec
            cwd: process.env['HOME']
            cmd: 'ls -l'
          , (err, stdout, stderr) ->
            return next err if err
            sshout.should.eql stdout
            ssherr.should.eql stderr
            next()

  it 'handle a command without a callback', (next) ->
    connect host: 'localhost', (err, connection) ->
      return next err if err
      ssh2out = ssh2err = ''
      # SSH with ssh2 instance
      child = superexec 
        ssh: connection
        cmd: 'ls -l'
      child.stdout.on 'data', (data) ->
        ssh2out += data
      child.stderr.on 'data', (data) ->
        ssh2err += data
      child.on 'exit', (code) ->
        sshout = ssherr = ''
        # SSH with object
        child = superexec 
          ssh: host: 'localhost'
          cmd: 'ls -l'
        child.stdout.on 'data', (data) ->
          sshout += data
        child.stderr.on 'data', (data) ->
          ssherr += data
        child.on 'exit', (code) ->
          ssh2out.should.eql sshout
          ssh2err.should.eql ssherr
          # Local
          stdout = stderr = ''
          child = superexec 
            cwd: process.env['HOME']
            cmd: 'ls -l'
          child.stdout.on 'data', (data) ->
            stdout += data
          child.stderr.on 'data', (data) ->
            stderr += data
          child.on 'exit', (code) ->
            sshout.should.eql stdout
            ssherr.should.eql stderr
            next()

  it 'handle a failed command without a callback', (next) ->
    connect host: 'localhost', (err, connection) ->
      return next err if err
      sshout = ssherr = ''
      # SSH with ssh2 instance
      child = superexec 
        ssh: connection
        cmd: 'ls -l ~/doesntexist'
      child.stdout.on 'data', (data) ->
        sshout += data
      child.stderr.on 'data', (data) ->
        ssherr += data
      child.on 'exit', (sshcode) ->
        stdout = stderr = ''
        child = superexec 
          cmd: 'ls -l ~/doesntexist'
        child.stdout.on 'data', (data) ->
          stdout += data
        child.stderr.on 'data', (data) ->
          stderr += data
        child.on 'exit', (code) ->
          sshout.should.eql stdout
          ssherr.should.eql stderr
          sshcode.should.eql code
          next()







