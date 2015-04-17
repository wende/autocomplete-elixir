RsenseClient = require './autocomplete-elixir-client.coffee'

module.exports =
class RsenseProvider
  id: 'autocomplete-elixir-elixirprovider'
  selector: '.source.elixir'
  rsenseClient: null

  constructor: ->
    @rsenseClient = new RsenseClient()


  requestHandler: (options) ->
    return new Promise (resolve) =>
      row = options.cursor.getBufferRow()
      col = options.cursor.getBufferColumn()

      prefix = options.editor.getTextInBufferRange([[row ,0],[row, col]])
      [... , prefix] = prefix.split(" ")
      unless prefix then resolve([])
      options.prefix = prefix

      completions = @rsenseClient.checkCompletion(options.editor,
      options.buffer, row, col, options.prefix, (completions) =>
        suggestions = @findSuggestions(options.prefix, completions)
        return resolve() unless suggestions?.length
        return resolve(suggestions)
      )

  findSuggestions: (prefix, completions) ->
    if completions?
      suggestions = []
      for completion in completions when completion.name isnt prefix
        one = completion.continuation
        kind = completion.kind.toLowerCase()
        word = completion.name.trim()
        label = completion.qualified_name
        count = parseInt(/\d+$/.exec(word)) || 0;
        func = /\d+$/.test(word)
        if func then word = word.split("/")[0] + "("
        i = 0
        while ++i <= count
          word += "${#{i}:#{i}}" + (if i != count then "," else "")
        if func
          word += ")"
          word += "${#{count+1}:\u0020}"

        [..., last] = prefix.split(".")
        suggestion =
          snippet:  if one then prefix + word else word
          prefix:  if one then prefix else last
          label: if completions.length > 1 then label else prefix + label
        suggestions.push(suggestion)
      return suggestions
    return []

  dispose: ->
