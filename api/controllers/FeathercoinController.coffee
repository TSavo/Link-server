###
FeathercoinController

@module :: Controller
@description :: A set of functions called `actions`.

Actions contain code telling Sails how to respond to a certain type of
request. (i.e. do stuff, then send some JSON, show an HTML page, or redirect
to another URL)

You can configure the blueprint URLs which trigger these actions
(`config/controllers.js`) and/or override them with custom routes
(`config/routes.js`)

NOTE: The code you write here supports both HTTP and Socket.io automatically.

@docs :: http://sailsjs.org/#!documentation/controllers
###
LinkPublisher = require("blockchain-link").LinkPublisher
LinkReader = require("blockchain-link").LinkReader
levelup = require("levelup")
bitcoin = require("bitcoin")
client = new bitcoin.Client(
  host: "localhost"
  port: 8332
  user: "Kevlar"
  pass: "zabbas"
)
client.opts = version: 14
db = LinkReader.getDB("Feathercoin", client)
requests = new levelup("Feathercoin-requests")

publisher = new LinkPublisher(client)
db.on "put", (key, value) ->
  sails.io.sockets.emit "newContent", value


  
module.exports =
  
  ###
  Action blueprints: `/feathercoin/search`
  ###
  search: (req, res, next) ->
    console.log "requesting"
    db.search req.param("query"), (result) ->
      console.log result
      res.socket.emit "searchResult", result

    next()

  
  ###
  Action blueprints: `/feathercoin/publish`
  ###
  publish: (req, res) ->
    message = {}
    message.name = req.param("name")  if req.param("name")
    message.description = req.param("description")  if req.param("description")
    message.keywords = req.param("keywords")  if req.param("keywords")
    message.payloadInline = req.param("payloadInline")  if req.param("payloadInline")
    publisher.publish message, (tx) ->
      res.json tx: tx


  
  ###
  Action blueprints: `/feathercoin/view`
  ###
  view: (req, res) ->
    
    # Send a JSON response
    res.view "home/index"

  
  ###
  Overrides for the settings in `config/controllers.js` (specific to
  FeathercoinController)
  ###
  _config: {}