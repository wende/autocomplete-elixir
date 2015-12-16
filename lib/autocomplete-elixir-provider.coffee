  IS_ELIXIR = true

  lang = if IS_ELIXIR then "elixir" else "erlang"

  RsenseClient = require "./autocomplete-#{lang}-client.coffee"


  module.exports =
  class RsenseProvider
    selector: ".source.#{lang}"
    rsenseClient: null

    constructor: ->
      @rsenseClient = new RsenseClient()

    getSuggestions: (request) ->
      return new Promise (resolve) =>
        row = request.bufferPosition.row
        col = request.bufferPosition.column

        prefix = request.editor.getTextInBufferRange([[row ,0],[row, col]])
        [... , prefix] = prefix.split(/[ ()]/)
        unless prefix then resolve([])
        #TODO check
        npref = /.*\./.exec prefix
        postfix = ""
        if npref
          postfix = prefix.replace(npref[0], "")
          prefix = npref[0]

        completions = @rsenseClient.checkCompletion(prefix, (completions) =>
          suggestions = @findSuggestions(prefix, postfix , completions)
          return resolve() unless suggestions?.length
          return resolve(suggestions)
        )

    findSuggestions: (prefix, postfix, completions) ->
      if completions?
        suggestions = []
        for completion in completions when (completion.name isnt prefix+postfix) and (completion.name.indexOf(postfix) == 0)

          one = completion.continuation
          [word, spec] = completion.name.trim().split("@")
          argTypes = null
          ret = null;
          if !word || !word[0] then continue
          if word[0] == word[0].toUpperCase() then [ret,isModule] = ["Module",true]
          label = completion.spec
          if spec
            specs = spec.replace(/^[\w!?]+/,"")
            types = specs.substring(1,specs.length-1).split(",")
            label = specs
            [_, args, ret] = specs.match(/\(?(.+)\)\s*::\s*(.*)/)
            #console.log [args, ret]
            argTypes = args.split(",")
          count = parseInt(/\d+$/.exec(word)) || 0;
          func = /\d+$/.test(word)
          if func then word = word.split("/")[0] + "("
          inserted = word;
          i = 0
          while ++i <= count
            if argTypes then word += "${#{i}:#{argTypes[i-1]}}" + (if i != count then "," else "")
            else word +=  "${#{i}:#{i}}" + (if i != count then "," else "")
            inserted += "${#{i}:#{i}}" + (if i != count then "," else "")


          if func
            word += ")${#{count+1}:\u0020}"
            inserted += ")${#{count+1}:\u0020}"
          [..., last] = (prefix + postfix).split(if IS_ELIXIR then "." else ":")

          type = "variable"
          if isModule then type = "method"
          if func     then type = "function"

          suggestion =
            snippet:  if one then prefix + postfix + word else word
            displayText:  (if one then prefix + postfix + word else word).replace(/\(.*\).*}/g, "/#{count}")
            replacementPrefix:  if one then prefix + postfix else last
            rightLabel: if ret then ret else "any"
            type: type
            description: spec || ret || "Desc"
            #inclusionPriority: -1
            #TODO excludeLowerPriority: true
          suggestions.push(suggestion)
        return suggestions
      return []

    dispose: ->
