Transaction = require '../../app/Entities/Transaction'
expect = require 'expect.js'

describe 'The Transaction entity', ->

    instance = null

    it 'should throw an error if instantiated with wrong params', ->
        instance = new Transaction
        instance._isValid = () ->
            false
        fn = () ->
            new instance
        expect(fn).to.throwError()

    describe '', ->