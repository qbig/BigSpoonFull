//global page

$(document).ready(function() {
	window.csrftoken = $.cookie('csrftoken');
	window.page_start_time_in_seconds = new Date().getTime()/1000;
	window.host = "http://"+location.host;
	window.STAFF_API_URLS = {
		"req": host+"/api/v1/ackreq",
		"bill": host+"/api/v1/closebill",
		"order": host+"/api/v1/ackorder",
		"note": host+"/api/v1/note",
		"dish": host+"/api/v1/dish",
		"spending": host+"/api/v1/spending",
		"newOrder": host+"/api/v1/meal-update",
		"table" : host+"/api/v1/table",
		"table-single" : host+"/api/v1/table-single-diner",
		"order_update" : host+"/api/v1/order",
	};
	window.STAFF_MEAL_PAGES = {
		"new": ['/staff/main/'],
		"ack": ['/staff/main/', '/staff/history/', '/staff/tables/'],
		"askbill": ['/staff/main/', '/staff/history/', '/staff/tables/'],
		"closebill": ['/staff/main/', '/staff/report/', '/staff/tables/', '/staff/history/'],
	};

	window.STAFF_MENU_PAGES = ['/staff/menu/'];
	
	function Page() {
		this.model = new app.Model();
		this.view = new app.View();
		this.controller = new app.Controller(this.model, this.view);
		//dummy outlet_id
		window.outlet_ids = [0,1];
		this.controller.initialise(outlet_ids[0]);
	}

	var page = new Page();

});

