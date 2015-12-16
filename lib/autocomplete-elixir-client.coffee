$ = require('jquery')
autocomplete = require('./alchemide/wrapper')
doendmather = require './alchemide/doendmatcher'
String.prototype.replaceAll = (s,r) -> @split(s).join(r)

module.exports =
class RsenseClient
  projectPath: null
  serverUrl: null

  constructor: ->
    autocomplete.init(atom.project.getPaths())
    atom.workspace.observeTextEditors (editor) ->
      # Only if elixir files
      if(/.exs?$/.test(editor.getTitle()))
        editor.onDidSave (e) ->
          autocomplete.loadFile(e.path)
        editor.onDidChangeCursorPosition (e) ->
          doendmather.handleMatch(editor, e)

  checkCompletion: (prefix, callback) ->
    #console.log "Prefix: #{prefix}"
    autocomplete.getAutocompletion prefix, (result) ->
      #console.log result
      result = if result.one
         {result: [result.one], one: true}
        else
          {result: result.multi, one: false}
      callback(result.result.map (a)-> {continuation: result.one,name: a, spec:a})
    return []
