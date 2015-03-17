function Model() {
    this.items = {
        "meals": [],
        "requests": []
    };
    this.csrftoken = $.cookie('csrftoken');
    var host = "http://"+location.host;
	this.STAFF_API_URLS = {
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
		"outlet": host+"/api/v1/outlet-items/",
		"meal": host+"/api/v1/meal-details/",
		"request": host+"/api/v1/request/",

	};
	this.STAFF_MEAL_PAGES = {
		"new": ['/staff/main/'],
		"ack": ['/staff/main/', '/staff/history/', '/staff/tables/'],
		"askbill": ['/staff/main/', '/staff/history/', '/staff/tables/'],
		"closebill": ['/staff/main/', '/staff/report/', '/staff/tables/', '/staff/history/'],
	};

	this.STAFF_MENU_PAGES = ['/staff/menu/'];
}

Model.prototype = {
    addMealCard: function(meal_id, callback) {
    	console.log("addMealCard:meal_id:"+ meal_id);
        var that = this;
        var duplicateData = false;
        $.ajax({
            url: this.STAFF_API_URLS["meal"] + meal_id,
            cache: false,
            dataType: "text",
            success: function(mealData) {
                var mealCardData = JSON.parse(mealData);
                //check to see if there is already another meal object with the same id
                if (mealCardData.status !== 1) {
                    for (var i = 0, len = that.items.meals.length; i < len; i++) {
                        if (that.items.meals[i].id === parseInt(meal_id, 10)) {
                            duplicateData = true;
                            that.items.meals.splice(i, 1);
                            break;
                        }
                    }
                    that.mealDishDupCollapse(mealCardData);
                    that.items.meals.push(mealCardData);
                    that.checkNumCards();
                    callback(mealCardData, duplicateData);
                }
            }
        });
    },

    mealDishDupCollapse: function (mealObj){
        for (var len = mealObj.orders.length, i = len - 1; i > 0; i--){
            for (var j = i - 1; j > 0; j--){
                if (mealObj.orders[i].dish === mealObj.orders[j].dish &&
                 mealObj.orders[i].note === mealObj.orders[j].note) {
                    mealObj.orders[j].quantity++;
                    mealObj.orders.splice(i, 1);
                    break;
                }
            }
        }
    },
    //add a request card to the model
    addRequestCard: function(request_id, callback) {
        var that = this;
        $.ajax({
            url: this.STAFF_API_URLS["request"] + request_id,
            cache: false,
            dataType: "text",
            success: function(requestData) {
                var requestCardData = JSON.parse(requestData);
                that.items.requests.push(requestCardData);
                that.checkNumCards();
                callback(requestCardData);
            }
        });
    },
    //check through the model items and remove (using splice())the meal item corresponding to id
    //ensure no multiple items with same id
    removeMeal: function(id, callback) {
        var len = this.items.meals.length;
        for (var i = 0; i < len; i++) {
            if (this.items.meals[i].id === parseInt(id, 10)) {
                this.items.meals.splice(i, 1);
                this.checkNumCards();
                callback();
                break;
            }
        }
    },
    //check through the model items and remove (using splice())the request item corresponding to id
    //ensure no multiple items with same id
    removeRequest: function(id, callback) {
        var len = this.items.requests.length;
        for (var i = 0; i < len; i++) {
            if (this.items.requests[i].id === parseInt(id)) {
                this.items.requests.splice(i, 1);
                this.checkNumCards();
                callback();
                break;
            }
        }
    },
    //acquire all unacnowledged cards from the backend, and add to the model
    addAllCard: function(outlet_id) {
        var that = this;
        $.ajax({
            url: this.STAFF_API_URLS["outlet"] + outlet_id,
            cache: false,
            dataType: "text",
            //upon successful request, backend response (alldata) will be passed to function
            success: function(alldata) {
                var allDataParsed = JSON.parse(alldata);
                allDataParsed.meals.forEach(function(meal) {
                    that.mealDishDupCollapse(meal);
                    that.items.meals.push(meal);
                });
                allDataParsed.requests.forEach(function(request) {
                    that.items.requests.push(request);
                });
                document.dispatchEvent(new CustomEvent("allItemsAdded"));
                that.checkNumCards();
            }
        });
    },
    //ajax post to backend when acknowledge/closebill button is clicked
    postRemoveData: function(e, callback) {
        var req_data = {
            "csrfmiddlewaretoken": this.csrftoken
        };
        req_data[e.model] = e.card_id;
        $.post(this.STAFF_API_URLS[e.button_type], req_data).done(function(data) {
            //callback to remove view card and model data when succeed
            callback();
        }).fail(function(data) {
            //does not callback when failed
            console.log("POST failed");
            console.log(data);
        });
    },
    //check card type and remove accordingly
    removeData: function(event, callback) {
        if (event.model === 'request') {
            this.removeRequest(event.card_id, function() {
                callback();
            });
        } else if (event.model === 'meal') {
            this.removeMeal(event.card_id, function() {
                callback();
            });
        }
    },
    checkNumCards: function() {
        var numCards = this.items.meals.length + this.items.requests.length;
        document.dispatchEvent(new CustomEvent("checkNumCards", {
            'detail': numCards
        }));
    }
};

window.app = window.app || {};
window.app.Model = Model;