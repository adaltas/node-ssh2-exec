
connect = require './connect'

###
Extends mocha with a function similar to `it` but 
running both locally and remotely
###
they = (msg, callback) ->
  it "#{msg} (local)", (next) ->
    callback.call @, null, next
  it "#{msg} (remote)", (next) ->
    connect host: 'localhost', (err, ssh) =>
      callback.call @, ssh, next
they.only = (mode, msg, callback) ->
  if arguments.length is 2
    callback = msg
    msg = mode
    mode = null
  local = ->
    it.only "#{msg} (local)", (next) ->
      callback.call @, null, next
  remote = ->
    it.only "#{msg} (remote)", (next) ->
      connect host: 'localhost', (err, ssh) =>
        callback.call @, ssh, next
  if mode
    switch mode
      when 'local'
        local()
      when 'remote'
        remote()
      else throw new Error "Invalid test mode #{mode}"
  else
    local()
    remote()
they.skip = (mode, msg, callback) ->
  if arguments.length is 2
    callback = msg
    msg = mode
    mode = null
  local = ->
    it.skip "#{msg} (local)", (next) ->
      callback.call @, null, next
  remote = ->
    it.skip "#{msg} (remote)", (next) ->
      connect host: 'localhost', (err, ssh) =>
        callback.call @, ssh, next
  if mode
    switch mode
      when 'local'
        local()
      when 'remote'
        remote()
      else throw new Error "Invalid test mode #{mode}"
  else
    local()
    remote()

module.exports = they