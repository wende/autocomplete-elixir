{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null
  frontContext: []
  backContext: []
  blockNext : false;
  currentContext : null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'autocomplete-elixir:backward': => @backward()
      'autocomplete-elixir:forward': => @forward()
    self = this
    atom.workspace.observeTextEditors (editor) ->
      editor.onDidChangeCursorPosition (e) ->
        self.contextChanged editor.getPath(), e.newBufferPosition, e.textChanged

  deactivate: ->
    @subscriptions.dispose()

  forward: ->
    if editor = atom.workspace.getActiveTextEditor()
      if context = @frontContext.shift()
        @backContext.push @currentContext
        @setContext(editor, context)

  backward: ->
    if editor = atom.workspace.getActiveTextEditor()
      if context = @backContext.pop()
        @frontContext.unshift @currentContext
        @setContext(editor, context)


  contextChanged: (file, position, insert) ->
    # if cursor moves because of text input
    if insert
      @currentContext = {file, position}
      return;
    if @blockNext
      @blockNext = false;
      return
    if @currentContext
      @backContext.push @currentContext
      # clear redo history
      @frontContext = []
    @currentContext = {file, position}

  setContext: (editor, context) ->
    @blockNext = true;
    @setPosition(editor, context.file, context.position)
    @currentContext = context

  setPosition: (editor, file, position) ->
    if file == editor.getPath()
      editor.setCursorBufferPosition(position);
    else
      atom.workspace.open file, {
        initialLine : position.row
        initialColumn : position.column
      }
