Transactions = require '../../app/Interactors/Transactions'
expect = require 'expect.js'

describe 'The Transactions controller', ->

    instance = null
    successMessage = "Transaction created successfully"
    errorMessage = "Invalid transaction."
    defaultOptions = {}
    defaultCallback = () ->

    describe 'makeTransaction method', ->

        beforeEach ->
            instance = new Transactions

        it 'should create a new Transaction entity', ->
            newTransactionCalled = false
            instance._newTransaction = () ->
                newTransactionCalled = true
                transaction =
                    authorize: () ->
                    save: () ->

            instance.makeTransaction defaultOptions, defaultCallback

            expect(newTransactionCalled).to.be.ok()

        it 'should return an error if entity creation throws an error', (done) ->
            error =
                error: errorMessage
            instance._newTransaction = () ->
                throw error
            callback = (callbackError, callbackResponse) ->
                expect(callbackError).to.eql error
                done()

            instance.makeTransaction defaultOptions, callback

        it 'should try to authorize if the options are valid', ->
            authorizeCalled = false
            instance._newTransaction = () ->
                transaction =
                    authorize: () ->
                        authorizeCalled = true
                    save: () ->

            instance.makeTransaction defaultOptions, defaultCallback
            expect(authorizeCalled).to.be.ok()

        it 'should save the transaction after authorization is finished', ->
            saveCalled = false
            instance._newTransaction = () ->
                transaction =
                    authorize: () ->
                    save: () ->
                        saveCalled = true

            instance.makeTransaction defaultOptions, defaultCallback
            expect(saveCalled).to.be.ok()

        it 'should invoke the passed callback with ok if everything went right', (done) ->
            instance._newTransaction = () ->
                transaction =
                    authorize: () ->
                    save: () ->

            expectedResponse =
                success: successMessage

            callback = (err, response) ->
                expect(response).to.eql expectedResponse
                done()

            instance.makeTransaction defaultOptions, callback