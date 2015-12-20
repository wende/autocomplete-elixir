wordRegex = /[a-zA-Z0-9.:]*/

module.exports.jump = (editor) ->
  word = editor.getWordUnderCursor({wordRegex})
  console.log(word)
  [fun, mod...] = word.split(".").reverse()
  mod.reverse()
  console.log([fun, mod])
  if !mod.length #we've got alias or local call
    console.log("local jump #{fun}")
    found = false;
    editor.scan new RegExp("def(macro)? #{fun}"), (m) ->
      editor.setCursorBufferPosition(m.range.start)
      found = true;
      keyb = atom.keymaps.findKeyBindings({command:"autocomplete-elixir:backward"})
      console.log(keyb)
      atom.notifications.addInfo("Jumped to #{fun} definition \n Press #{keyb[0].keystrokes} to return.")
    atom.notifications.addInfo("No #{fun} definition found") unless found
  else #we've got project or stdlib call
    1
