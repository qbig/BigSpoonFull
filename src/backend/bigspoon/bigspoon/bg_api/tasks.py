from __future__ import absolute_import

from celery import task
from utils import send_socketio_message, send_user_feedback, today_limit
from bg_order.models import Meal
from bg_inventory.models import User
import datetime
import requests
import json
import logging

# Get an instance of a logger
logger = logging.getLogger(__name__)


@task
def send_socketio_message_async(chan_list, message_data):
    send_socketio_message([int(i) for i in str(chan_list).split("||")], [str(s) for s in str(message_data).split("||")])


@task
def send_user_feedback_async(user, message_data):
    send_user_feedback(user, message_data)


@task.periodic_task(run_every=datetime.timedelta(seconds=60 * 15))
def remove_testing_meal():
    testers_emails = ['info@the loft.com.sg', 'ananias@theloft.com.sg', 'jay.tjk@gmail.com']
    testers = User.objects.filter(email__in=testers_emails)
    for meal in Meal.objects.filter(created__range=today_limit(), diner__in=testers):
        meal.delete()


@task(bind=True, max_retries=3)
def push_to_device(self, key, val, msg="New Message"):
    """
    eg. key = outlet_id, val = "1"
    eg. key = user_id, val = "123"
    """
    url = 'https://onesignal.com/api/v1/notifications'
    hdr = {
        'Content-Type': 'application/json',
        'Authorization': 'Basic YzQxMjM2ZDItZTcyNS0xMWU0LTk2ODYtYjMzZTkxY2MzYjYw'
    }
    load = {
        'isIos': False,
        'isAndroid': True,
        'app_id': 'c412366e-e725-11e4-9685-ef6b78def1f2',
        'contents': {'en': msg},
        'tags': [{'relation': '=', 'value': val, 'key': key}]
    }

    try:
        r = requests.post(url, headers=hdr, data=json.dumps(load))
        if r.status_code != 200:
            r.raise_for_status()
    except Exception as exc:
        if self.request.retries >= self.max_retries:
            logger.info("send notification failed, key={0}, val={1}".format(key, val))
        else:
            self.retry(exc=exc, countdown=min(2 ** self.request.retries, 60))
