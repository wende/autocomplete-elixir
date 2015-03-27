#!/usr/bin/env node
var     EventEmitter =  require("events").EventEmitter
var server = new EventEmitter();
global.server = server;


var http = require("http")
  , path = require("path")
  , mime = require("mime")
  , url = require("url")
  , fs = require("fs")
  , port = process.env.PORT || 4321
  , ip = "localhost"


global.projectRoot = path.resolve(__dirname);


// compatibility with node 0.6
if (!fs.exists)
    fs.exists = path.exists;

var allowSave = process.argv.indexOf("--allow-save") != -1;

module.exports = server;
exports = server;
server.setMaxListeners(1);

//Launch plugins
require("./erlang/erlang.js");

try{
  var httpServer = http.createServer(receiveClient);
  httpServer.on("error", function (){})
  httpServer.listen(port, ip);


function receiveClient(req, res) {
    var uri = url.parse(req.url).pathname
      , filename = uri;

    if(exports.emit(uri, req, res, url.parse(req.url, true).query)){
        return
    }

    if(uri.length <= 1){
        uri = "/erlhickey.html"
    }

    if (req.method == "PUT") {
        save(req, res, filename);
    }

    filename = process.cwd() + filename
    fs.exists(filename, function(exists) {
        if (!exists)
            return error(res, 404, "404 Not Found\n");

        if (fs.statSync(filename).isDirectory()) {
            var files = fs.readdirSync(filename);
            res.writeHead(200, {"Content-Type": "text/html"});

            files.push(".", "..");
            var html = files.map(function(name) {
                try {
                    var href = uri + "/" + name;
                    href = href.replace(/[\/\\]+/g, "/").replace(/\/$/g, "");
                    if (fs.statSync(filename + "/" + name + "/").isDirectory())
                        href += "/";

                    return "<a href='" + href + "'>" + name + "</a><br>";
                }
                catch (e){
                    return ""
                }
            });

            res._hasBody && res.write(html.join(""));
            res.end();
            return;
        }

        fs.readFile(filename, "binary", function(err, file) {
            if (err) {
                res.writeHead(500, { "Content-Type": "text/plain" });
                res.write(err + "\n");
                res.end();
                return;
            }

            var contentType = mime.lookup(filename) || "text/plain";
            res.writeHead(200, { "Content-Type": contentType });
            res.write(file, "binary");
            res.end();
        });
    });
};

function error(res, status, message, error) {
    res.writeHead(status, { "Content-Type": "text/plain" });
    res.write(message);
    res.end();
}

function save(req, res, filePath) {
    var data = "";
    req.on("data", function(chunk) {
        data += chunk;
    });
    req.on("error", function() {
        error(res, 404, "Could't save file");
    });
    req.on("end", function() {
        try {
            fs.writeFileSync(filePath, data);
        }
        catch (e) {
            res.statusCode = 404;
            res.end("Could't save file");
            return;
        }
        res.statusCode = 200;
        res.end("OK");
    });
}

function getLocalIps() {
    var os = require("os");

    var interfaces = os.networkInterfaces ? os.networkInterfaces() : {};
    var addresses = [];
    for (var k in interfaces) {
        for (var k2 in interfaces[k]) {
            var address = interfaces[k][k2];
            if (address.family === "IPv4" && !address.internal) {
                addresses.push(address.address);
            }
        }
    }
    return addresses;
}

console.log("http://" + (ip == "0.0.0.0" ? getLocalIps()[0] : ip) + ":" + port);
} catch(e) {
  console.log("server already running")
}
//==================================================================
//=========================== ErlHickey ============================
//==================================================================
