TransactionHandler = require '../../app/Boundaries/TransactionHandler'
expect = require 'expect.js'

describe 'The Transaction Handler', ->

    describe 'the post method', ->

        instance = null
        defaultReq = 
            query:
                options: {}
        defaultRes =
            json: () ->
        defaultCallback = () ->

        beforeEach ->
            instance = new TransactionHandler
            instance._makeTransaction = () ->

        it 'should call the transactions makeTransaction method', ->
            makeTransactionCalled = false
            instance._makeTransaction = () ->
                makeTransactionCalled = true
            instance.post defaultReq, defaultRes, defaultCallback
            expect(makeTransactionCalled).to.be.ok()

        it 'should callback to restify after everything is finished', ->
            callbackCalled = false
            callback = () ->
                callbackCalled = true
            instance.post defaultReq, defaultRes, callback

        describe 'on makeTransaction error', ->

            it 'should call res.json with the response and status code', ->
                expectedError =
                    error: "Invalid transactions."
                expectedStatusCode = 500
                receivedError = {}
                receivedStatusCode = 0
                
                instance._makeTransaction = (params, callback) ->
                    callback expectedError
                res =
                    json: (statusCode, body) ->
                        receivedError = body
                        receivedStatusCode = statusCode

                instance.post defaultReq, res, defaultCallback
                expect(receivedError).to.eql expectedError
                expect(receivedStatusCode).to.eql expectedStatusCode

        describe 'on makeTransaction success', ->

            it 'should call res.json with the response and status code', ->
                expectedBody =
                    Body: "Invalid transactions."
                expectedStatusCode = 201
                receivedBody = {}
                receivedStatusCode = 0
                
                instance._makeTransaction = (params, callback) ->
                    callback null, expectedBody
                res =
                    json: (statusCode, body) ->
                        receivedBody = body
                        receivedStatusCode = statusCode

                instance.post defaultReq, res, defaultCallback
                expect(receivedBody).to.eql expectedBody
                expect(receivedStatusCode).to.eql expectedStatusCode

