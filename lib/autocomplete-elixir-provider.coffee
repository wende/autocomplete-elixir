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
      [... , prefix] = prefix.split(/[ ()]/)
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
        [word, spec] = completion.name.trim().split("@")
        console.log [word, spec]
        argTypes = null
        ret = null;
        if word[0] == word[0].toUpperCase() then ret = "Module"
        label = completion.spec
        if spec
          specs = spec.replace(/^\w+/,"")
          types = specs.substring(1,specs.length-1).split(",")
          label = specs
          [_, args, ret] = specs.match(/\((.+)\)\s*::\s*(.*)/)
          console.log [args, ret]
          argTypes = args.split(",")
        count = parseInt(/\d+$/.exec(word)) || 0;
        func = /\d+$/.test(word)
        if func then word = word.split("/")[0] + "("
        i = 0
        while ++i <= count
          if argTypes then word += "${#{i}:#{argTypes[i-1]}}" + (if i != count then "," else "")
          else word +=  "${#{i}:#{i}}" + (if i != count then "," else "")
        if func
          word += ")"
          word += "${#{count+1}:\u0020}"

        [..., last] = prefix.split(".")
        suggestion =
          snippet:  if one then prefix + word else word
          prefix:  if one then prefix else last
          label: if ret then ret else "any"
        suggestions.push(suggestion)
      return suggestions
    return []

  dispose: ->
