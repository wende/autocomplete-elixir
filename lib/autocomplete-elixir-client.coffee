$ = require('jquery')
autocomplete = require('./new/wrapper')
String.prototype.replaceAll = (s,r) -> @split(s).join(r)

module.exports =
class RsenseClient
  projectPath: null
  serverUrl: null

  constructor: ->
    autocomplete.init(atom.project.getPaths())
    atom.workspace.observeTextEditors (editor) ->
      editor.onDidSave (e) ->
        autocomplete.loadFile(e.path)

  checkCompletion: (editor, buffer, row, column, prefix, callback) ->
    autocomplete.getAutocompletion prefix, (result) ->
      callback(result.map (a)-> {name: a, qualified_name:a, kind:"elixir"})
    return []
