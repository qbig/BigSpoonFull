//(function (window) {

	function Model() {
		this.items = {
			"meals":[],
			"requests":[]
		};
	};

	Model.prototype = {

		addMealCard: function(meal_id, callback){
			var that = this;
			$.ajax({
				//where data of all "meals" can be found
				url: "http://127.0.0.1:8000/api/v1/outlet-items/meals/"+meal_id,
				dataType: "text",
				//data: "meal_id",
				//when request is successful, backend responds with meal object that corresponds to meal_id
				//object will be in the form of "data" and be pushed into items array in model
				success: function(mealData) {
					var mealCardData = JSON.parse(mealData);
					that.items.meals.push(mealCardData);
					that.checkNumCards();
					callback(mealCardData);
					//document.dispatchEvent(new CustomEvent("cardAdded", {'detail': temp}));

				}
			});
		},

		//add a request card to the model
		addRequestCard: function(request_id, callback){
			var that = this;
			$.ajax({
				//where data of all "requests" can be found
				url: "http://127.0.0.1:8000/api/v1/outlet-items/requests/"+request_id,
				dataType: "text",
				//data: "request_id",
				//when request is successful, backend responds with request object that corresponds to request_id
				//object will be in the form of "data" and be pushed into items array in model
				/*example:
				{
				   "request_id":23,
				   "request_start_time":"1.404269983e+12",
				   "request_table_name":"A1",
				   "request_type":0,
				   "request_wait_time":{
				      "min":1,
				      "second":20
				   },
				   "request_note":"hot",
				   "dinerInfo":{
				      "diner_id":1,
				      "diner_name":"amy",
				      "diner_visits":2,
				      "diner_total_spend":60,
				      "diner_average_spend":30,
				      "diner_profile":{
				         "is_vegetarian":"Y",
				         "is_muslim":"F",
				         "allergies":""
				      }
				   }
				},*/
				success: function(requestData) {
					var requestCardData = JSON.parse(requestData);
					that.items.requests.push(requestCardData);
					that.checkNumCards();
					callback(requestCardData);
					// document.dispatchEvent(new Event("requestAdded"));
				}
			});
		},

		//check through the model items and remove (using splice())the meal item corresponding to id
		//ensure no multiple items with same id
		removeMeal: function(id,callback){
			var len = this.items.meals.length;
			for(var i = 0; i < len; i++) {
				if(this.items.meals[i].id === parseInt(id)) {
					this.items.meals.splice(i,1);
					this.checkNumCards();
					callback();
					break;
				}
			}

		},

		//check through the model items and remove (using splice())the request item corresponding to id
		//ensure no multiple items with same id
		removeRequest: function(id,callback){
			var len = this.items.requests.length;
			for (var i = 0; i < len; i++) {
				if(this.items.requests[i].id === parseInt(id)) {
					this.items.requests.splice(i,1);
					this.checkNumCards();
					callback();
					break;
				}
			}
		},


		//acquire all unacnowledged cards from the backend, and add to the model
		addAllCard: function(outlet_id){
			var that = this;
			$.ajax({
				url: "http://127.0.0.1:8000/api/v1/outlet-items/"+outlet_id,
				dataType: "text",
				//upon successful request, backend response (alldata) will be passed to function
				success: function(alldata) {
					var allDataParsed = JSON.parse(alldata);
					
					allDataParsed.meals.forEach( function (meal) {
						that.items.meals.push(meal);
					});
					
					allDataParsed.requests.forEach( function (request) {
						that.items.requests.push(request);
						console.log(request)
					});
					document.dispatchEvent(new Event("allItemsAdded"));
					that.checkNumCards();
				}
			});
		},

		//ajax post to backend when acknowledge/closebill button is clicked 
		postRemoveData: function(e, callback) {
			var req_data = {
				"csrfmiddlewaretoken":csrftoken
			};
			req_data[e.model] = e.card_id;
			$.post(
				STAFF_API_URLS[e.button_type],
				req_data
				).done(function(data) {
					//callback to remove view card and model data when succeed 
					callback();
				}).fail(function(data) {
					//does not callback when failed
					console.log("POST failed");
					console.log(data);
				});
		},

		//check card type and remove accordingly
		removeData: function(event,callback) {
			if(event.model === 'request') {
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
			var numCards = this.items.meals.length+this.items.requests.length
			document.dispatchEvent(new CustomEvent("checkNumCards",  { 'detail': numCards }));
		}
	};

	//Export to window
	window.app = window.app || {};
	window.app.Model = Model;
//})(window);