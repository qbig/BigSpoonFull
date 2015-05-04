from __future__ import absolute_import

from celery import task
from utils import send_socketio_message, send_user_feedback, today_limit
from bg_order.models import Meal, Order, Meal
from bg_inventory.models import User, Table
import datetime
import requests
import json
import logging
from requests.auth import HTTPBasicAuth

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


"""
TODO:
API
1. print_amax_normal (DONE)
-- same as the 'old' print_amax, just change the "'ToBePrintedInKitchen': 'true' ," -- > 'false'
2. for TAKEAWAY
-- send them to dashboard (no printing etc)
-- call 'print_amax_normal' after ACK, that's it. no additional API required.
Change:
url = 'http://greendot02-151617.ddns.net:53698/ppc'
r = requests.get(url, auth=HTTPBasicAuth('Administrator', 'Greendot@111'))
"""


@task(bind=True, max_retries=3)
def send_to_amax_no_print(self, table_id, new_order_id, print_bool=False):
    table = Table.objects.get(id=table_id)
    new_order = Order.objects.get(id=new_order_id)
    url = 'http://greendot02-151617.ddns.net:53698/ppc/ordering.asmx/AddiPadOrderNew'
    basic_auth = HTTPBasicAuth('Administrator', 'Greendot@111')
    tableName = table.name
    should_print = 'true' if print_bool else 'false'
    pos_id = str(new_order.dish.pos)  # !!! must match '10101'
    item_name = new_order.dish.name
    item_price = str(new_order.get_order_spending())
    quantity = str(new_order.quantity)
    item_note = new_order.note
    item_sale_str = "||".join([pos_id, item_name, item_name + "*\n" + item_note, item_price, quantity]) + "|"
    payload = {
        'SalesItems': item_sale_str,
        'TableName': tableName,
        'CounterCode': 'WEB',
        'EmployeeCode': 'Web',
        'CreateNewTransactionForEachOrder': 'false',
        'ToBePrintedInKitchen': 'true',
        'ToPrintOrderList': 'false',
        'ToPrintKitchenOrderList': 'false',
        'ToPrintBarOrderList': 'false',
        'PrintBillAfterKitchenOrder': 'false',
        'PrintReceiptAfterKitchenOrder': 'false',
        'PrintBriefReceiptAfterKitchenOrder': 'false',
        'sGUID': '',
        'iSalesPax': '1',
    }
    try:
        r = requests.post(url, data=payload, auth=basic_auth)
        if r.status_code == 200:
            new_order.has_been_sent_to_POS = True
            new_order.save()
        r.raise_for_status()
    except Exception as exc:
        if self.request.retries >= self.max_retries:
            new_order.is_finished = False
            new_order.meal.status = Meal.ACTIVE
            new_order.meal.note = "Undelivered(network unstable), pls add to POS manually. " + new_order.meal.note
            new_order.meal.save()
            new_order.save()
            send_socketio_message(
                [table.outlet.id],
                ['refresh', 'meal', 'new', new_order.meal.id]
            )
        else:
            self.retry(exc=exc, countdown=min(2 ** self.request.retries, 60))


############################
task_config = {
    1: send_to_amax_no_print,
    14: send_to_amax_no_print
}
############################


#get_printing_task(table.outlet.id).delay(table.outlet, table, new_order)
def get_printing_task(outlet_id):
    return task_config.get(outlet_id)
