{EventEmitter}             = require 'events'
Q                          = require 'q'

amqpClient = nodeAmqp = undefined

describe 'QueueWrapper', ->

    beforeEach ->
        nodeAmqp = {}
        amqpClient = proxyquire '../src/amqp-client', 
            'node-amqp': nodeAmqp

    describe '.subscribe()', ->

        it 'should pass options to .subscribe() on to the wrapped queue', (done) ->
            conn = {}
            queue = { on: -> }
            amqpc = amqpClient { local: true }            
            queue.subscribe = stub().returns { addCallback: (fn) -> fn( { consumerTag: 'tag' }) }
            wrapper = new amqpc._QueueWrapper conn, queue
            wrapper.unsubscribe = stub().returns Q {}

            wrapper.subscribe({panda: true}, ->).then ->
                queue.subscribe.should.have.been.calledWith({panda: true}, match.func)
                done()
            .done()

    it 'should take its name from the underlying queue and update it when it changes', ->
            queue = new EventEmitter
            queue.name = 'panda'
            amqpc = amqpClient { local: true }            
            wrapper = new amqpc._QueueWrapper {}, queue
            wrapper.name.should.equal 'panda'
            queue.emit 'open', 'cub'
            wrapper.name.should.equal 'cub'
            
describe 'AmqpClient', ->

    beforeEach ->
        nodeAmqp = {}
        amqpClient = proxyquire '../src/amqp-client', 
            'amqp': nodeAmqp

    describe 'conn', ->

        it 'should invoke amqp.createConnection with the connection parameters', ->
            amqp = new EventEmitter
            amqp.exchange = (name, opts, cb) -> cb {}
            nodeAmqp.createConnection = stub().returns amqp
            amqpc = amqpClient { connection: url: 'url' }
            amqp.emit 'ready'
            amqpc.exchange('panda').then ->
                nodeAmqp.createConnection.should.have.been.calledWith { url: 'url' }
