RsenseProvider = require './autocomplete-elixir-provider.coffee'
delorean = require "./delorean/delorean.coffee"

module.exports =
  config:
    matchDoEnd:
      type: 'boolean'
      default: true
      description: "Highlight matching [do|fn]/[end] constructs"
    elixirPath:
      type: 'string'
      default: ""
      description: "Absolute path to elixir executable (essential for MacOS)"
    erlangHome:
      type: 'string'
      default: ""
      description: "Absolute path to erlang bin directory (essential for MacOS)"

  rsenseProvider: null

  activate: (state) ->
    @rsenseProvider = new RsenseProvider()
    delorean.activate(state);

  provideAutocompletion: ->
    [@rsenseProvider]

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
