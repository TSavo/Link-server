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
    return requests.del data.key if not data.createdOn? or data.createdOn + 86400000 < new Date().getTime()
    client.getReceivedByAddress data.value.sendAddress, (err, amount)->
      console.log amount, ",", data.value.total
      if parseFloat(parseFloat(amount).toFixed(8)) >= parseFloat(parseFloat(data.value.total).toFixed(8))
        requests.del data.key
        publisher.publish data.value.message, (txid)->
          sails.io.sockets.emit data.value.sendAddress,
            message:data.value.message
            txid:txid

setInterval checkRequests, 10000

goals =[
  name:"Enhanced&nbsp;Search&nbsp;Results&nbsp;/&nbsp;Individual&nbsp;Results&nbsp;Page"
  address:"6pUfvyapR9LRc2ZkuqQ6bpEXh2SWqURuNf"
  goal:250
,
  name:"Support for Uploading .torrent Files"
  address:"6zNNPA8ibHDW7BF6ZQQppEGShiXSBRA8sG"
  goal:250
,
  name:"Live Data Feed of Freshly Published Data"
  address:"72eJHaib1NXC7Cj4ZnZ1uLJWJhrMEozU6r"
  goal:100
,
  name:"Search and Publish REST API"
  address:"6g43o9GuaoMSVCnGLxEKinz5ruKiWMcioW"
  goal:100
,
  name:"Streaming API"
  address:"6w7qoMY37xHniUtEJG3HjuM1Z9wGVCv4nE"
  goal:50
,
  name:"RSS Feeds"
  address:"6jQepsnaz4SsttSp8T4GGykZNJHcdRzfrx"
  goal:100
,
  name:"Tag Cloud"
  address:"6fpVwBM6MDzyEk6pWG6gBP279mrweFHJfA"
  goal:100
,
  name:"Upvoting/Downvoting&nbsp;Content&nbsp;(via&nbsp;the&nbsp;blockchain)"
  address:"6sjSzGikzrYnoTGE5DwVqWfGnBHhsfitYY"
  goal:500
,
  name:"Bitcoin Support (Publishing and Searching)"
  address:"6rcwJeWe4bSz8PeNdiQfNGRVFn6WRhTiPR"
  goal:250
,
  name:"Litecoin Support (Publishing and Searching)"
  address:"6npNZx2NkhJJGALNUTaULxdNzXqAd4Wk31"
  goal:250
,
  name:"Dogecoin Support (Publishing and Searching)"
  address:"71boFB9XC5HVYfVkmX2yYXeS4qCpCXjk7w"
  goal:250
,
  name:"Catcoin Support (Publishing and Searching)"
  address:"6v8PYXBgyYH69r9bnLxuHtgasSjTqcCUZK"
  goal:250
,
  name:"Worldcoin Support (Publishing and Searching)"
  address:"6tLwa8143KH5mzGZodqsdWmBtmqxeRNgQD"
  goal:250
,
  name:"Phoenixcoin Support (Publishing and Searching)"
  address:"6phyjrjvoUtctr2KovhH8QuoRcpa9TQfAB"
  goal:250
,  
  name:"Digitalcoin Support (Publishing and Searching)"
  address:"6ofqYZqHrReuSAXaaTjaFVXFgKbzfiDW4m"
  goal:250
,
  name:"Infinitecoin Support (Publishing and Searching)"
  address:"6sLdmuPHYhAe6YPTzAUbUoqWRo5NEFRVMd"
  goal:250
,
  name:"Twitter Tip Bot (Unrelated to Link)"
  address:"71dFhNDRziPCphXdhayAFCKnwxyut6z9ox"
  goal:2500
,
  name:"Pizza and Beer for the Developer of Link"
  address:"72A5GTNfUR18U8VZGK4UaJHSi2u1i5JZie"
  goal:100
]

getBalance = (address, callback)->
  client.getReceivedByAddress address, (err, amount)->
    return console.log err if err?
    callback amount

updateGoals = ()->
 for key, value of goals
   do (key)->
     getBalance goals[key].address, (amount)->
       goals[key].balance = amount
     
broadcastGoals = ()->
  console.log goals
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
        createdOn:new Date().getTime()
  
  ###
  Action blueprints: `/feathercoin/view`
  ###
  view: (req, res) ->
    
    # Send a JSON response
    res.view "home/index"
  
  keywords: (req, res) ->
    res.json glossary.extract req.param "query"
  goals:(req, res)->
    res.json goals
    
  ###
  Overrides for the settings in `config/controllers.js` (specific to
  FeathercoinController)
  ###
  _config: {}