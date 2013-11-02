from django.conf import settings
import redis

REDIS_HOST = getattr(settings, 'REDIS_HOST', '127.0.0.1')


def send_socketio_message(chan_list, message_data):
    red = redis.StrictRedis(REDIS_HOST)
    for c_id in chan_list:
        red.publish('%d' % c_id, message_data)
