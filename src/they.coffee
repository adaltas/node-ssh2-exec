
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
  switch mode
    when 'local'
      it.only "#{msg} (local)", (next) ->
        callback.call @, null, next
    when 'remote'
      it.only "#{msg} (remote)", (next) ->
        connect host: 'localhost', (err, ssh) =>
          callback.call @, ssh, next
    else throw new Error "Invalid test mode #{mode}"
they.skip = (mode, msg, callback) ->
  switch mode
    when 'local'
      it.skip "#{msg} (local)", (next) ->
        callback.call @, null, next
    when 'remote'
      it.skip "#{msg} (remote)", (next) ->
        connect host: 'localhost', (err, ssh) =>
          callback.call @, ssh, next
    else throw new Error "Invalid test mode #{mode}"

module.exports = they