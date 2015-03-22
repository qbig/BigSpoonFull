function View() {
    this.$mainWrapper = $('#main .wrapper');
    this.$mainWrapper.masonry({
        resizeable: true,
        itemSelector: '.item',
        columWidth: 15,
        gutter: 10
    });
}

Handlebars.registerHelper('ifCond', function(v1, operator, v2, options) {
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
    displayAllCard: function(allCards) {
        var that = this;
        var mealLength = allCards.meals.length;
        var requestLength = allCards.requests.length;
        for (var i = 0; i < mealLength; i++) {
            that.handleMealCard(allCards.meals[i]);
            that.updateTime();
        }

        for (var j = 0; j < requestLength; j++) {
            that.handleRequestCard(allCards.requests[j]);
            that.updateTime();
        }
    },

    displayAddedMealCard: function(meal_obj, replace) {
        //if required to replace (due to resubmission of meal id before card is acknowledged, remove existing card before displaying updated meal card)
        if (replace) {
            var id = meal_obj.id;
            var parent_card = this.$mainWrapper.find("#" + id).parent();
            this.removeCard(parent_card);
        }
        this.handleMealCard(meal_obj);
        this.updateTime();
    },

    displayAddedRequestCard: function(request_obj) {
        this.handleRequestCard(request_obj);
        this.updateTime();
    },
    //creates a new card and a new DOM element to insert the card to html file
    handleMealCard: function(obj) {
        var templateSource = $("#card-template-order").html();
        template = Handlebars.compile(templateSource);
        cardBodyHTML = template(obj);

        var elem = document.createElement('div');
        elem.className = 'item';
        elem.setAttribute("id", "card-" + obj.id);
        elem.innerHTML = cardBodyHTML;

        this.$mainWrapper.append(elem).masonry('appended', elem);
        this.$mainWrapper.masonry();
        this.updateNotification('plus');
        bind_popup();
    },
    //creates a new card and a new DOM element to insert the card to html file
    handleRequestCard: function(obj) {
        var templateSource = $("#card-template-request").html();
        template = Handlebars.compile(templateSource);
        cardBodyHTML = template(obj);

        var elem = document.createElement('div');
        elem.className = 'item request';
        elem.setAttribute("id", "card-" + obj.id);
        elem.innerHTML = cardBodyHTML;

        this.$mainWrapper.append(elem).masonry('appended', elem);
        this.$mainWrapper.masonry();
        this.updateNotification('plus');
        bind_popup();
    },
    //use masonry to remove the corresponding meal/request element
    removeCard: function(elem) {
        this.$mainWrapper.masonry('remove', elem);
        this.$mainWrapper.masonry();
        this.updateNotification('minus');
    },
    removeCardWithId: function(itemId){
        var elem = $('id-'+itemId);
        this.removeCard(elem);
    },
    //triggers acknowledgement event when button is clicked
    handleClick: function() {
        var button = $(this);
        console.log("clicked");
        console.log(button);
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
    updateTime: function() {
        $('.countdown').each(function() {
            var timer = $(this);
            var startTime = timer.attr("start");

            setInterval(function() {
                var secondsPassed = (new Date() - new Date(Number(startTime))) / 1000;
                var minutes = parseInt(secondsPassed / 60, 10);
                var seconds = parseInt(secondsPassed % 60, 10);
                timer.html('<i class="icon-time"></i> waited ' + minutes + "m, " + seconds + "s");
            }, 1000);
        });
    },
    //update and display number of notification
    updateNotification: function(change) {
        $("nav ul li:first-child a p").remove();
        //masonry only removes elem at end of function, hence need to remove one before to update correct notification number
        if (change === 'minus') {
            var number = $(".item").length - 1;
        } else if (change === 'plus') {
            var number = $(".item").length;
        }
        if (!number) {
            $("nav ul li:first-child a").append("");
        } else {
            $("nav ul li:first-child a").append("<p class='notification'><span><i class='icon-bell'> " + number + "</i></span></p>");
        }
    },
    checkCardNum: function(cardNum) {
        if (cardNum === 0) {
            this.$mainWrapper.append('<p class="no-cards"><i class="icon-smile"></i> You have no pending orders!</p>');
        } else if (this.$mainWrapper.find('.no-cards')) {
            $('.no-cards').remove();
        }
    },
    replaceMealCard: function(id) {
        var that = this;
    }
};

window.app = window.app || {};
window.app.View = View;