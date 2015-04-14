
const RESULT_BUFFER_PERIOD = 100;

var server = require("../static");
var url = require('url');
var pty = require('../pty.js');
var helpers = require("./../helpers");
//var defRegExp = //helpers.$$$();

if(~process.argv.indexOf("--erlang-mode")) process.erlangMode = true;

/// INITIALIZATION
var erlCompServer = {};
var eliCompServer = {};
module.exports = erlCompServer;

server.on("/erl/complete", function(req, res){
    var parameters = url.parse(req.url, true).query;
    erlCompServer.awaitCompletion(parameters["word"], function(result){
        res.end(JSON.stringify({result : result}))
    });
});

server.on("/elixir/complete", function(req, res){
    var parameters = url.parse(req.url, true).query;
    eliCompServer.awaitCompletion(parameters["word"], function(result){
        res.end(JSON.stringify({result : result}))
    });
})

server.on("/erl/compile", function(req, res){
    var parameters = url.parse(req.url, true).query;
    erlCompServer.compile(parameters["module"].replace(/'/g,""), function(result){
        res.end(JSON.stringify(result, null, 2))
    })
});
server.on("/elixir/compile", function(req, res){
    var parameters = url.parse(req.url, true).query;
    eliCompServer.compile(parameters["module"].replace(/'/g,""), function(result){
        res.end(JSON.stringify(result, null, 2))
    })
});


server.on("/erl/dialyze", function(req, res){
    var parameters = url.parse(req.url, true).query;
    erlCompServer.dialyze(parameters["module"], function(result){
        res.end(JSON.stringify(result, null, 2))
    })
});

server.on("/erl/definition", function(req, res, par){
    var dirs = par["dirs"].replace(/'/g,"").split(",");
    var name = par["name"];
    var file = par["file"] || "";
    try {
      var regex =  new RegExp(name +"(.*) *->(.|\\n)*?\\.", "g");
      helpers.findDefinition(dirs, file+".erl",regex, function(result){
          res.end(JSON.stringify(result))
        })
    } catch (e){
      res.end("{result:[]}")
    }
});

(function(){
    var term = pty.spawn('erl', [], {
        name: 'xterm-color',
        cols: 80,
        rows: 30,
        cwd: process.env.HOME,
        env: process.env
    });
    term.on("error", function(e){throw e})

    erlCompServer.awaitCompletion =function(a,b,c){ awaitCompletion(a,b,c,term)}
    erlCompServer.compile = function(a,b) { compileModule(a,b, term)};
    erlCompServer.dialyze = dialyzeModule;
})();
(function(){
    var term = pty.spawn('iex', [], {
        name: 'xterm-color',
        cols: 80,
        rows: 30,
        cwd: process.env.HOME,
        env: process.env
    });
    term.on("error", function(e){throw e})

    eliCompServer.awaitCompletion =function(a,b,c){ awaitCompletion(a,b,c,term, true)}
    eliCompServer.compile = function(a,b) { compileModule(a,b, term, true)};
    eliCompServer.dialyze = dialyzeModule;
})();


function awaitCompletion(word, callback, acc, term, isElixir) {
    acc = acc | "";
    word = word || "";

    term.write(word + "\t");
    var counter = 2;

    var bufferEE = helpers.bufferEE(term, "data", function(data){
      try{
      data.split("\n").map(function(line){
          acc += line + " "
          if(word && (new RegExp("^"+word.trim())).test(line.trim()) && !isList(line)){
              counter--
          }
          else if(word && (new RegExp(word.trim()+"$")).test(line.trim())){
              counter--
          }
          if(!counter){
              bufferEE.flush()
          }
      })
    } catch(e){}
    }, RESULT_BUFFER_PERIOD , function(){

        callback(prepareResult(acc, !!word && !!counter, isElixir));
        term.write( (isElixir ? "" : ".") + "\n")
    })

}
function prepareResult(res, isOneLiner, isElixir) {

    try {
        var cake = res.match(/\S+/g);
        if (isElixir) {
            if (isOneLiner) {
                return [cake.join("").substr(1).replace(/\u0007/g, "")]
            }
            return cake.slice(1, cake.length - 2).map(function(a){
              return a.replace(/\u0007/g, "")
            })
        } else {

            if (isOneLiner) {
              // first result always looks weird "0application: "
                return /\D\S*/.exec(res).replace("\u0007", "")
            }
            return cake.slice(1, cake.length - 2).filter(function (a) {
              return a != "\u0007"
            }).map(function(a){
              return a.replace(/\u0007/g, "")
            })
        }
    } catch (e) {
        return []
    }
}

function compileModule(name, cb, term, isElixir){
    term.write("c(\"" + name + "\")" + (isElixir ? "\n" : ".\n"));
    var lines = [];
    var listenForData = function() {
        term.once("data", function (data) {
            var lastRes = false;
            data.split("\n").map(function (line) {
                var res = isElixir ? recognizeElixirLine(line) : recognizeCompilerLine(line);
                if (res) {
                    lines.push(res);
                    if (res.type == "result") {
                        cb(lines);
                        lastRes = true;
                    }
                }
            });
            if(!lastRes){
                listenForData()
            }
        })
    }
    listenForData()
}
function recognizeCompilerLine(line){
    //if tuple result
    if(!line.length) return undefined;
    line = line.trim();

    if(/^\{.*\}\s*$/.test(line) || /^\S*error*\S$/.test(line)){
        return {
            type: "result",
            content: line
        }
    }
    else
    {
        var cake = line.split(":");
        return {
            type: / error /.test(line) ? "error" : "warning" ,
            path: cake[0],
            line: cake[1],
            content: cake.slice(2).join(":")
        }
    }
}
function recognizeElixirLine(line){
    if(/\*\* \(/.test(line)){
        var cake;
        var result = line.match(/\*\* \(SyntaxError\).*/)
        result = result ? result : line.match(/\*\* \(CompileError\).*/)
        if(result){
            cake = result[0].replace(/\*\* \(SyntaxError\)/, "").split(":");
            return {
                type: "error",
                path: cake[0],
                line: cake[1],
                content: cake.slice(2).join(":")
            }
        }
        result = line.match(/\*\* \(exit\).*/)

        if(result){
            return {
                type: "result"
            }
        }
    } else if(line.match(/\S*:.*:.*/)){
        cake = line.split(":");
        return {
            type: "warning",
            path: cake[0],
            line: cake[1],
            content: cake.slice(2).join(":")
        }

    } else if(line.match(/iex\(/)){
        return {
            type: "result"
        }
    } else return undefined

}
function dialyzeModule(name, cb) {
    var dialTerm = pty.spawn('dialyzer', [name, "--quiet"], {
        name: 'xterm-color',
        cols: 80,
        rows: 30,
        cwd: process.env.HOME,
        env: process.env
    });
    var lines = [];
    var awaitData = function(){
        dialTerm.on("data", function(data){
            data.split("\n").map(function(line){
                if(line)lines.push(recognizeDialyzerLine(line))
            })
        })
    };
    dialTerm.on("exit", function(){
        cb(lines)
    });
    dialTerm.on("error", function(e){
        cb({err: e})
    });

    awaitData()
}
function recognizeDialyzerLine(line){
    var cake = line.split(":")
    return {path: cake[0], line: cake[1], content: cake.slice(2).join(":")}
}

function isList(w){
    return /\S+\s+\S+/.test(w)
}
