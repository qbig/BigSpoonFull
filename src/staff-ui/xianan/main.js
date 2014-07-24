	
	$(document).ready(function(){
	
		var model = new Model();
		var view = new View();
		var controller = new Controller(model,view);
		/*
		 * when first open the page or refresh the page
		 * display all current unacknowledged cards
		 */
		controller.displayAll();
	});
	
	/*
	 *          Model
	 * Create a new Model instance
	 * @constructor
	 * when initialize, items is a array of two empty arrays
	 *  {meals:[],requests[]}
	 */
	function Model(){
		this._items = {"meals":[],"requests":[]};

	};

	/*
	 * Model.prototype consist all the functions that will modify the page storage/ model
	 */
	
	Model.prototype = {

		/*
		 * add a meal card to the model
		 */
		addMealCard : function(meal_id){
			var mySelf = this;
			$.ajax({
					//url is the backend position where can get all meals data
                    url: "meals.json",
                    dataType: "text",
                    //on success, filter the json to get specific data of the meal_id
                    success: function(data) {
                        var obj = JSON.parse(data);
	                    var length = obj.meals.length;
	                    for(var i = 0; i < length;i++){
		                   if(obj.meals[i].meal_id == meal_id){
			                   var obj2 = obj.meals[i];
		                   }
	                    }
	                    // add this meal data object to the model
						mySelf._items.meals.push(obj2);
					}
			});
			//console.log(this._items);
		},
		
		/*
		 * add a request card to the model
		 */
		addRequestCard : function(request_id){
			var mySelf = this;
			$.ajax({
                    url: "requests.json",
                    dataType: "text",
                    success: function(data) {
                    	var obj = JSON.parse(data);
                    	var length = obj.requests.length;
                    	for (var i = 0; i < length; i++){
	                    	if(obj.requests[i].request_id == request_id){
		                    	var obj2 = obj.requests[i];
	                    	}
                    	}		                        
						//add thsi request data object to the model						
						mySelf._items.requests.push(obj2);							
					}
			});
			//console.log(this._items);

		},
		
		/*
		 * check through the Model items,remove the specific meal item with given meal_id
		 * splice(m,n) function remove n items start from position m
		 * must make sure there are no items with the same id! Otherwise myItems.meals[i] will be undefined
		 */
		removeMealItem : function(id){
			var myItems = this._items;
			var length = myItems.meals.length;
			for (var i = 0; i < length; i++){
				if(myItems.meals[i].meal_id == id){
					myItems.meals.splice(i,1);
				}
			}
			//console.log(this._items);
		},
		
		/*
		 * check through the Model items request, remove the specific request item with given request_id
		 */
		removeRequestItem : function(id){
			var mySelf = this;
			var length = mySelf._items.requests.length;
			for (var j = 0; j < length; j++){
				if(mySelf._items.requests[j].request_id == id){
					mySelf._items.requests.splice(j,1);
				}
			}
			//console.log(this._items);
		},
		
		/*
		 * go to the backend to get the unacknowledged item data
		 * and add them to the model
		 */
		addAllCard : function(){
			var mySelf = this;
			$.ajax({
				//backend address where will return all unacknowledged meals and requests data
				url:"allData.json",
				dataType: "text",
				success: function(alldata){
					var dataObj = JSON.parse(alldata);
					var mealLength 		= dataObj.meals.length;
					var requestLength 	= dataObj.requests.length;
					for (var i = 0; i < mealLength;i++){
						var currentMeal = dataObj.meals[i];
						mySelf._items.meals.push(currentMeal);
					}

					for (var j = 0; j < requestLength;j++){
						var currentRequest = dataObj.requests[j];
						mySelf._items.requests.push(currentRequest);
					}
				}
			});
		}
	};
	
	/*
	 *                    View
	 * functions to render and display the card items
	 */
	function View(){
		/* two helper functions */
		
		/*
		 * masonry plugin to arrange the cards
		 */		
		$("#main .wrapper").masonry({
	        resizeable: true,
	        itemSelector: '.item',
	        columnWidth: 15,
	    });
		
		/*
		 * handlebar helper function for comparision
		 */
		Handlebars.registerHelper('ifCond', function (v1, operator, v2, options) {
		    switch (operator) {
		        case '==':
		            return (v1 == v2) ? options.fn(this) : options.inverse(this);
		        case '===':
		            return (v1 === v2) ? options.fn(this) : options.inverse(this);
		        case '!==':
		            return (v1 !== v2) ? options.fn(this) : options.inverse(this);
		        case '<':
		            return (v1 < v2) ? options.fn(this) : options.inverse(this);
		        case '<=':
		            return (v1 <= v2) ? options.fn(this) : options.inverse(this);
		        case '>':
		            return (v1 > v2) ? options.fn(this) : options.inverse(this);
		        case '>=':
		            return (v1 >= v2) ? options.fn(this) : options.inverse(this);
		        default:
		            return options.inverse(this);
		    }
		});
		
	}
	
	View.prototype = {
		
		/*
		 * display all current cards 
		 * called when the page is first opened or refreshed
		 * get from backend for all the meal and request data
		 * for each card call respective function to render and display in the Page
		 */
		displayAllCard : function(){
			var mySelf = this;
			$.ajax({
				url:"allData.json",
				dataType: "text",
				success: function(alldata){
					var dataObj = JSON.parse(alldata);
					var mealLength 		= dataObj.meals.length;
					var requestLength 	= dataObj.requests.length;
					//display all meal card sequentially
					for (var i = 0; i < mealLength;i++){
						var currentMeal = dataObj.meals[i];
						mySelf.handleMeals(currentMeal);
						mySelf.updateTime();
					}
					//display all request card
					for (var j = 0; j < requestLength;j++){
						var currentRequest = dataObj.requests[j];
						mySelf.handleRequest(currentRequest);
						mySelf.updateTime();
					}
				}
			});
		},		
	
		/*
		 * functions to get the meal data from backend and then render the data by filling the template
		 * eventually append the rendered meal card to the HTML page
		 * re-call the updateTime function to be able to update time for the new added card
		 */
		displayAddedMeal : function(id){
			var mySelf = this;
			$.ajax({
	                url: "meals.json",
	                dataType: "text",
	                success: function(data) {
	                    var obj = JSON.parse(data);
	                    var length = obj.meals.length;
	                    for(var i = 0; i < length;i++){
		                   if(obj.meals[i].meal_id == id){
			                   var obj2 = obj.meals[i];
		                   }
	                    }		                   
						mySelf.handleMeals(obj2);
						mySelf.updateTime();
					}
			});
		},
		
		handleMeals : function(resObj){
			var templateSource = $("#card-template-order").html();
			template = Handlebars.compile(templateSource);				
			cardBodyHTML = template(resObj);
			//create a new DOM element to put in the newly created card
			var elem = document.createElement('div');
			//add in the identifying attribute values of the div
			elem.className = 'item';
			elem.setAttribute("id", "card-"+resObj.meal_id);
			elem.innerHTML= cardBodyHTML;
			//call masonry plugin to append and format the cards
			$('#main .wrapper').append(elem).masonry('appended',elem);
		},
		
		/*
		 * functions to get the request data from backend and then render the data by filling the template
		 * append the rendered request card to the HTML page
		 */
		 
		displayAddedRequest : function(id){
			var mySelf = this;
			$.ajax({
                    url: "requests.json",
                    dataType: "text",
                    success: function(data) {
                    	var obj = JSON.parse(data);
                    	var length = obj.requests.length;
                    	for (var i = 0; i < length; i++){
	                    	if(obj.requests[i].request_id == id){
		                    	var obj2 = obj.requests[i];
	                    	}
                    	}	                        
						mySelf.handleRequest(obj2);
						mySelf.updateTime();							
					}
			});
		},
		
		handleRequest : function(resObj){
			var templateSource = $("#card-template-request").html(),
			template = Handlebars.compile(templateSource),
			cardBodyHTML = template(resObj);
			var elem = document.createElement('div');
			elem.className = 'item request';
			elem.setAttribute("id", "card-"+resObj.request_id);
			elem.innerHTML= cardBodyHTML;
			$('#main .wrapper').append(elem).masonry('appended',elem);
		},
		 
		/*
		 * by given the card element as parameter
		 * using masonry to remove the element and rearrange the cards for display 
		 */
		removeMeal : function(elem){
			$('#main .wrapper').masonry( 'remove', elem);
			//using masonry to re-layout the items in the container
			$('#main .wrapper').masonry();
		},
		 
		removeRequest : function(elem){
			$('#main .wrapper').masonry( 'remove', elem);
			//using masonry to re-layout the items in the container
			$('#main .wrapper').masonry();
		},
		
		/*
		 * function to update the waiting time
		 * there is no Event regarding change in one second
		 * in order to bind the update function to newly added card
		 * the function is recalled whenever a card is added into the page
		 */		
		 updateTime : function(){
			 $('.countdown').each(function() {
			        var card = $(this);
			        var start_time = card.attr("start");
			        setInterval(function () {			
			            var seconds_left = (new Date() - new Date(Number(start_time))) / 1000;
			            var minutes = parseInt(seconds_left / 60, 10);
			            var seconds = parseInt(seconds_left % 60, 10);
			            card.html('<i class="icon-time"></i> waited ' + minutes + " m, " + seconds + " s");			
			        }, 1000);
			    });
		 } 		 
		 
	};
	
	/*
	 *                     Controller
	 * Takes a model and view and acts as the controller between them
	 * @constructor
	 * @param {object} model The model instance
	 * @param {object} view The view instance
	 */
	 function Controller(model, view) {
		 var that = this;
		 this._model = model;
		 this._view = view;
		 
		 /*
		  * bind the DOM element with event and handlers
		  * now is insert a number and go to backend
		  * later will change to socket io and function will be called when new order is added
		  */
		 $('#button1').on('click',function(){
			var meal_id = parseInt(document.getElementById('meal_id').value);
			that.addMeal(meal_id);
		 });
		 
		 $('#button2').on('click',function(){
			var request_id = parseInt(document.getElementById('request_id').value);	
			that.addRequest(request_id);
		 });

		 	/*
			 * bind events with main wrapper's child elements
			 * the bind also works for dynamic added elements, no need re-bind
			 * after clicking the button, find the parent node of the button
			 * that is the element representing the card item
			 */
		 $('#main .wrapper').on('click',".item a.acknowledge.ack-button",function(){
			 var ackButton_Parent_Card = $( this ).parent();
			 that.ackMeal(ackButton_Parent_Card);
		 });
			
		 $('#main .wrapper').on('click',".item a.closebill.ack-button",function(){
		 	 var billButton_Parent_Card = $( this ).parent();
			 that.ackMeal(billButton_Parent_Card);
		 });
			
		 $('#main .wrapper').on('click',".item a.respond.ack-button",function(){
			 var respondButton_Parent_Card = $( this ).parent();
			 that.ackRequest(respondButton_Parent_Card);
		 });
		 
		 
		 /*
		  * bind event and function in the popup windows 
		  * to be added
		  
		  //dishIncreaseQuantiy click event
		  
		  //dishDecreaseQuantity click event
		  
		  //chooseCategoryButton click event
		  
		  //chooseDishButton click event
		  
		  //addNewDishButton click event
		  
		  //saveNoteButton click event
		  
		  //changeTableButton click event
		  
		  //targetTableSelected event

				  
		  */

	 }
	 
	 Controller.prototype = {
	 	/*
	 	 * when open the page or refresh, if there are unacknowledged meal/request card, display them first
	 	 * also add to the Model
	 	 */
		displayAll : function(){
			this._view.displayAllCard();
			this._model.addAllCard();
		},
		
		addMeal : function(id){
			this._model.addMealCard(id);
			this._view.displayAddedMeal(id);
		},
		
		addRequest : function(id){
			this._model.addRequestCard(id);
			this._view.displayAddedRequest(id);
		},
		
		/*
		 * remove the elem in the view
		 * get the id from elem's attribute
		 * remove the data in model by given id
		 */
		ackMeal : function(elem){
			this._view.removeMeal(elem);
			var mealIdAttr = elem.attr("id");
			var mealId = mealIdAttr.replace( /[^\d]/g, '' );
			this._model.removeMealItem(mealId);
			//in future add the card in the Table page
		},
		
		ackBill : function(elem){
			this._view.removeMeal(elem);
			var mealIdAttr = elem.attr("id");
			var mealId = mealIdAttr.replace( /[^\d]/g, '' );
			this._model.removeMealItem(mealId);
			//in future add the card in the Table page
		},
		
		ackRequest : function(elem){
			this._view.removeRequest(elem);
			var requestIdAttr = elem.attr("id");
			var requestId = requestIdAttr.replace( /[^\d]/g, '' );
			this._model.removeRequestItem(requestId);
			//in future add the card in the Table page
		}
		
		/*
		 * functions serve the popup windows
		 
		 increaseDishQuantity : function(){
		 	get the dish element
		 	view display new quantity
		 	model update new quantity + if need to update in backend
		 },	
		 
		 decreaseDishQuantity : function() {
		 	
		 },
		 
		 chooseCategory : function(){},
		 
		 chooseDish : function(){},
		 
		 addNewDish : function(){},
		 
		 saveNote : function(){
		 	
		 },
		 
		 <below two function can convert to one function only to prevent use of global variable>
		 changeTable : function(){
		 	view.displayTableDropdown();
		 }		 
		 selectTargetTable : function(){
		 	view display new table id/name
		 	model update table information
		 }
		 
		 
		 */
		
		
		
	};
