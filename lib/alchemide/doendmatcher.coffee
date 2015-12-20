DO = "do"
END = "end"
FN = "fn"
DOEND = /(\Wdo\W|\Wend\W|\Wfn\W)/g
{Range, Point} = require("atom")
decorations = []


highlightRange = (editor, r) ->
  marker = editor.markBufferRange(r)
  decorations.push editor.decorateMarker(marker, {type: 'highlight', class: 'selection'})

module.exports.handleMatch = (editor, e) ->
  if not atom.config.get("autocomplete-elixir.matchDoEnd") then return
  decorations.map (a) -> a.destroy()

  lastLineNo = editor.buffer.lines.length - 1
  [x, y] = e.cursor.getBufferPosition().toArray()
  fromBeginning = new Range([0,0], [x, y-1])
  toEnd         = new Range([x, y+1], [lastLineNo, 0])

  word = editor.getWordUnderCursor()
  counter = 0;
  if word == DO
    highlightRange(editor, e.cursor.getCurrentWordBufferRange())
    editor.scanInBufferRange DOEND, toEnd, ({range: r, matchText: m, stop }) ->
      if m == DO or m == FN then counter++
      if m == END and counter then counter--
      else if !counter
        highlightRange(editor, r)
        stop()
  if word == END
    highlightRange(editor, e.cursor.getCurrentWordBufferRange())
    editor.backwardsScanInBufferRange DOEND, fromBeginning, ({range: r, matchText: m, stop }) ->
      if m == END then counter++
      if (m == DO || m == FN) && counter then counter--
      else if !counter
        highlightRange(editor, r)
        stop()
