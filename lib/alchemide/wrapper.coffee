IS_ELIXIR = true

autocomplete = "autocompleter/autocomplete.exs"
Process = require("atom").BufferedProcess

spawn = require('child_process').spawn
path = require 'path'
fs = require 'fs'


out = null
inp  = null
projectPaths = null;
lastError = null;

error = (e) -> atom.notifications.addError("Woops. Something went bananas \n Error: #{e}") #console.log("Err: #{e}")

exports.init = (pP) ->
  projectPaths = pP;
  p = path.join(__dirname, autocomplete)
  array = projectPaths
  stderr = (e) -> lastError = e #console.log("Err: #{e}")
  exit = (e) -> console.error("CLOSED #{e}, Last Error: #{lastError}"); exports.init(projectPaths)

  array.push(p)
  name = if IS_ELIXIR then 'autocomplete-elixir' else 'autocomplete-erlang'
  setting = atom.config.get("#{name}.elixirPath").replace(/elixir$/,"")
  command = path.join ( setting || "") , "elixir"
  console.log(setting)
  ac = new Process({command: command, args: array.reverse(), stderr, exit, stdout: ->})
  unless ac.process then exports.init(pP)

  out = ac.process.stdout
  inp = ac.process.stdin
  


exports.getAutocompletion = (prefix, cb) ->
  unless inp then exports.init(projectPaths)
  if prefix.trim().length < 1
    cb()
    return
  cmd = if IS_ELIXIR then "a" else "ea"
  inp.write "#{cmd} #{prefix}\n"
  waitTillEnd (chunk) ->
    [_, one, multi] = chunk.split("<>")
    cb({one, multi: multi.split(";").filter((a) -> a.trim())})

exports.loadFile =          (path,   cb = (->)) ->
  unless inp then exports.init(projectPaths)
  unless /.ex$/.test(path)
    cb()
    return
  inp.write "l #{path}\n"
  waitTillEnd (chunk) ->
    console.log("File load #{path} -> #{chunk}")
    if cb then cb(chunk)

waitTillEnd = (cb) ->
  chunk = ""

  fn = (data) ->
    chunk += data
    if ~chunk.indexOf("ok.")
      out.removeListener "data", fn
      cb chunk.replace("ok.", "")
  out.on "data", fn
