// (function (window) {

	//Use masonry plugin to arrange cards based on size of brower and number of cards
	function View() {
		this.$mainWrapper = $('#main .wrapper');
		this.$mainWrapper.masonry({
			resizeable: true,
			itemSelector: '.item',
			columWidth: 15,
			gutter: 10
		});
	}

	//Use handlebar for templating
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

	View.prototype = {

		//Display all current unacknowledged cards
		//Called when page is first opened or refreshed
		displayAllCard : function(allCards) {
			var that = this;
			var mealLength 		= allCards.meals.length;
			var requestLength 	= allCards.requests.length;
			//display all meal card sequentially
			for (var i = 0; i < mealLength; i++){
				that.handleMealCard(allCards.meals[i]);
				that.updateTime();
			}
			//display all request card
			for (var j = 0; j < requestLength; j++){
				that.handleRequestCard(allCards.requests[j]);
				that.updateTime();
			}
		},

		//function accepts a meal object as the parameter
		//append the rendered meal card to the HTML page by calling handleMealCard
		//call updateTime function to be able to update time for added card
		displayAddedMealCard : function(meal_obj,replace) {
			if(replace) {
				var id = meal_obj.id;
				var parent_card = this.$mainWrapper.find("#"+id).parent();
				this.removeCard(parent_card);
			}
			this.handleMealCard(meal_obj);
			this.updateTime();
		},

		//function accepts a request object as the parameter
		//append the rendered request card to the HTML page by calling handleRequestCard
		//call updateTime function to be able to update time for added card
		displayAddedRequestCard : function(request_obj) {
			this.handleRequestCard(request_obj);
			this.updateTime();
		},
		
		//creates a new card and a new DOM element to insert the card to html file
		handleMealCard : function(obj) {
			var templateSource = $("#card-template-order").html();
			template = Handlebars.compile(templateSource);				
			cardBodyHTML = template(obj);

			//create a new DOM element to put in the newly created card
			var elem = document.createElement('div');
			
			//add in the identifying attribute values of the div
			elem.className = 'item';
			elem.setAttribute("id", "card-"+obj.id);
			elem.innerHTML = cardBodyHTML;
			
			//call masonry plugin to append and format the cards
			this.$mainWrapper.append(elem).masonry('appended',elem);

			//rearrange remaining cards
			this.$mainWrapper.masonry();

			this.updateNotification('plus');
			bind_popup();
		},
	
		//creates a new card and a new DOM element to insert the card to html file
		handleRequestCard : function(obj) {
			var templateSource = $("#card-template-request").html();
			template = Handlebars.compile(templateSource);				
			cardBodyHTML = template(obj);
		
			//create a new DOM element to put in the newly created card
			var elem = document.createElement('div');
		
			//add in the identifying attribute values of the div
			elem.className = 'item request';
			elem.setAttribute("id", "card-"+obj.id);
			elem.innerHTML = cardBodyHTML;
		
			//call masonry plugin to append and format the cards
			this.$mainWrapper.append(elem).masonry('appended',elem);

			//rearrange remaining cards
			this.$mainWrapper.masonry();

			this.updateNotification('plus');
			bind_popup();
		},
		
		//use masonry to remove the corresponding meal/request element
		removeCard : function(elem) {
			this.$mainWrapper.masonry('remove', elem);

			//rearrange remaining cards
			this.$mainWrapper.masonry();

			this.updateNotification('minus');
		},

		//triggers acknowledgement event when button is clicked
		handleClick : function() {
			var button = $(this);
			document.dispatchEvent(new CustomEvent('cardClicked', { 
				'detail': {
					'button': button,
					'parent_card': button.parent(), 
					'card_id': button.attr('id'),
					'button_type': button.attr('rel'),
					'model': button.attr("model")
				} 
			}));
		},
		
		//update waiting time of meal order or request
		updateTime : function() {

			$('.countdown').each(function(){

				var timer = $(this);
				var startTime = timer.attr("start");
				//startTime is not accurate at the moment
				setInterval(function () {
					var secondsPassed = (new Date()- new Date(Number(startTime))) / 1000;
	            	var minutes = parseInt(secondsPassed / 60, 10);
	            	var seconds = parseInt(secondsPassed % 60, 10);
					//substitutes updated time to counter
					timer.html('<i class="icon-time"></i> waited ' + minutes + "m, " + seconds + "s");			
				},1000); //updates every second	
			});
		},
		
		//update and display number of notification
		//play alert sound every two minutes if there is/are existing notification(s)
		updateNotification : function(change) {
			$("nav ul li:first-child a p").remove();
			
			//masonry only removes elem at end of function, hence need to remove one before to update correct notification number
			if(change === 'minus') {
				var number = $(".item").length-1;
			} else if(change === 'plus') {
				var number = $(".item").length;					
			}

			if(!number) {
				$("nav ul li:first-child a").append("");
			} else {
				$("nav ul li:first-child a").append("<p class='notification'><span><i class='icon-bell'> " + number + "</i></span></p>");
			}
			
			document.dispatchEvent(new Event("alarm"));
			//play sound every 30 seconds if there are unacknowledged cards
			setInterval(function() {	
				document.dispatchEvent(new Event("alarm"));
			}, 30000);
		},

		checkCardNum : function (cardNum) {
			if (cardNum === 0) {
				this.$mainWrapper.append('<p class="no-cards"><i class="icon-smile"></i> You have no pending orders!</p>');
			} else if (this.$mainWrapper.find('.no-cards')) {
				// remove no card notice if there are cards and the notice exists
				$('.no-cards').remove();
			}
		},

		replaceMealCard : function(id) {
			var that = this;

		}
	}

	//Export to window
	window.app = window.app || {};
	window.app.View = View;

// })(window);