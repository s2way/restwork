'use strict'

fs = require 'fs'

class Server

    constructor: (@routes, @handlers, deps) ->
        @restify = deps?.restify || require 'restify'
        @bunyan = deps?.bunyan || require 'bunyan'
        @oauth = deps?.oauth || require 'restwork-oauth'

    start: (port, startCallback) ->
        @server = @_createServer()
        @_loadGeneralHandlers()
        @_loadRoutes @routes
        @_registerListeners()
        @server.listen port, startCallback

    setCertificatePath: (certificatePath) ->
        @_certificatePath = certificatePath

    _createServer: ->
        if @_certificatePath

            ssl_certificate_path = @_certificatePath.certificate
            ssl_key_path = @_certificatePath.key

            console.log '---------------------------------------'
            console.log "CERTIFICATE PATH #{ssl_certificate_path}"
            console.log "KEY PATH         #{ssl_key_path}"
            console.log '---------------------------------------'

            if ssl_certificate_path? and ssl_key_path?
                return @restify.createServer({
                    certificate: fs.readFileSync "#{ssl_certificate_path}",
                    key: fs.readFileSync "#{ssl_key_path}"
                })
        return @restify.createServer()


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

    _registerListeners: ->
        @server.on 'after', @restify.auditLogger(
            log: @bunyan.createLogger(
                name: 'audit'
                stream: process.stdout
            )
        )
        @server.on 'error', (req, res, route, err) ->
            console.log err?.stack || err
        @server.on 'uncaughtException', (req, res, route, err) ->
            console.log err?.stack || err

    

module.exports = Server