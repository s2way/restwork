'use strict'

Server = require '../src/server'
expect = require 'expect.js'

describe 'The Server', ->

    describe 'start method', ->

        instance = null
        defaultPort = 1234
        startCallback = () ->

        beforeEach ->
            instance = new Server
            instance.routes = null
            instance.restify =
                createServer: () ->
                    server =
                        listen: () ->
            instance._loadGeneralHandlers = () ->
            instance._loadRoutes = () ->

        it 'should create a new restify server instance', ->

            restifyServerInstanceCreated = false
            instance.restify =
                createServer: () ->
                    restifyServerInstanceCreated = true
                    server =
                        listen: () ->
            instance._registerListeners = () ->

            instance.start()

            expect(restifyServerInstanceCreated).to.be.ok()

        it 'should call _loadRoutes', ->

            _loadRoutesCalled = false
            instance._loadRoutes = () ->
                _loadRoutesCalled = true
            instance._registerListeners = () ->

            instance.start()

            expect(_loadRoutesCalled).to.be.ok()

        it 'should call the listen method with the passed port callback', ->

            expectedPort = defaultPort
            expectedCallback = startCallback
            receivedPort = null
            receivedCallback = null

            instance.restify =
                createServer: () ->
                    server =
                        listen: (port, callback) ->
                            receivedPort = port
                            receivedCallback = callback
            instance._registerListeners = () ->

            instance.start expectedPort, expectedCallback
            expect(receivedPort).to.eql expectedPort
            expect(receivedCallback).to.eql expectedCallback


    describe '_loadRoutes method', ->

        instance = null

        beforeEach ->
            instance = new Server

        it 'should call server[method] with the right url according to the routes', ->
            receivedPutCalled = false
            receivedGetCalled = false
            
            routes =
                resource1: [
                    {
                        httpMethod: 'put'
                        url: '/something1/'
                        method: ->
                            receivedPutCalled = true
                    }
                ]
                resource2: [
                    {
                        httpMethod: 'get'
                        url: '/something2/'
                        method: ->
                            receivedGetCalled = true
                    }
                ]

            receivedPutUrl = null
            receivedGetUrl = null

            instance.server =
                put : (route, func) ->
                    func()
                    receivedPutUrl = route
                get : (route, func) ->
                    func()
                    receivedGetUrl = route

            instance._loadRoutes routes

            expect(receivedPutCalled).to.be.ok()
            expect(receivedPutUrl).to.eql routes.resource1[0].url
            expect(receivedGetCalled).to.be.ok()
            expect(receivedGetUrl).to.eql routes.resource2[0].url

    describe '_loadGeneralHandlers method', ->

        instance = null

        beforeEach ->
            instance = new Server

        it 'should add handlers to the server', ->

            methodsCalled = []

            instance.server =
                use : (methodName) ->
                    methodsCalled.push methodName
            instance.restify =
                authorizationParser : ->
                    'authorizationParser'
                bodyParser : ->
                    'bodyParser'
                queryParser : ->
                    'queryParser'
            instance.handlers =
                authorizationParser : true
                bodyParser : true
                queryParser : true
            instance._loadGeneralHandlers()

            expect(methodsCalled).to.contain 'authorizationParser'
            expect(methodsCalled).to.contain 'bodyParser'
            expect(methodsCalled).to.contain 'queryParser'


         it 'should add handlers to the server', ->

            methodsCalled = []
            actualParams = null
            res =
                sendUnauthenticated : ->

            instance.server =
                use : (methodName) ->
                    methodName(null, res, ->)
                    methodsCalled.push methodName.toString()
            instance.restify =
                authorizationParser : ->
                    authorizationParser = ->
                bodyParser : ->
                    bodyParser = ->
                queryParser : ->
                    queryParser = ->
            instance.handlers =
                authorizationParser : true
                bodyParser : true
                queryParser : true
                easyOauth :
                    enable : true
                    secret : 'secret'
                    clients : 'clients'
                    endpoint:  'endpoint'
                    expiry: 'expiry'
            instance.oauth =
                easyOauth : (server, params)->
                    actualParams = params
            instance._loadGeneralHandlers()

            expect(methodsCalled).to.contain instance.restify.authorizationParser().toString()
            expect(methodsCalled).to.contain instance.restify.bodyParser().toString()
            expect(methodsCalled).to.contain instance.restify.queryParser().toString()
            expect(actualParams.secret).to.eql 'secret'
            expect(actualParams.clients).to.eql 'clients'
            expect(actualParams.endpoint).to.eql 'endpoint'
            expect(actualParams.tokenValidity).to.eql 'expiry'

    describe '_registerListeners method', ->

        instance = null

        beforeEach ->
            instance = new Server

        it 'should register the default listeners', ->

            methodsCalled = []

            instance.server =
                on:(event, method) ->
                    methodsCalled.push event
                    method null, null, null, stack: 'stack'
            instance.restify =
                auditLogger: ->
                    logger = ->
            instance.bunyan =
                createLogger: ->
            instance._log = ->

            instance._registerListeners()
            expect(methodsCalled).to.contain 'after'
            expect(methodsCalled).to.contain 'error'
            expect(methodsCalled).to.contain 'uncaughtException'
