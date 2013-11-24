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

    def listener(self, chan):
            red = redis.StrictRedis(REDIS_HOST)
            red = red.pubsub()
            red.subscribe(chan)
            while True:
                for i in red.listen():
                    self.send({'message': i}, json=True)

    def recv_message(self, message):
        action, pk = message.split(':')
        logger.info("connected - action %s pk %s" % (action, pk))

        if action == 'subscribe':
            Greenlet.spawn(self.listener, pk)


def socketio(request):
    socketio_manage(
        request.environ,
        {'': BigSpoonNamespace, },
        request=request
    )
    return HttpResponse()
