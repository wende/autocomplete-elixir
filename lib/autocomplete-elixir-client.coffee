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
      console.log result
      result = if result.one
         {result: [result.one], one: true}
        else
          {result: result.multi, one: false}
      callback(result.result.map (a)-> {continuation: result.one,name: a, qualified_name:a, kind:"elixir"})
    return []
