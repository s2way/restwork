error = 
    error: "Invalid transaction."
class Transaction

    _isValid: (params) ->
        true
    constructor: (params) ->
        throw error unless @_isValid params
        @params = params

    authorize: () ->

    save: () ->

module.exports = Transaction