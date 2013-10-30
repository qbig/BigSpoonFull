$(document).ready(function() {

    // for socket io
    socket = io.connect();
    socket.on("message", function(obj){
        if (obj.message.type == "message") {
            var data = eval(obj.message.data);
            console.log(data);
            if (data[0] == "refresh") {
                location.reload(true);
            }
        }
    });
    if (outlet_ids != null) {
        for (var i = 0, len = outlet_ids.length; i < len; i++) {
            socket.send("subscribe:" + outlet_ids[i]);
        }
    }

    // for masonry
    $("#main").masonry({
        resizeable: true,
        itemSelector: '.item'
    });

    // for user pop up
    $(".user-profile-link").magnificPopup({
        type: 'ajax',
        alignTop: true,
        closeBtnInside: true,
        overflowY: 'scroll',
    });

    // for request and order ack
    var host = "http://"+location.host;

    var STAFF_API_URLS = {
        "req": host+"/api/v1/ackreq",
        "bill": host+"/api/v1/closebill",
        "order": host+"/api/v1/ackorder",
    }

    var csrftoken = $.cookie('csrftoken');

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
});
