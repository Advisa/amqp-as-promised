Q = require 'q'

module.exports = class ExchangeWrapper

    constructor: (@exchange) ->
        @name = @exchange.name

    publish: (routingKey, message, options) ->
        def = Q.defer()
        @exchange.publish routingKey, message, options, (err) ->
            if err
                def.reject err
            else
                def.resolve()
        def.promise
        
    
