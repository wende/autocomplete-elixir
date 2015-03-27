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
      matcher = /\S*(\w|:|\.)$/.exec(prefix)
      unless matcher then resolve([])
      prefix = matcher[0]
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
        kind = completion.kind.toLowerCase()
        word = completion.name
        count = parseInt(/\d*$/.exec(word)) || 0;
        if count
          word = word.split("/")[0] + "("
          i = 0
          while ++i <= count then word += "${#{i}:#{i}}" + (if i != count then "," else ")")
          word += "${#{count+1}:_}"
        [..., last] = prefix.split(/(:|\.)/)
        suggestion =
          snippet: word
          prefix: last
          label: "#{completion.qualified_name}"
        suggestions.push(suggestion)
      return suggestions
    return []

  dispose: ->
