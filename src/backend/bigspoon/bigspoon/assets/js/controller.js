function Controller(model, view) {
    this.model = model;
    this.view = view;
    this.host = "http://" + location.host;
    this.page_start_time_in_seconds = new Date().getTime() / 1000;
    this.view.$mainWrapper.on('click', ".item a.acknowledge.ack-button", this.view.handleClick);
    this.view.$mainWrapper.on('click', ".item a.closebill.ack-button", this.view.handleClick);
    this.view.$mainWrapper.on('click', ".active a.closebill.ack-button", this.view.handleClick);
    this.view.$mainWrapper.on('click', ".item a.respond.ack-button", this.view.handleClick);
}
Controller.prototype = {
    // when open the page or refresh, if there are unacknowledged meal/request card, display them first
    // also add to the Model
    initialise: function(outlet_id) {
        document.addEventListener("allItemsAdded", this.updateView.bind(this));
        document.addEventListener("mealAdded", this.addMeal.bind(this));
        document.addEventListener("requestAdded", this.addRequest.bind(this));
        document.addEventListener('cardClicked', this.removeCard.bind(this));
        document.addEventListener('alarm', this.playAlarm.bind(this));
        document.addEventListener("checkNumCards", this.updateNumCards.bind(this));
        this.model.addAllCard(outlet_id);
        this.initSocketIO();
        this.sound = new Howl({
            urls: [media_url + 'sounds/notification.mp3']
        });
    },
    updateNumCards: function(e) {
        this.view.checkCardNum(e.detail);
        if (e.detail !== 0) {
            if (this.intervalId) {
                clearInterval(this.intervalId);
            }
            this.playAlarm();
            this.intervalId = setInterval(function() {
                document.dispatchEvent(new Event("alarm"));
            }, 30000);
        } else {
            clearInterval(this.intervalId);
        }
    },
    playAlarm: function() {
        this.sound.play();
    },
    removeCard: function(e) {
        var that = this;
        console.log("removing");
        console.log(e);
        console.log(this.host);
        //ajax post to backend with card_id with a callback to remove card and data
        if (this.host.indexOf("table") !== -1) {
            that.model.postRemoveData(e.detail, function() {
                e.detail.parent_card.remove();
            });
        } else {
            that.model.postRemoveData(e.detail, function() {
                that.model.removeData(e.detail, function() {
                    that.view.removeCard(e.detail.parent_card);
                });
            });
        }
    },
    initSocketIO: function() {
        // handle Socketio message, data may be in any of the following formats:
        // ['refresh', 'meal', 'new', 'meal_id']
        // ['refresh', 'meal', 'askbill', 'meal_id']
        // ['refresh', 'meal', 'closebill', 'meal_id']
        // ['refresh', 'request', 'new', 'request_id']
        // not implemented yet
        // ['refresh', 'meal', 'ack']   (reply from socketIO when a meal card is acknowledged)
        // ['refresh', 'request', 'ack']    (reply from socketIO when a request card is acknowledged)
        // ['refresh', 'menu', 'add']   (reply from socketIO when a menu detail is changed)
        var that = this;
        var details = {
            'reconnect': true,
            'reconnection delay': 500,
            'max reconnection attempts': 10
        };
        //host is a global variable. host = "http://"+location.host
        if (this.host.indexOf("8000") !== -1) {
            socket = io.connect(this.host, details);
        } else {
            socket = io.connect(this.host + ":8000", details);
        }
        socket.on("message", function(obj) {
            if (obj.message.type == "message") {
                var data = eval(obj.message.data);
                var path = location.pathname;
                if (data[0] == "refresh") {
                    var seconds_since_page_load = new Date().getTime() / 1000 - that.page_start_time_in_seconds;
                    if (seconds_since_page_load < REFRESH_INTEVAL_CAP) {
                        timeout_obj = setTimeout(function() {
                            that.handlePrompt(data, path);
                        }, (REFRESH_INTEVAL_CAP - seconds_since_page_load) * 1000);
                    } else {
                        that.handlePrompt(data, path);
                    }
                }
            }
        });
        socket.on("connect", function(obj) {
            if (OUTLET_IDS !== null) {
                for (var i = 0, len = OUTLET_IDS.length; i < len; i++) {
                    socket.send("subscribe:" + OUTLET_IDS[i]);
                }
            }
        });
    },
    handlePrompt: function(data, path) {
        if (data[1] === 'request') {
            if ($.inArray(path, this.model.STAFF_MEAL_PAGES[data[2]]) != -1) {
                if (data[2] == 'new') {
                    document.dispatchEvent(new CustomEvent("requestAdded", {
                        'detail': data[3]
                    }));
                }
            }
        } else if (data[1] === 'meal') {
            if ($.inArray(path, this.model.STAFF_MEAL_PAGES[data[2]]) != -1) {
                if (data[2] === 'new' || data[2] === 'askbill' || data[2] === 'closebill') {
                    document.dispatchEvent(new CustomEvent("mealAdded", {
                        'detail': data[3]
                    }));
                }
            }
        }
    },
    updateView: function() {
        this.view.displayAllCard(this.model.items);
    },
    addMeal: function(e) {
        var that = this;
        that.model.addMealCard(e.detail, function(mealObj, replace) {
            that.view.displayAddedMealCard(mealObj, replace);
        });
    },
    addRequest: function(e) {
        var that = this;
        that.model.addRequestCard(e.detail, function(requestObj) {
            that.view.displayAddedRequestCard(requestObj);
        });
    },
};
window.app = window.app || {};
window.app.Controller = Controller;