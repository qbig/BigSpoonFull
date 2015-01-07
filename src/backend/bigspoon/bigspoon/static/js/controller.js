// (function (window) {

	function Controller(model, view) {
		var that = this;
		this.model = model;
		this.view = view;
       
        // ================== TEST ==================

		$('#button1').on('click',function(){
			var meal_id = parseInt(document.getElementById('meal_id').value);
			if(meal_id) {
				//that.model.addMealCard(meal_id);
				this.handlePrompt(['refresh', 'meal', 'closebill', meal_id]);
			}
		});
		 
		$('#button2').on('click',function(){
			var request_id = parseInt(document.getElementById('request_id').value);
			if(request_id)	{
				//that.addRequest(request_id);
				this.handlePrompt(['refresh', 'request', 'new', request_id]);
			}
		});

		// ================== TEST END ==================
	 	
		this.view.$mainWrapper.on('click',".item a.acknowledge.ack-button",this.view.handleClick);
		this.view.$mainWrapper.on('click',".item a.closebill.ack-button",this.view.handleClick);
		this.view.$mainWrapper.on('click',".item a.respond.ack-button",this.view.handleClick);
		
		//In progress
		this.view.$mainWrapper.on('click',".view-profile",function(){
			 alert('display profile pop up');

		});
		
		function bind_popup(){
		        // for User profile pop up
		        $(".user-profile-link").magnificPopup({
		            type: 'ajax',
		            settings: {cache:false},
		            alignTop: true,
		            cache: false,
		            closeBtnInside: true,
		            overflowY: 'scroll',
		            callbacks: {
		                open: function() {
		                    is_in_popup = true;
		                    console.log(is_in_popup);
		                }
		            },
		        });

		        $(".view-profile").magnificPopup({
		            type: 'ajax',
		            settings: {cache:false},
		            alignTop: true,
		            cache: false,
		            closeBtnInside: true,
		            overflowY: 'scroll',
		            callbacks: {
		                open: function() {
		                    is_in_popup = true;
		                    console.log(is_in_popup);
		                }
		            },
		        });

		        $('.popup-modal').magnificPopup({
		            type: 'inline',
		            preloader: false,
		            focus: '#username',
		            modal: true
		        });

		        $('.cancel_order_icon_btn').click(function(){
		            var icon_clicked = $(this);
		            order_to_modify = icon_clicked.attr('data-orderId');
		        });
		    }
		    bind_popup();

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

	 };
	 
	 Controller.prototype = {

	 	// when open the page or refresh, if there are unacknowledged meal/request card, display them first
	 	// also add to the Model
		initialise : function(outlet_id) {
			document.addEventListener("allItemsAdded", this.updateView.bind(this));
	   		document.addEventListener("mealAdded", this.addMeal.bind(this));
	   		document.addEventListener("requestAdded", this.addRequest.bind(this));
	   		document.addEventListener('cardClicked', this.removeCard.bind(this));
	   		document.addEventListener('alarm', this.playAlarm.bind(this));
	   		this.model.addAllCard(outlet_id);
	   		this.initSocketIO();
	   		this.sound = new Howl ({
			    url: [media_url + 'sounds/notification.mp3']
			});
		},

		playAlarm : function() {
			this.sound.play();
		},

		removeCard : function(e) {
			var that = this
			//ajax post to backend with card_id with a callback to remove card and data
			that.model.postRemoveData(e.detail, function() {
				that.model.removeData(e.detail);
				that.view.removeCard(e.detail.parent_card);
			});
		},

		initSocketIO : function() {

		    // handle Socketio message, data may be in any of the following formats:
		    // ['refresh', 'meal', 'new', 'meal_id']
		    // ['refresh', 'meal', 'askbill', 'meal_id']
		    // ['refresh', 'meal', 'closebill', 'meal_id']
		    // ['refresh', 'request', 'new', 'request_id']
		    // ['refresh', 'meal', 'ack']		(ignore for now)
		    // ['refresh', 'request', 'ack'] 	(ignore for now)
		    // ['refresh', 'menu', 'add']		(ignore for now)
			var that = this;
			var details = {
		    	'reconnect': true,
		    	'reconnection delay': 500,
		    	'max reconnection attempts': 10
		    };
		    //host is a global variable. host = "http://"+location.host
		    if (host.indexOf("8000") !== -1) {
		    	socket = io.connect(host, details);
		    } else {
		    	socket = io.connect(host+":8000", details);
		    }

		    socket.on("message", function(obj){
		    	if (obj.message.type == "message") {
		    		var data = eval(obj.message.data);
		    		var path = location.pathname;
		    		if (data[0] == "refresh") {
		    			var seconds_since_page_load = new Date().getTime()/1000 - page_start_time_in_seconds;
		    			if (seconds_since_page_load  < REFRESH_INTEVAL_CAP) {
		    				timeout_obj = setTimeout(function(){
		    					that.handlePrompt(data, path);
		    				}, (REFRESH_INTEVAL_CAP - seconds_since_page_load) * 1000);
		    			} else {
		    				that.handlePrompt(data, path);
		    			}
		    		}
		    	}
		    });

		    // subsribe to socketIO channels
		    if (outlet_ids !== null) {
		    	for (var i = 0, len = outlet_ids.length; i < len; i++) {
		    		socket.send("subscribe:" + outlet_ids[i]);
		    	}
		    }
		},

		handlePrompt : function(data, path){        
			if (data[1] === 'request') {
				if ($.inArray(path, STAFF_MEAL_PAGES[data[2]]) != -1) {
					if (data[2] == 'new') {
						document.dispatchEvent(new Event("requestAdded"), { 'detail': data[3] });
					}
				}
			} else if (data[1] === 'meal') {
				if ($.inArray(path, STAFF_MENU_PAGES[2]) != -1) {
					if (data[2] === 'new' || data[2] === 'askbill' || data[2] === 'closebill') {
						document.dispatchEvent(new Event("mealAdded"), { 'detail': data[3] });
					}
				}
			}
		},

		updateView: function() {
	   		this.view.displayAllCard(this.model.items);
		},

		addMeal : function(e) {
			var that = this;
			that.model.addMealCard(e.detail, function(mealObj) {
				that.view.displayAddedMealCard(mealObj);
			});
		},
		
		addRequest : function(id) {
			var that = this;
			that.model.addRequestCard(e.detail, function(requestObj) {
				that.view.displayAddedRequestCard(requestObj);
			});
		},
		
		/*
		 * remove the elem in the view
		 * get the id from elem's attribute
		 * remove the data in model by given id
		 */
		ackMeal : function(elem) {
			var mealIdAttr = elem.attr("id");
			var mealId = mealIdAttr.replace( /[^\d]/g, '' );
			var that = this;
			this.model.removeMealItem(mealId,function() {
				that.view.removeMeal(elem);
			});
			//in future add the card in the Table page
		},
		
		ackBill : function(elem) {
			var mealIdAttr = elem.attr("id");
			var mealId = mealIdAttr.replace( /[^\d]/g, '' );
			var that = this;
			this.model.removeMealItem(mealId, function() {
				that.view.removeMeal(elem);
			});
			//in future add the card in the Table page
		},
		
		ackRequest : function(elem) {
			console.log('not suppose to be here')
			var requestIdAttr = elem.attr("id");
			var requestId = requestIdAttr.replace( /[^\d]/g, '' );
			var that = this;
			this.model.removeRequestItem(requestId, function() {
				that.view.removeRequest(elem);
			});
			//in future add the card in the Table page
		},

		
		
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

	//Export to window
	window.app = window.app || {};
	window.app.Controller = Controller;
// })(window);