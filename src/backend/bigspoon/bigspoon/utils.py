from django.conf import settings
from datetime import datetime, timedelta, time

import redis

REDIS_HOST = getattr(settings, 'REDIS_HOST', '127.0.0.1')


def send_socketio_message(chan_list, message_data):
    red = redis.StrictRedis(REDIS_HOST)
    for c_id in chan_list:
        red.publish('%d' % c_id, message_data)


def today_limit():
    today = datetime.now.date()
    tomorrow = today + timedelta(1)
    today_start = datetime.combine(today, time())
    today_end = datetime.combine(tomorrow, time())
    return (today_start, today_end)


def one_hour_ago():
    return datetime.datetime.now() - datetime.timedelta(hours=1)
