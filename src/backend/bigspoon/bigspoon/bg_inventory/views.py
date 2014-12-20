import redis
from django.http import HttpResponse
from django.conf import settings
from gevent.greenlet import Greenlet

from socketio.namespace import BaseNamespace
from socketio import socketio_manage
import logging

REDIS_HOST = getattr(settings, 'REDIS_HOST', '127.0.0.1')

logger = logging.getLogger('')


class BigSpoonNamespace(BaseNamespace):
    def initialize(self):
        self.redis_pubsub = redis.StrictRedis(REDIS_HOST).pubsub()
        self.greenlets = []

    def _listen(self, chan):
        self.redis_pubsub.subscribe(chan)
        while True:
            for i in self.pubsub.listen():
                self.send({'message': i}, json=True)

    def recv_message(self, message):
        action, pk = message.split(':')
        logger.info("connected - action %s pk %s" % (action, pk))

        if action == 'subscribe':
            self.greenlets.append(self.spawn(self._listen, pk))

    def recv_disconnect(self):
        logger.info("disconnect!")
        if self.redis_pubsub:    
            logger.info("pubsub closed!")
            self.redis_pubsub.close()
        for gls in self.greenlets:
            gls.kill()
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
