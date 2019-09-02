const amqp = require('amqplib/callback_api');
const opt = { credentials: require('amqplib').credentials.plain('guest', 'guest') };
const queue = "test.queue";

amqp.connect('amqp://rabbit2', opt, function (error0, connection) {
  if (error0) {
    throw error0;
  }
  connection.createChannel(function (error1, channel) {
    channel.consume(queue, function (msg) {
      console.log("%s Recieved: %s", new Date().toISOString(), msg.content.toString());
      channel.nack(msg, false, false);
    })
  });
});
