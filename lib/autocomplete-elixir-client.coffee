autocomplete = require('./alchemide/wrapper')
doendmather = require './alchemide/doendmatcher'
jumptodef = require './alchemide/jumptodef/jumptodef.coffee'

atom.commands.add 'atom-text-editor',
  'autocomplete-elixir:jump-to-definition': (event) ->
    editor = @getModel()
    if(/.exs?$/.test(editor.getTitle()))
      jumptodef.jump(editor)

module.exports =
class RsenseClient
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
