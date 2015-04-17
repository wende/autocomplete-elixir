autocomplete = "autocomplete.exs"

spawn = require('child_process').spawn
path = require 'path'
fs = require 'fs'

out = null
inp  = null

exports.init = (projectPaths) ->
  p = path.join(__dirname, autocomplete)
  array = projectPaths
  array.push(p)
  ac  = spawn("elixir", array.reverse())
  out = ac.stdout
  inp  = ac.stdin
  ac.stderr.on("data", (e) -> console.log("Err: #{e}") )
  ac.on("close", (e) -> console.log("CLOSED #{e}"); init())

exports.getAutocompletion = (prefix, cb) ->
  if prefix.trim().length < 1
    cb()
    return
  inp.write "a #{prefix}\n"
  waitTillEnd (chunk) ->
    [_, one, multi] = chunk.split("|")
    cb(if one then [one] else multi.split(","))

exports.loadFile =          (path,   cb = (->)) ->
  unless /.ex$/.test(path)
    cb()
    return
  inp.write "l #{path}\n"
  waitTillEnd (cb || (->))

waitTillEnd = (cb) ->
  chunk = ""

  fn = (data) ->
    chunk += data
    if ~chunk.indexOf("ok.")
      out.removeListener "data", fn
      cb chunk.replace("ok.", "")
  out.on "data", fn
