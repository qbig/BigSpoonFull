		//handlebar helper function for comparision
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
		
			$(document).ready(function(){
				//add a meal card
				$('#button1').click(function(){
					//get meal data with respective meal_id
					var meal_id = parseInt(document.getElementById('meal_id').value);	
					$.ajax({
		                    url: "meals.json",
		                    dataType: "text",
		                    //on success, filter the json to get specific data of the meal_id
		                    success: function(data) {
		                        var obj = JSON.parse(data);
		                        console.log(obj);
			                    var length = obj.meals.length;
			                    for(var i = 0; i < length;i++){
				                   if(obj.meals[i].meal_id == meal_id){
					                   var obj2 = obj.meals[i];
				                   }
			                    }
			                    //it is a javascript Object that contains meal data			                   
								handleMeals(obj2);
							}
					});
				});
				
				// add a request card
				$('#button2').click(function(){
					var request_id = parseInt(document.getElementById('request_id').value);	
					$.ajax({
		                    url: "requests.json",
		                    dataType: "text",
		                    success: function(data) {
		                    	console.log(data);
		                    	var obj = JSON.parse(data);
		                    	var length = obj.requests.length;
		                    	for (var i = 0; i < length; i++){
			                    	if(obj.requests[i].request_id == request_id){
				                    	var obj2 = obj.requests[i];
			                    	}
		                    	}		                        
								handleRequest(obj2);							
							}
					});
				});
				
				// for masonry
			    $("#main .wrapper").masonry({
			        resizeable: true,
			        itemSelector: '.item',
			        columnWidth: 15,
			    });

			});
			
			// this function read in the meal object data, call meal card template and render meal card HTML
			function handleMeals(resObj){
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
				
			};
		
			function handleRequest(resObj){
				//resObj is a javascript object of request data
				var templateSource = $("#card-template-request").html(),
				template = Handlebars.compile(templateSource),
				cardBodyHTML = template(resObj);
				var elem = document.createElement('div');
				elem.className = 'item request';
				elem.setAttribute("id", "card-"+resObj.request_id);
				elem.innerHTML= cardBodyHTML;
				$('#main .wrapper').append(elem).masonry('appended',elem);
			};
			

