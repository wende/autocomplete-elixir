autocomplete = "autocompleter/autocomplete.exs"
Process = require("atom").BufferedProcess

spawn = require('child_process').spawn
path = require 'path'
fs = require 'fs'

out = null
inp  = null

exports.init = (projectPaths) ->
  p = path.join(__dirname, autocomplete)
  array = projectPaths
  stderr = (e) -> console.log("Err: #{e}")
  exit = (e) -> console.log("CLOSED #{e}"); exports.init(projectPaths)

  array.push(p)
  command = atom.config.get('my-package.thingVolume') || "elixir"

  ac = new Process({command: command, args: array.reverse(), stderr, exit})
  out = ac.process.stdout
  inp = ac.process.stdin
  # ac  = spawn("elixir", array.reverse())
  # out = ac.stdout
  # inp  = ac.stdin
  # ac.stderr.on("data", stderr)
  # ac.on("close", exit)
  # ac.stdout.setMaxListeners(2)

exports.getAutocompletion = (prefix, cb) ->
  if prefix.trim().length < 1
    cb()
    return
  inp.write "a #{prefix}\n"
  waitTillEnd (chunk) ->
    [_, one, multi] = chunk.split("<>")
    cb({one, multi: multi.split(";").filter((a) -> a.trim())})

exports.loadFile =          (path,   cb = (->)) ->
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
