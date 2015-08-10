'use strict'

# TIU DÛ:
  # - Exportar QueryBuilder
  # - Esta classe deve ser static (instancia apenas uma vez)

class MySQLConnector

    NOT_FOUND_ERROR = 'NOT_FOUND'

    constructor: (params, deps) ->

        @rules = require('waferpie-utils').Rules
        exceptions = require('waferpie-utils').Exceptions

        if !@rules.isUseful(params)
            throw new exceptions.Fatal exceptions.INVALID_ARGUMENT, 'Missing arguments'
        
        @mysql = deps?.mysql || require 'mysql'

        host = params?.host || null
        poolSize = params?.poolSize || null
        timeout = params?.timeout || 10000
        user = params?.user || null
        password = params?.password || ''
        @database = params?.domain || null
        @table = params?.resource || null

        if !@rules.isUseful(host) or !@rules.isUseful(@database) or !@rules.isUseful(@table) or !@rules.isUseful(user) or !@rules.isUseful(poolSize)
            throw new exceptions.Fatal exceptions.INVALID_ARGUMENT, 'Missing one or more arguments'

        poolParams =
            host: host
            database: @database
            user: user
            password: password
            connectionLimit: poolSize
            acquireTimeout: timeout
            waitForConnections: 0

        @pool = @mysql.createPool poolParams

    readById: (id, callback) ->
        return callback 'Invalid id' if !@rules.isUseful(id) or @rules.isZero id
        @_execute "SELECT * FROM #{@table} WHERE id = ?", [id], (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback NOT_FOUND_ERROR

    read: (query, callback) ->
        @_execute query, null, (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback NOT_FOUND_ERROR

    readJoin: (id, params, callback) ->
        return callback 'Invalid id' if !@rules.isUseful(id) or @rules.isZero id

        joinTable = params?.table || null
        condition = params?.condition || null
        fields = params?.fields || null

        if !@rules.isUseful(joinTable) or !@rules.isUseful(condition) or !@rules.isUseful(fields)
            return callback 'Invalid join parameters'

        if params?.orderBy
            orderBy =  "ORDER BY #{params.orderBy}"
        if params?.limit
            limit = "LIMIT #{params.limit}"

        selectFields = ''

        for key in fields
            selectFields += "#{key},"

        selectFields = selectFields.substring(0, selectFields.length-1)

        query = "SELECT #{selectFields} FROM #{@table} JOIN #{joinTable} ON #{condition} WHERE #{@table}.id = ? #{orderBy} #{limit}"

        @_execute query, [id], (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback NOT_FOUND_ERROR

    _execute: (query, params, callback) ->
        @pool.getConnection (err, connection) =>
            return callback 'Error getConnection' if err?
            @_selectDatabase "#{@database}", connection, (err) ->
                if err?
                    connection.release()
                    return callback 'Error select database' if err?
                connection.query query, params, (err, row) ->
                    connection.release()
                    callback err, row

    _selectDatabase: (databaseName, connection, callback) ->
        connection.query "USE #{databaseName}", [], callback

    create: (data, callback) ->
        return callback 'Invalid data' if !@rules.isUseful(data)
        fields = ''
        values = []
        for key, value of data
            fields += "#{key}=?,"
            values.push value
        fields = fields.substr 0,fields.length-1

        @_execute "INSERT INTO #{@table} SET #{fields}", values, (err) ->
            return callback err if err?
            return callback()

    update:(id, data, callback) ->
        return callback 'Invalid id' if !@rules.isUseful(id) or @rules.isZero id
        return callback 'Invalid data' if !@rules.isUseful(data)

        fields = ''
        values = []

        for key, value of data
            fields += "#{key}=?,"
            values.push value

        fields = fields.substr 0,fields.length-1
        values.push id

        @_execute "UPDATE #{@table} SET #{fields} WHERE id=?", values, (err, row) ->
            return callback err if err?
            return callback null, row

    changeTable: (tableName) ->
        @table = tableName

    # createMany
    # readMany
    # update
    # updateMany
    # delete
    # deleteMany


module.exports = MySQLConnector