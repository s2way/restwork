class Server

    constructor: (@routes, @handlers) ->
        @restify = require 'restify'

    start: (port, startCallback) ->
        @server = @_createServer()
        @_loadGeneralHandlers()
        @_loadRoutes @routes
        bunyan = require 'bunyan'
        # @server.on 'after', @restify.auditLogger(
        #     log: bunyan.createLogger(
        #         name: 'audit'
        #         stream: process.stdout
        #     )
        # )
        @server.listen port, startCallback


    _createServer: () ->
        return @restify.createServer()

    _loadRoutes: (routes) ->
        for key, resource of routes
            for route in resource
                @server[route.httpMethod] route.url, route.method

    #TODO: Enable the use of configured general handlers (restify .use)
    _loadGeneralHandlers: () ->
        @server.use @restify.bodyParser(mapParams: false)
        @server.use @restify.queryParser(mapParams: false)

module.exports = Server