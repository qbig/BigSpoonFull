from django.conf import settings
from django.utils import timezone
from datetime import datetime, timedelta, time
from celery import shared_task, task
import gevent
import redis

REDIS_HOST = getattr(settings, 'REDIS_HOST', '127.0.0.1')


@task
def send_socketio_message(chan_list, message_data):
    red = redis.StrictRedis(REDIS_HOST)
    for c_id in chan_list:
        red.publish('%d' % c_id, message_data)
@task
def send_user_feedback(user, message_data):
    red = redis.StrictRedis(REDIS_HOST)
    red.publish(user, message_data)


def today_limit():
    today = timezone.now().date()
    tomorrow = today + timedelta(1)
    today_start = make_time_zone_aware(datetime.combine(today, time()))
    today_end = make_time_zone_aware(datetime.combine(tomorrow, time()))
    return (today_start, today_end)

def make_time_zone_aware(to_update):
    return timezone.make_aware(to_update, timezone.get_current_timezone())

def one_hour_ago():
    return timezone.now() - timedelta(hours=1)
