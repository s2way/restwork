fsConnector = require '../../src/connectors/fsConnector'
expect = require 'expect.js'

describe 'the fsConnector,', ->

    describe 'when being constructed', ->

        it 'should set the prefix to domain/resource', (done) ->

            params =
                domain: 'Pay'
                resource: 'Order'

            class nodePersistMock
                first = yes
                @createDirIfNotExists: (dir) ->
                    expect(dir).to.be 'Pay' if first
                    expect(dir).to.be 'Pay/Order' if !first
                    done() if !first
                    first = no

            instance = new fsConnector params, fs : nodePersistMock

    describe 'when creating a new file', (done) ->

        it 'should hand to the module the id as the filename and the data to be persisted ', (done) ->

            params =
                domain: 'Pay'
                resource: 'Order'

            expectedData =
                id: 123
                name: 'Michel Teló'

            class nodePersistMock
                @isFile: -> true

            instance = new fsConnector params, fs : nodePersistMock
            instance.create expectedData, (err) ->
                expect(err).not.to.be.ok()
                done()

        it 'should hand to the module the id as the filename and the data to be persisted ', (done) ->

            params =
                domain: 'Pay'
                resource: 'Order'

            expectedData =
                id: 123
                name: 'Michel Teló'

            class nodePersistMock
                @isFile: -> false
                @createFileIfNotExists: (filename, data) ->
                    expect(filename).to.be 123
                    expect(data).to.eql expectedData

            instance = new fsConnector params, fs : nodePersistMock
            instance.create expectedData, ->
                done()
