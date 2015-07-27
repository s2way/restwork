// Generated by CoffeeScript 1.9.3
(function() {
  'use strict';
  var Server;

  Server = (function() {
    function Server(routes1, handlers, deps) {
      this.routes = routes1;
      this.handlers = handlers;
      this.restify = (deps != null ? deps.restify : void 0) || require('restify');
      this.bunyan = (deps != null ? deps.bunyan : void 0) || require('bunyan');
      this.oauth = (deps != null ? deps.oauth : void 0) || require('restwork-oauth');
    }

    Server.prototype.start = function(port, startCallback) {
      this.server = this._createServer();
      this._loadGeneralHandlers();
      this._loadRoutes(this.routes);
      this._registerListeners();
      return this.server.listen(port, startCallback);
    };

    Server.prototype._createServer = function() {
      return this.restify.createServer();
    };

    Server.prototype._loadRoutes = function(routes) {
      var key, resource, results, route;
      results = [];
      for (key in routes) {
        resource = routes[key];
        results.push((function() {
          var i, len, results1;
          results1 = [];
          for (i = 0, len = resource.length; i < len; i++) {
            route = resource[i];
            results1.push(this.server[route.httpMethod](route.url, route.method));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    Server.prototype._loadGeneralHandlers = function() {
      var params, ref, ref1, ref2, ref3, ref4;
      if (((ref = this.handlers) != null ? ref.authorizationParser : void 0) != null) {
        this.server.use(this.restify.authorizationParser());
      }
      if (((ref1 = this.handlers) != null ? ref1.bodyParser : void 0) != null) {
        this.server.use(this.restify.bodyParser({
          mapParams: false
        }));
      }
      if (((ref2 = this.handlers) != null ? ref2.queryParser : void 0) != null) {
        this.server.use(this.restify.queryParser({
          mapParams: false
        }));
      }
      if ((ref3 = this.handlers) != null ? (ref4 = ref3.easyOauth) != null ? ref4.enable : void 0 : void 0) {
        params = {
          secret: this.handlers.easyOauth.secret,
          clients: this.handlers.easyOauth.clients,
          endpoint: this.handlers.easyOauth.endpoint,
          tokenValidity: this.handlers.easyOauth.expiry
        };
        this.oauth.easyOauth(this.server, params);
        return this.server.use(function(req, res, next) {
          if ((req != null ? req.username : void 0) == null) {
            res.sendUnauthenticated();
          }
          return next();
        });
      }
    };

    Server.prototype._registerListeners = function() {
      this.server.on('after', this.restify.auditLogger({
        log: this.bunyan.createLogger({
          name: 'audit',
          stream: process.stdout
        })
      }));
      this.server.on('error', function(req, res, route, err) {
        return console.log(err.stack);
      });
      return this.server.on('uncaughtException', function(req, res, route, err) {
        return console.log(err.stack);
      });
    };

    return Server;

  })();

  module.exports = Server;

}).call(this);