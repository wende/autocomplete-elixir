symbolDict = {};
filesDict = {}
$$$ = () -> throw new Error("Not implemented yet")

wordRegex = /[a-zA-Z0-9.:]*/

notifyJump = (fun) ->
  keyb = atom.keymaps.findKeyBindings({command:"autocomplete-elixir:backward"})
  atom.notifications.addInfo("Jumped to #{fun} definition \n Press #{keyb[0].keystrokes} to return.")
jumpToRange = (r) -> editor.setCursorBufferPosition(r.start)
jumpToRangeInFile = (f, r) ->
  atom.workspace.open f, {
    initialLine : r.start.row
    initialColumn : r.start.column
  }
resolveSymbol = $$$
loadSTDSymbols = $$$
loadProjectSymbols = $$$
updateProjectSymbol = $$$
getImportsAndAliases = $$$
initRefreshOnFileSave = $$$

module.exports.init = (editor) ->
  loadSTDSymbols(editor)
  loadProjectSymbols(editor)
  initRefreshOnFileSave(editor)

module.exports.jump = (editor) ->
  word = editor.getWordUnderCursor({wordRegex})
  aliasDict = getImportsAndAliases(editor)
  
  console.log(word)
  [fun, mod...] = word.split(".").reverse()
  mod.reverse()
  
  [mod, fun] = resolveSymbol(mod, fun, aliasDict)
  if !mod.length #we've got alias or local call
    console.log("local jump #{fun}")
    found = false;
    editor.scan new RegExp("def(macro)? #{fun}"), (m) ->
      jumpToRange(m.range)
      found = true;
      notifyJump(fun)
    atom.notifications.addInfo("No #{fun} definition found") unless found
  else # we've got project or stdlib call
    
