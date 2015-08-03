'use strict'

MySQLConnector = require '../../src/connectors/MySQLConnector'
expect = require 'expect.js'

describe 'the MySQLConnector,', ->

    describe 'when creating a new instance', ->

        it 'should throw an exception if one or more params was not passed', ->

            expect(->
                new MySQLConnector {}
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be 'Missing one or more arguments'
            )

        it 'should verify if the connection pool was created', ->

            createPoolCalled = false

            params =
                host : 'host'
                poolSize : 10000
                timeout : 10000
                user: 'user'
                password: 'password'
                domain: 'databaseName'
                resource: 'tableName'

            expectedParams =
                host: params.host
                database: params.domain
                user: params.user
                password: params.password
                connectionLimit: params.poolSize
                acquireTimeout: params.timeout
                waitForConnections: 0

            deps =
                mysql:
                    createPool: (params) ->
                        expect(params).to.eql expectedParams
                        createPoolCalled = true

            connector = new MySQLConnector params, deps
            expect(connector).to.be.ok()
            expect(connector.pool).to.be.ok()
            expect(createPoolCalled).to.be.ok()

    describe 'when reading a order', ->

        params = null

        beforeEach ->

            params =
                host : 'host'
                poolSize : 10000
                timeout : 10000
                user: 'user'
                password: 'password'
                domain: 'databaseName'
                resource: 'tableName'


        it 'should return an error if the order id is null', (done) ->

            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.read null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order id is undefined', (done) ->

            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.read undefined, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order id is zero', (done) ->

            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.read 0, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        # deverá retornar erro ao pegar uma nova conexão do pool de conexões
        it 'should return an ', (done) ->

            expectedError = 'Error getConnection'

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback 'Error to get connection'

            connector = new MySQLConnector params, deps
            connector.read 1, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the query error if it happens', (done) ->

            releaseMethodCalled = no

            expectedError = 'Error Query'

            mockedConnection =
                query: (query, params, callback) ->
                    callback expectedError
                release: ->
                    releaseMethodCalled = yes

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector params, deps

            connector._selectDatabase = (databaseName, connection, callback)->
                callback()

            connector.read 1, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                expect(releaseMethodCalled).to.be yes
                done()

        it 'should return the found row', (done) ->

            expectedRow =
                costumer_number: 1
                amount: 100

            mockedConnection =
                query: (query, params, callback) ->
                    callback null, expectedRow
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector params, deps
            connector.read 1, (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedRow
                done()

        it 'should return a NOT_FOUND error if nothing was found', (done) ->

            expectedRow =
                costumer_number: 1
                amount: 100

            mockedConnection =
                query: (query, params, callback) ->
                    callback()
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector params, deps
            connector.read 1, (error, response) ->
                expect(error).not.to.be 'NOT FOUND'
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the database selection went wrong', (done) ->

            expectedError = 'Error select database'

            mockedConnection =
                query: (query, params, callback) ->
                    callback()
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector params, deps

            connector._selectDatabase = (databaseName, connection, callback)->
                callback expectedError

            connector.read 1, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()