/**
 * FeathercoinController
 * 
 * @module :: Controller
 * @description :: A set of functions called `actions`.
 * 
 * Actions contain code telling Sails how to respond to a certain type of
 * request. (i.e. do stuff, then send some JSON, show an HTML page, or redirect
 * to another URL)
 * 
 * You can configure the blueprint URLs which trigger these actions
 * (`config/controllers.js`) and/or override them with custom routes
 * (`config/routes.js`)
 * 
 * NOTE: The code you write here supports both HTTP and Socket.io automatically.
 * 
 * @docs :: http://sailsjs.org/#!documentation/controllers
 */
var LinkPublisher = require("blockchain-link").LinkPublisher;
var LinkReader = require("blockchain-link").LinkReader;
var bitcoin = require('bitcoin');
var client = new bitcoin.Client({
	host : 'localhost',
	port : 8332,
	user : 'Kevlar',
	pass : 'zabbas',
});
client.opts = {
	version : 14
};
var db = LinkReader.getDB("Feathercoin", client);
var publisher = new LinkPublisher(client);
module.exports = {

	/**
	 * Action blueprints: `/feathercoin/search`
	 */
	search : function(req, res) {
		db.search(req.param("query"), function(result) {
			return res.json(result);
		});
	},

	/**
	 * Action blueprints: `/feathercoin/publish`
	 */
	publish : function(req, res) {

		var message = {};
		if (req.param("name")) {
			message.name = req.param("name");
		}
		if (req.param("description")) {
			message.description = req.param("description");
		}
		if (req.param("keywords")) {
			message.keywords = req.param("keywords");
		}
		if (req.param("payloadInline")) {
			message.payloadInline = req.param("payloadInline");
		}
		publisher.publish(message, 0.05, function(tx) {
			res.json({
				tx : tx
			});
		});
	},

	/**
	 * Action blueprints: `/feathercoin/view`
	 */
	view : function(req, res) {

		// Send a JSON response
		return res.view("home/index");
	},

	/**
	 * Overrides for the settings in `config/controllers.js` (specific to
	 * FeathercoinController)
	 */
	_config : {}

};
