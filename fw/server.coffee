class Server

    constructor: (@routes, @handlers) ->
        @restify = require 'restify'

    start: (port, startCallback) ->
        @server = @_createServer()
        @_loadGeneralHandlers()
        @_loadRoutes @routes
        @server.listen port, startCallback

    _createServer: () ->
        return @restify.createServer()

    _loadRoutes: (routes) ->
        for resource of routes
            resource = routes[resource]
            for action of resource
                action = resource[action]
                @server[action.httpMethod] action.url, action.method

    #TODO: Enable the use of configured general handlers (restify .use)
    _loadGeneralHandlers: () ->
        @server.use @restify.bodyParser()
        @server.use @restify.queryParser()

module.exports = Server