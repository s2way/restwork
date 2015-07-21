class Transactions

    _newTransaction: (params) ->
        Transaction = require '../Entities/Transaction'
        return new Transaction(params)

    makeTransaction: (options, callback) ->
        transaction = null
        try
            transaction = @_newTransaction(options)
        catch err
            return callback err
        transaction.authorize()
        transaction.save()
        success =
            success: "Transaction created successfully"
        callback null, success


module.exports = Transactions