DO = /(?!do:)\bdo\b/
END = /\bend\b/
FN = /\bfn\b/
DOEND = /(?!do:)(\bdo\b|\bend\b|\bfn\b)/g
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
  if DO.test(word)
    highlightRange(editor, e.cursor.getCurrentWordBufferRange())
    editor.scanInBufferRange DOEND, toEnd, ({range: r, matchText: m, stop }) ->
      if DO.test(m) or FN.test(m) then counter++
      if END.test(m) and counter then counter--
      else if !counter
        highlightRange(editor, r)
        stop()
  if END.test(word)
    highlightRange(editor, e.cursor.getCurrentWordBufferRange())
    editor.backwardsScanInBufferRange DOEND, fromBeginning, ({range: r, matchText: m, stop }) ->
      if END.test(m) then counter++
      if (DO.test(m) || FN.test(m)) && counter then counter--
      else if !counter
        highlightRange(editor, r)
        stop()
