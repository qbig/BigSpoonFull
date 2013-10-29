$(document).ready(function() {

    $("#main").masonry({
        resizeable: true,
        itemSelector: '.item'
    });

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
                location.reload();
            }).fail(function(data) {
                console.log("POST failed");
                console.log(data);
            });
        });
    });
});
