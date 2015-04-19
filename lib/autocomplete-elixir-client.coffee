$ = require('jquery')
autocomplete = require('./alchemide/wrapper')
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
