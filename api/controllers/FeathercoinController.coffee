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

@docs :: http:// sailsjs.org/#!documentation/controllers
###


glossary = require("glossary")
  blacklist: ["x264", "x", "x264-FoV", "-FoV"]
  collapse:true


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
client.version= 14
db = LinkReader.getDB "Feathercoin", client
requests = new levelup "Feathercoin-requests", 
    valueEncoding: 'json'


publisher = new LinkPublisher(client)

db.on "put", (key, value) ->
  sails.io.sockets.emit "newContent", value

checkRequests = ()->
  requests.createReadStream().on "data", (data)->
    client.getReceivedByAddress data.value.sendAddress, (err, amount)->
      console.log amount, ",", data.value.total
      if parseFloat(parseFloat(amount).toFixed(8)) >= parseFloat(data.value.total).toFixed(8)
        requests.del data.key
        publisher.publish data.value.message, (txid)->
          sails.io.sockets.emit data.value.sendAddress,
            message:data.value.message
            txid:txid

setInterval checkRequests, 10000

goals =[
  name:"Enhanced Search Results / Individual Results Page"
  address:""
  goal:250
,
  name:"Support for Uploading .torrent Files"
  address:""
  goal:250
,
  name:"Live Data Feed of Freshly Published Data"
  address:""
  goal:100
,
  name:"Search and Publish REST API"
  address:""
  goal:100
,
  name:"Streaming API"
  address:""
  goal:50
,
  name:"RSS Feeds"
  address:""
  goal:100
,
  name:"Tag Cloud"
  address:""
  goal:100
,
  name:"Bitcoin Support (Publishing and Searching)"
  address:""
  goal:250
,
  name:"Litecoin Support (Publishing and Searching)"
  address:""
  goal:250
,
  name:"Dogecoin Support (Publishing and Searching)"
  address:""
  goal:250
,
  name:"Catcoin Support (Publishing and Searching)"
  address:""
  goal:250
,
  name:"Worldcoin Support (Publishing and Searching)"
  address:""
  goal:250
,
  name:"Phoenixcoin Support (Publishing and Searching)"
  address:""
  goal:250
,  
  name:"Digitalcoin Support (Publishing and Searching)"
  address:""
  goal:250
,
  name:"Infinitecoin Support (Publishing and Searching)"
  address:""
  goal:250
,
  name:"Twitter Tip Bot (Unrelated to Link)"
  address:""
  goal:2500
,
  name:"Pizza and Beer for the Developer of Link"
  address:""
  goal 50
]
          
getBalance = (address, callback)->
  client.getBalance address, (err, amount)->
    return console.log err if err?
    callback amount

updateGoals = ()->
 for x in goals
   do (x)->
     getBalance goals[x].address, (amount)->
       goals[x].balance = amount
     
broadcastGoals = (goals)->
  sails.io.sockets.emit "goals", goals

setInterval updateGoals, 15000
setInterval broadcastGoals, 30000

module.exports =
  
  ###
  Action blueprints: `/feathercoin/search`
  ###
  search: (req, res, next) ->
    db.search req.param("query"), (result) ->
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
    console.log message
    addresses = publisher.encodeAddresses message
    total = publisher.getMessageCost addresses
    client.getNewAddress (err, sendAddress)->
      return console.log(err) if err?
      console.log sendAddress
      res.json
        addresses:addresses
        total:parseFloat(total)
        sendAddress:sendAddress
        message:message
      requests.put sendAddress, 
        message:message
        total:parseFloat(total)
        sendAddress:sendAddress
  
  ###
  Action blueprints: `/feathercoin/view`
  ###
  view: (req, res) ->
    
    # Send a JSON response
    res.view "home/index"
  
  keywords: (req, res) ->
    res.json glossary.extract req.param "query"

    
  ###
  Overrides for the settings in `config/controllers.js` (specific to
  FeathercoinController)
  ###
  _config: {}