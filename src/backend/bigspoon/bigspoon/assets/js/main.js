$(document).ready(function() {

    var container = document.querySelector('#main');
    var msnry = new Masonry( container, {
        itemSelector: '.item'
    });

    var host = "http://"+location.host;

    var STAFF_API_URLS = {
        "req": host+"api/v1/ackreq",
        "bill": host+"api/v1/closebill",
        "order": host+"api/v1/ackorder",
    }

    var csrftoken = $.cookie('csrftoken');

    $('.ack-button').each(function() {
        var button = $(this);
        var type = button.attr('rel');
        var container = button.parent();
        button.click(function() {
            $.post(
                STAFF_API_URLS[type],
                {  ,"csrfmiddlewaretoken":csrftoken}
            ).done(function(data) {
                console.log(data);
            });
        });
    });


});
