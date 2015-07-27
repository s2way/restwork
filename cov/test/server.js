// Generated by CoffeeScript 1.9.3
(function() {
  'use strict';
  var Server, expect;

  Server = require('../src/server');

  expect = require('expect.js');

  describe('The Server', function() {
    describe('start method', function() {
      var defaultPort, instance, startCallback;
      instance = null;
      defaultPort = 1234;
      startCallback = function() {};
      beforeEach(function() {
        instance = new Server;
        instance.routes = null;
        instance.restify = {
          createServer: function() {
            var server;
            return server = {
              listen: function() {}
            };
          }
        };
        instance._loadGeneralHandlers = function() {};
        return instance._loadRoutes = function() {};
      });
      it('should create a new restify server instance', function() {
        var restifyServerInstanceCreated;
        restifyServerInstanceCreated = false;
        instance.restify = {
          createServer: function() {
            var server;
            restifyServerInstanceCreated = true;
            return server = {
              listen: function() {}
            };
          }
        };
        instance._registerListeners = function() {};
        instance.start();
        return expect(restifyServerInstanceCreated).to.be.ok();
      });
      it('should call _loadRoutes', function() {
        var _loadRoutesCalled;
        _loadRoutesCalled = false;
        instance._loadRoutes = function() {
          return _loadRoutesCalled = true;
        };
        instance._registerListeners = function() {};
        instance.start();
        return expect(_loadRoutesCalled).to.be.ok();
      });
      return it('should call the listen method with the passed port callback', function() {
        var expectedCallback, expectedPort, receivedCallback, receivedPort;
        expectedPort = defaultPort;
        expectedCallback = startCallback;
        receivedPort = null;
        receivedCallback = null;
        instance.restify = {
          createServer: function() {
            var server;
            return server = {
              listen: function(port, callback) {
                receivedPort = port;
                return receivedCallback = callback;
              }
            };
          }
        };
        instance._registerListeners = function() {};
        instance.start(expectedPort, expectedCallback);
        expect(receivedPort).to.eql(expectedPort);
        return expect(receivedCallback).to.eql(expectedCallback);
      });
    });
    describe('_loadRoutes method', function() {
      var instance;
      instance = null;
      beforeEach(function() {
        return instance = new Server;
      });
      return it('should call server[method] with the right url according to the routes', function() {
        var receivedGetCalled, receivedGetUrl, receivedPutCalled, receivedPutUrl, routes;
        receivedPutCalled = false;
        receivedGetCalled = false;
        routes = {
          resource1: [
            {
              httpMethod: 'put',
              url: '/something1/',
              method: function() {
                return receivedPutCalled = true;
              }
            }
          ],
          resource2: [
            {
              httpMethod: 'get',
              url: '/something2/',
              method: function() {
                return receivedGetCalled = true;
              }
            }
          ]
        };
        receivedPutUrl = null;
        receivedGetUrl = null;
        instance.server = {
          put: function(route, func) {
            func();
            return receivedPutUrl = route;
          },
          get: function(route, func) {
            func();
            return receivedGetUrl = route;
          }
        };
        instance._loadRoutes(routes);
        expect(receivedPutCalled).to.be.ok();
        expect(receivedPutUrl).to.eql(routes.resource1[0].url);
        expect(receivedGetCalled).to.be.ok();
        return expect(receivedGetUrl).to.eql(routes.resource2[0].url);
      });
    });
    describe('_loadGeneralHandlers method', function() {
      var instance;
      instance = null;
      beforeEach(function() {
        return instance = new Server;
      });
      it('should add handlers to the server', function() {
        var methodsCalled;
        methodsCalled = [];
        instance.server = {
          use: function(methodName) {
            return methodsCalled.push(methodName);
          }
        };
        instance.restify = {
          authorizationParser: function() {
            return 'authorizationParser';
          },
          bodyParser: function() {
            return 'bodyParser';
          },
          queryParser: function() {
            return 'queryParser';
          }
        };
        instance.handlers = {
          authorizationParser: true,
          bodyParser: true,
          queryParser: true
        };
        instance._loadGeneralHandlers();
        expect(methodsCalled).to.contain('authorizationParser');
        expect(methodsCalled).to.contain('bodyParser');
        return expect(methodsCalled).to.contain('queryParser');
      });
      return it('should add handlers to the server', function() {
        var actualParams, methodsCalled, res;
        methodsCalled = [];
        actualParams = null;
        res = {
          sendUnauthenticated: function() {}
        };
        instance.server = {
          use: function(methodName) {
            methodName(null, res, function() {});
            return methodsCalled.push(methodName.toString());
          }
        };
        instance.restify = {
          authorizationParser: function() {
            var authorizationParser;
            return authorizationParser = function() {};
          },
          bodyParser: function() {
            var bodyParser;
            return bodyParser = function() {};
          },
          queryParser: function() {
            var queryParser;
            return queryParser = function() {};
          }
        };
        instance.handlers = {
          authorizationParser: true,
          bodyParser: true,
          queryParser: true,
          easyOauth: {
            enable: true,
            secret: 'secret',
            clients: 'clients',
            endpoint: 'endpoint',
            expiry: 'expiry'
          }
        };
        instance.oauth = {
          easyOauth: function(server, params) {
            return actualParams = params;
          }
        };
        instance._loadGeneralHandlers();
        expect(methodsCalled).to.contain(instance.restify.authorizationParser().toString());
        expect(methodsCalled).to.contain(instance.restify.bodyParser().toString());
        expect(methodsCalled).to.contain(instance.restify.queryParser().toString());
        expect(actualParams.secret).to.eql('secret');
        expect(actualParams.clients).to.eql('clients');
        expect(actualParams.endpoint).to.eql('endpoint');
        return expect(actualParams.tokenValidity).to.eql('expiry');
      });
    });
    return describe('_registerListeners method', function() {
      var instance;
      instance = null;
      beforeEach(function() {
        return instance = new Server;
      });
      return it('should register the default listeners', function() {
        var bkpLog, methodsCalled;
        methodsCalled = [];
        bkpLog = console.log;
        console.log = function() {};
        instance.server = {
          on: function(event, method) {
            methodsCalled.push(event);
            return method(null, null, null, {
              stack: 'stack'
            });
          }
        };
        instance.restify = {
          auditLogger: function() {
            var logger;
            return logger = function() {};
          }
        };
        instance.bunyan = {
          createLogger: function() {}
        };
        instance._log = function() {};
        instance._registerListeners();
        expect(methodsCalled).to.contain('after');
        expect(methodsCalled).to.contain('error');
        expect(methodsCalled).to.contain('uncaughtException');
        return console.log = bkpLog;
      });
    });
  });

}).call(this);