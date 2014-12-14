from __future__ import absolute_import

from celery import shared_task, task
import requests
from bg_inventory.models import Outlet, Table
from bg_order.models import Order


@shared_task
def add(x, y):
    return x + y

@task(bind=True, max_retries=10)
def print_amax(self, outlet_id, table_id, new_order_id):
	outlet = Outlet.objects.get(id=outlet_id)
	table = Table.objects.get(id=table_id)
	new_order = Order.objects.get(id=new_order_id)
	url = 'http://greendotpls.serveftp.com:8811/ppc/ordering.asmx/AddiPadOrderNew'
	TableName = table.name
	pos_id = '10101'#str(new_order.dish.pos) !!! must match
	item_name = new_order.dish.name
	item_price = str(new_order.dish.price)
	quantity = str(new_order.quantity)
	item_note = new_order.note
	item_sale_str = "||".join([pos_id, item_name, item_name + "*" + item_note, item_price, quantity]) + "|"
	payload = {
		'SalesItems': item_sale_str, 
		'TableName': TableName ,
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
		r.raise_for_status()
	except Exception as exc:
		self.retry(exc=exc, countdown=min(2 ** self.request.retries, 60))


############################
task_config = {
	1 : print_amax
}
############################

#get_printing_task(table.outlet.id).delay(table.outlet, table, new_order)
def get_printing_task(outlet_id):
	return task_config.get(outlet_id)