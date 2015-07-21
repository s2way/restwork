Transactions = require '../Interactors/Transactions'

class TransactionHandler

    constructor: ->
        @transactions = new Transactions
    
    _makeTransaction: (options, callback) ->
        @transactions.makeTransaction options, callback

    post: (req, res, callback) ->
        console.log req.params
        meta = {} #req.headers
        params = 
            meta: meta
            data: req.params
        @_makeTransaction params, (error, success) ->
            response = if error? then error else success
            statusCode = if error? then 500 else 201
            res.json statusCode, response
        callback()

module.exports = TransactionHandler