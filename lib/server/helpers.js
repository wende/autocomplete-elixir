var nodedir = require("node-dir")

module.exports.bufferEE = function(emiter, event ,onListener, period, after){
    emiter.on(event, onListener);

    var flush = function(){
        emiter.removeListener(event, onListener);
        after()
    };
    setTimeout(flush , period);

    return {
        flush : function(){
            clearTimeout(flush(), period);
            flush()
        }
    }
};

module.exports.findDefinition = function(dirs, fileName, definitionRegExp, callback) {
    lookInDirs(dirs );
    function lookInDirs(dirs) {
        if(!dirs.length){
            callback({err : null, result : null});
            return;
        }
        nodedir.readFiles(dirs[0], {exclude : /^\./, match: new RegExp(fileName)}, function (err, content, next) {
            if (err) {
                console.log("error")
                callback({err: err});
                lookInDirs(dirs.slice(1));
            } else {
                var result  = content.match(definitionRegExp);
                if(result)callback({result: result, err: null});
                else next()
            }
        }, function(err, files){
            if(err) callback({err: err})
            lookInDirs(dirs.slice(1));
        });
    }
}

module.exports.$$$ = function(){
    throw new Error("Not implemented yet");
};