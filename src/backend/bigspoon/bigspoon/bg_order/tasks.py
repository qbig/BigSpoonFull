from __future__ import absolute_import

from celery import shared_task, task
import requests
from bg_inventory.models import Table
from bg_order.models import Order, Meal
from utils import send_socketio_message

@shared_task
def add(x, y):
    return x + y

"""
TODO:
API
1. print_amax_normal
-- same as the 'old' print_amax, just change the "'ToBePrintedInKitchen': 'true' ," -- > 'false'
2. for TAKEAWAY
-- send them to dashboard (no printing etc)
-- call 'print_amax_normal' after ACK, that's it. no additional API required.
"""

@task(bind=True, max_retries=3)
def print_amax(self, table_id, new_order_id):
	table = Table.objects.get(id=table_id)
	new_order = Order.objects.get(id=new_order_id)
	url = 'http://greendotpls.serveftp.com:8811/ppc/ordering.asmx/AddiPadOrderNew'
	tableName = table.name
	pos_id = str(new_order.dish.pos) # !!! must match '10101'
	item_name = new_order.dish.name
	item_price = str(new_order.dish.price)
	quantity = str(new_order.quantity)
	item_note = new_order.note
	item_sale_str = "||".join([pos_id, item_name, item_name + "*" + item_note, item_price, quantity]) + "|"
	payload = {
		'SalesItems': item_sale_str,
		'TableName': tableName ,
		'CounterCode': 'WEB' ,
		'EmployeeCode': 'Web' ,
		'CreateNewTransactionForEachOrder': 'false' ,
		'ToBePrintedInKitchen': 'true' ,
		'ToPrintOrderList': 'false' ,
		'ToPrintKitchenOrderList': 'false' ,
		'ToPrintBarOrderList': 'false' ,
		'PrintBillAfterKitchenOrder': 'false' ,
		'PrintReceiptAfterKitchenOrder': 'false' ,
		'PrintBriefReceiptAfterKitchenOrder': 'false' ,
		'sGUID': '' ,
		'iSalesPax': '1' ,
	}
	try:
		r = requests.post(url, data=payload)
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
	1 : print_amax,
	14: print_amax
}
############################

#get_printing_task(table.outlet.id).delay(table.outlet, table, new_order)
def get_printing_task(outlet_id):
	return task_config.get(outlet_id)