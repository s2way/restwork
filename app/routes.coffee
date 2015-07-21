class Routes

    constructor: ->
        @TransactionHandler = require './Boundaries/TransactionHandler'

    getRoutes: () ->
        routes =
            transaction:
                doTransaction:
                    httpMethod: 'post'
                    url: 'transactions'
                    method: (req, res, next) =>
                        th = new @TransactionHandler
                        th.post req, res, next

module.exports = Routes