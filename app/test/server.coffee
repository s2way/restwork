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
            instance.start()

            expect(restifyServerInstanceCreated).to.be.ok()

        it 'should call _loadRoutes', ->

            _loadRoutesCalled = false
            instance._loadRoutes = () ->
                _loadRoutesCalled = true
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
