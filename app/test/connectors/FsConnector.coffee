'use strict'

FsConnector = require '../../src/connectors/FsConnector'
expect = require 'expect.js'

describe 'the fsConnector,', ->

    describe 'when being constructed', ->

        it 'should set the prefix to domain/resource', (done) ->

            params =
                domain: 'Pay'
                resource: 'Order'

            class NodePersistMock
                first = yes
                @createDirIfNotExists: (dir) ->
                    expect(dir).to.be 'Pay' if first
                    expect(dir).to.be 'Pay/Order' if !first
                    done() if !first
                    first = no

            instance = new FsConnector params, fs : NodePersistMock

    describe 'when creating a new file', (done) ->

        it 'should return an error if the file already exists', (done) ->

            params =
                domain: 'Pay'
                resource: 'Order'

            expectedData =
                id: 123
                name: 'Michel Teló'

            class NodePersistMock
                @isFile: -> true

            instance = new FsConnector params, fs : NodePersistMock
            instance.create expectedData, (err) ->
                expect(err).to.be 'File already exists.'
                done()

        it 'should hand to the module the id as the filename and the data to be persisted ', (done) ->

            fileNameExpect = null
            dataExpect = null
            params =
                domain: 'Pay'
                resource: 'Order'

            expectedData =
                id: 123
                name: 'Michel Teló'

            class NodePersistMock
                @isFile: -> false
                @createFileIfNotExists: (filename, data) ->
                    expect(filename).to.be 'Pay/Order/123'
                    expect(data).to.eql JSON.stringify(expectedData)

            instance = new FsConnector params, fs : NodePersistMock
            instance.create expectedData, (error, response)->
                expect(response).to.be.ok()
                done()

        it 'should catch the exception if thrown', (done) ->

            fileNameExpect = null
            dataExpect = null
            params =
                domain: 'Pay'
                resource: 'Order'

            expectedData =
                id: 123
                name: 'Michel Teló'

            class NodePersistMock
                @isFile: -> false
                @createFileIfNotExists: (filename, data) ->
                    throw new Error 'Michel Teló'

            instance = new FsConnector params, fs : NodePersistMock
            instance.create expectedData, (error, response)->
                expect(error.toString()).to.be 'Error: Michel Teló'
                done()
