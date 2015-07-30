'use strict'

path = require 'path'
uuid = require 'node-uuid'

class FsConnector

    constructor: (params, deps) ->
        @files = deps?.fs || require('waferpie-utils').Files
        @prefix = path.join params.domain, params.resource

    create: (data, callback) ->
        try
            @files.createDirIfNotExists params.domain
        try
            @files.createDirIfNotExists @prefix

        id = String(data.id) || "#{order}_#{uuid.v4().substr(-12)}"
        file = path.join @prefix, "#{id}.json"
        return callback 'File already exists.' if @files.isFile file
        try
            @files.createFileIfNotExists file, JSON.stringify(data)
            callback null, yes
        catch e
            callback e

    read: (basePath, id, callback) ->
        try
            fileContents = require path.join(basePath, @prefix, id)
            callback null, fileContents
        catch e
            callback e
        

module.exports = FsConnector