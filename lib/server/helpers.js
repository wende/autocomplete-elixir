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

module.exports.$$$ = function(){
    throw new Error("Not implemented yet");
};
