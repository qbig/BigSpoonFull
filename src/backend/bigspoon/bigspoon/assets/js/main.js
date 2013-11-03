$(document).ready(function() {

    // for socket io
    var STAFF_MEAL_PAGES = {
        "new": ['/staff/main/', '/staff/tables/'],
        "ack": ['/staff/main/', '/staff/history/', '/staff/tables/'],
        "askbill": ['/staff/main/', '/staff/history/', '/staff/tables/'],
        "closebill": ['/staff/main/', '/staff/report/', '/staff/tables/'],
        "all": ['/staff/main/', '/staff/report/', '/staff/tables/', '/staff/history/'],
    };
    var STAFF_MENU_PAGES = ['/staff/menu/'];
    socket = io.connect();
    socket.on("message", function(obj){
        if (obj.message.type == "message") {
            var data = eval(obj.message.data);
            var path = location.pathname;
            console.log(data);
            if (data[0] == "refresh") {
                if (data[1] == "request" || data[1] == "meal") {
                    if ($.inArray(path, STAFF_MEAL_PAGES[data[2]]) != -1) {
                        location.reload(true);
                    }
                }
                else if (data[1] == "menu") {
                    if ($.inArray(path, STAFF_MENU_PAGES) != -1) {
                        location.reload(true);
                    }
                }
                else {
                    // other instructions
                }
            }
        }
    });
    if (outlet_ids != null) {
        for (var i = 0, len = outlet_ids.length; i < len; i++) {
            socket.send("subscribe:" + outlet_ids[i]);
        }
    }

    // for masonry
    $("#main .wrapper").masonry({
        resizeable: true,
        itemSelector: '.item',
        columnWidth: 40,
    });

    // for request and order ack
    var host = "http://"+location.host;

    var STAFF_API_URLS = {
        "req": host+"/api/v1/ackreq",
        "bill": host+"/api/v1/closebill",
        "order": host+"/api/v1/ackorder",
        "note": host+"/api/v1/note",
    }

    var csrftoken = $.cookie('csrftoken');

    window.saveNote = function(elem){
            var button = $(elem);
            var user = button.attr('user');
            var outlet = button.attr('outlet');
            var content = button.parent().find('.notes').val();

            var req_data = {
                "csrfmiddlewaretoken":csrftoken,
                "outlet": outlet,
                "user": user,
                "content":content,
            }

            console.log(req_data);

            $.post(
                STAFF_API_URLS["note"],
                req_data
            ).done(function(data) {
                console.log("POST success!");
            }).fail(function(data) {
                console.log("POST failed");
                console.log(data);
            });
    }

    // for user pop up
    $(".user-profile-link").magnificPopup({
        type: 'ajax',
        alignTop: true,
        closeBtnInside: true,
        overflowY: 'scroll',
    });

    $('.ack-button').each(function() {
        var button = $(this);
        var type = button.attr('rel');
        var item = button.parent();
        var req_data = {
            "csrfmiddlewaretoken":csrftoken
        }
        req_data[button.attr("model")] = button.attr("id");
        button.click(function() {
            $.post(
                STAFF_API_URLS[type],
                req_data
            ).done(function(data) {
                location.reload(true);
            }).fail(function(data) {
                console.log("POST failed");
                console.log(data);
            });
        });
    });


    // for countdown

    $('.countdown').each(function() {
        var card = $(this);
        var start_time = card.attr("start");
        setInterval(function () {

            var seconds_left = (new Date() - new Date(Number(start_time))) / 1000;
            // do some time calculations
            days = parseInt(seconds_left / 86400);
            seconds_left = seconds_left % 86400;

            hours = parseInt(seconds_left / 3600);
            seconds_left = seconds_left % 3600;

            minutes = parseInt(seconds_left / 60);
            seconds = parseInt(seconds_left % 60);

            // format countdown string + set tag value
            card.html('<i class="icon-time"></i> waited ' + days + "d, " + hours + "h, "
            + minutes + "m, " + seconds + "s");

        }, 1000);
    });
});
