import redis
from django.http import HttpResponse
from django.conf import settings

from socketio.namespace import BaseNamespace
from socketio import socketio_manage
import logging

REDIS_HOST = getattr(settings, 'REDIS_HOST', '127.0.0.1')
logger = logging.getLogger('')


class BigSpoonNamespace(BaseNamespace):

    def __init__(self, *args, **kargs):
        super(BigSpoonNamespace, self).__init__(*args, **kargs)
        self.pubsub = redis.StrictRedis(REDIS_HOST).pubsub()

    def listener(self, chan):
        self.pubsub.subscribe(chan)
        while True:
            for i in self.pubsub.listen():
                self.send({'message': i}, json=True)

    def recv_message(self, message):
        action, pk = message.split(':')
        logger.info("connected - action %s pk %s" % (action, pk))

        if action == 'subscribe':
            self.spawn(self.listener, pk)

    def recv_disconnect(self):
        logger.info("disconnect!")
        if self.pubsub:
            logger.info("pubsub closed!")
            self.pubsub.close()
        self.disconnect(silent=True)
        super(BigSpoonNamespace, self).recv_disconnect()


def socketio(request):
    logger.info("Connecting start")
    socketio_manage(
        request.environ,
        {'': BigSpoonNamespace, },
        request=request
    )
    logger.info("Connecting finish")
    return HttpResponse()
