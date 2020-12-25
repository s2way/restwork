uuid = require 'node-uuid'
_ = require 'lodash'

class Server

    constructor: (@routes, @handlers, deps) ->
        @restify = deps?.restify or require 'restify'
        @bunyan = deps?.bunyan or require 'bunyan'
        @oauth = deps?.oauth or require 'restwork-oauth'
        @activeConnections = {}
        @healthz = false;

    start: (port, startCallback, @connTimeout = 30000) ->
        @server = @_createServer()
        @_loadGeneralHandlers()
        @_loadRoutes @routes
        @_registerListeners()
        @server.listen port, startCallback

    close: (cb) ->
        # give some time to connections to end for themselves
        connDestroy = setTimeout =>
            # ... otherwise, destroy'em
            conn.destroy() for key, conn of @activeConnections
        , @connTimeout
        @server.close cb

    setHealthz: (bool) ->
        @healthz = bool

    _createServer: ->
        if @_ssl_certificate? and @_ssl_key?
            return @restify.createServer({
                certificate: @_ssl_certificate,
                key: @_ssl_key
            })
        server = @restify.createServer()

        if @healthz

            server.use (req, res, next) ->
                req.resource = unless req.route.path instanceof RegExp then req.route.path.replace('/', ' ').trim().split('/') else ''
                next()

            server.get "/healthz", (req, res, next) -> res.send('OK'); next()
            server.get "/", (req, res, next) -> res.send('OK'); next()

        server.use (req, resp, next) ->
            req.id = uuid.v4()
            console.log "#{new Date().toISOString()} - REQUEST  # #{req.id} :: method: #{req.route?.method}, path: #{req._url?.path}"
            next()
        server

    _loadRoutes: (routes) ->
        for key, resource of routes
            for route in resource
                @server[route.httpMethod] route.url, route.method

    #TODO: Enable the use of configured general handlers (restify .use)
    _loadGeneralHandlers: ->
        if @handlers?.cors?
            @restify.CORS.ALLOW_HEADERS.push 'authorization'
            @server.use @restify.CORS()
        @server.use @restify.authorizationParser() if @handlers?.authorizationParser?
        @server.use @restify.bodyParser(mapParams: false) if @handlers?.bodyParser?
        @server.use @restify.queryParser(mapParams: false) if @handlers?.queryParser?
        if @handlers?.easyOauth?.enable
            @oauth.easyOauth @server, @handlers.easyOauth
            @server.use (req, res, next) ->
                return res.sendUnauthenticated() unless req?.username?
                next()
        if @handlers.custom?
            for handler in @handlers.custom
                @server.use handler

    _registerListeners: ->
        @server.on 'after', (req, res, route, error) ->
            reqId = if _.isFunction(req?.id) then req?.id() else req?.id
            console.log "#{new Date().toISOString()} - RESPONSE # #{reqId} :: method: #{req?.route?.method}, path: #{req?._url?.path}, status: #{res?.statusCode}"
        @server.on 'error', (req, res, route, err) ->
            console.log err?.stack or err
        @server.on 'uncaughtException', (req, res, route, err) ->
            console.log err?.stack or err
        @server.on 'connection', (conn) =>
            key = "#{conn?.remoteAddress}:#{conn?.remotePort}"
            @activeConnections[key] = conn
            conn?.on 'close', => delete @activeConnections[key]

    ssl_certificate: (certificateFile) ->
        @_ssl_certificate = certificateFile

    ssl_key: (keyFile) ->
        @_ssl_key = keyFile

module.exports = Server
