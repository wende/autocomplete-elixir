$ = require('jquery')
String.prototype.replaceAll = (s,r) -> @split(s).join(r)

module.exports =
class RsenseClient
  projectPath: null
  serverUrl: null

  constructor: ->
    @projectPath = atom.project.getPaths()[0]
    port = atom.config.get('autocomplete-elixir.port')
    @serverUrl = "http://localhost:4321/elixir/complete"

  checkCompletion: (editor, buffer, row, column, prefix, callback) ->
    code = buffer.getText().replaceAll '\n', '\n'
    console.log("Prefix: " +  prefix);
    $.ajax @serverUrl,
      type: 'GET'
      data: {word: prefix}
      error: (jqXHR, textStatus, errorThrown) ->
        console.error textStatus
      success: (data, textStatus, jqXHR) ->
        console.log data
        callback(JSON.parse(data).result.map (a)-> {name: a, qualified_name:a, kind:"elixir"})


    return []
