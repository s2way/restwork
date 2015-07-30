// Generated by CoffeeScript 1.9.3
(function() {
  'use strict';
  var HttpConnector, path, uuid;

  path = require('path');

  uuid = require('node-uuid');

  HttpConnector = (function() {
    function HttpConnector(deps) {
      this.restify = (deps != null ? deps.restify : void 0) || require('restify');
    }

    HttpConnector.prototype.post = function(params, callback) {
      var client;
      client = this.restify.createStringClient({
        url: params.url
      });
      path = (params != null ? params.path : void 0) || '';
      return client.post(path, params != null ? params.data : void 0, function(err, req, res, data) {
        if (err != null) {
          return callback(err);
        }
        return callback(null, data);
      });
    };

    return HttpConnector;

  })();

  module.exports = HttpConnector;

}).call(this);
