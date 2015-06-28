RsenseProvider = require './autocomplete-elixir-provider.coffee'

module.exports =
  config:
    elixirPath:
      type: 'string'
      default: ""
      description: "Absolute path to elixir executable (essential for MacOS)"

  rsenseProvider: null

  activate: (state) ->
    @rsenseProvider = new RsenseProvider()

  provideAutocompletion: ->
    [@rsenseProvider]

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
