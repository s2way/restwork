'use strict'

HttpConnector = require '../../src/connectors/HttpConnector'
expect = require 'expect.js'

describe 'the HttpConnector,', ->

    describe 'when the post method is called', (done) ->

        it 'should instantiate restify http client with the passed url', (done) ->

            expectedUrl = 'http://localhost:1234'
            receivedUrl = null

            class Restify
                @createStringClient: (options)->
                    receivedUrl = options.url
                    mockPost =
                        post: ->

            deps =
                restify: Restify

            params =
                url: expectedUrl

            instance = new HttpConnector deps
            instance.post params, ->
            expect(receivedUrl).to.eql expectedUrl
            done()

        it 'should call post with the right params', ->

            expectedPath = '/'
            receivedPath = null
            expectedData =
                message: 'Test data'
            receivedData = null

            class Restify
                @createStringClient: (options)->
                    client =
                        post: (path, object, callback) ->
                            receivedPath = path
                            receivedData = object

            deps =
                restify: Restify

            params =
                url: ''
                path: expectedPath
                data: expectedData

            instance = new HttpConnector deps
            instance.post params, ->
            expect(receivedPath).to.eql expectedPath
            expect(receivedData).to.eql expectedData

        it 'should return an error if there was an error in the request', (done) ->

            expectedError =
                message: 'Any error'

            class Restify
                @createStringClient: (options)->
                    client =
                        post: (path, object, callback) ->
                            callback expectedError

            deps =
                restify: Restify

            params =
                url: ''
                path: '/'
                data: {}

            instance = new HttpConnector deps
            instance.post params, (error, success)->
                expect(error).to.eql expectedError
                expect(success).not.to.be.ok()
                done()

        it 'should return the response from the request', (done) ->

            expectedResponse =
                message: 'Any response'

            class Restify
                @createStringClient: (options)->
                    client =
                        post: (path, object, callback) ->
                            callback null, null, null, expectedResponse

            deps =
                restify: Restify

            params =
                url: ''
                path: '/'
                data: {}

            instance = new HttpConnector deps
            instance.post params, (error, success)->
                expect(error).not.to.be.ok()
                expect(success).to.eql expectedResponse
                done()