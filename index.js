const amqp = require('amqplib/callback_api');
const opt = { credentials: require('amqplib').credentials.plain('guest', 'guest') };

const exchange = "test.exchange";
const queue = "test.queue";
const queue_dlq = "test.queue.dlq";
const routing_key = "test.queue.event"
const exchange_dlx = "test.exchange.dlx";
const exchange_dlx_retry = "test.exchange.dlx.retry";

['amqp://rabbit2', 'amqp://rabbit4'].forEach(function (host) {
  amqp.connect(host, opt, function (error0, connection) {
    if (error0) {
      throw error0;
    }
    connection.createChannel(function (error1, channel) {

      // declare dlq exchanges

      channel.assertExchange(exchange, 'topic', {
        durable: true,
      });

      channel.assertExchange(exchange_dlx, 'topic', {
        durable: true
      })

      channel.assertExchange(exchange_dlx_retry, 'topic', {
        durable: true
      })

      channel.assertQueue(queue, {
        deadLetterExchange: exchange_dlx
      });

      channel.assertQueue(queue_dlq, {
        messageTtl: 10000,
        deadLetterExchange: exchange_dlx_retry
      });

      channel.bindQueue(queue_dlq, exchange_dlx, '#');
      channel.bindQueue(queue, exchange_dlx_retry, routing_key);
      channel.bindQueue(queue, exchange, routing_key);

      const msg = 'Hello World from ' + host;

      // wait 2s (can be done using callbacks)
      setTimeout(function () {
        channel.publish(exchange, routing_key, Buffer.from(msg));
        console.log("%s Sent %s", new Date().toISOString(), msg);
      }, 2000);

    });

  });
})

