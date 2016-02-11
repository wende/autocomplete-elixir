regex = /(alias|import)\s+([\w.]+),? *(\w+)? *:? *(.+)?/

module.exports.getImportsAndAliases = (editor) ->
  range = new Range([0,0], editor.cursors[0].getBufferPosition().toArray())
  editor.backwardsScanInBufferRange regex, range, (m) ->
    
