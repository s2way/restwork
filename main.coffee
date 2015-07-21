Server = require './fw/server'
Routes = require './app/routes'

routes = new Routes()
server = new Server routes.getRoutes()

server.start 1337, ->
    console.log "Started!"