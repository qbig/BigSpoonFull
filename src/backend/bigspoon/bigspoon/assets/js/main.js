$(document).ready(function() {
    var page_start_time_in_seconds = new Date().getTime()/1000;
    var REFRESH_INTEVAL_CAP = 30;
    var host = "http://"+location.host;
    var timeout_obj;
    window.transfer_from_table;
    window.transfer_to_table;
    window.order_to_modify;
    window.selected_userId;
    window.order_quant_before_change;
    window.is_in_popup = false;

    
    $(document).on("click", "a.main-nav", function(event){
        event.preventDefault();
        window.location = $(this).attr("href");
    });

    var sound = new Howl({
        urls: [media_url + 'sounds/notification.mp3']
    });
    var reload_sound = new Howl({
        urls: [media_url + 'sounds/notification.mp3'],
        onend: function() {
            location.reload(true);
        }
    });

    function getNotification(number){
        if(!number){
            return "<p class='notification'><span><i class='icon-bell'> New</i></span></p>";
        }
        return "<p class='notification'><span><i class='icon-bell'> " + number + "</i></span></p>";
    }

    function showNotification(number) {
        $("nav ul li:first-child a p").remove();
        $("nav ul li:first-child a").append(getNotification(number));
        sound.play();
        setInterval(function() {
            sound.play();
        }, 120000);
    }

    function showNotificationReload(number) {
        $("nav ul li:first-child a p").remove();
        $("nav ul li:first-child a").append(getNotification(number));
        reload_sound.play();
        setTimeout(function(){
            location.reload(true);
        }, 1500);
    }

    function handleRefresh(data, path){        
        if (data[1] == "request" || data[1] == "meal") {
            if ($.inArray(path, STAFF_MEAL_PAGES[data[2]]) != -1) {
                if (data[2] == "new" || data[2] == "askbill") {
                    showNotificationReload();
                } else {
                    location.reload(true);
                }
            }
            
            if (data[2] == "new" || data[2] == "askbill") {
                showNotification();
            }

        } else if (data[1] == "menu") {
            if ($.inArray(path, STAFF_MENU_PAGES) != -1) {
                location.reload(true);
            }
        } else {
                        // other instructions
                    }
                    if (timeout_obj) {
                        clearTimeout(timeout_obj);
                    }
                }

                if ( cards_num > 0) {
                    showNotification(cards_num);
                }

    // time picker
    $('input.ui-timepicker-input').timepicker({
        'timeFormat': 'H:i:s',
        'step': 30,
        'maxTime': '11:59pm',
    });

    // close all menu
    function closeAllMenu() {
        $('.ui-accordion-header').removeClass('ui-accordion-header-active ui-state-active ui-corner-top').addClass('ui-corner-all').attr({
            'aria-selected': 'false',
            'tabindex': '-1'
        });
        $('.ui-accordion-header').find("i").removeClass('icon-collapse-top').addClass('icon-collapse');
        $('.ui-accordion-content').removeClass('ui-accordion-content-active').attr({
            'aria-expanded': 'false',
            'aria-hidden': 'true'
        }).hide();
    }

    // Menu update page live search/filter
    $('#filter').keyup(function() {
        var f = $(this).val();
        var regex = new RegExp(f, 'gi');

        closeAllMenu();
        $('#accordion h3').hide()
        .each(function() {
            if($(this).text().match(regex)) {
                $(this).show();
            }
        });
    });

    // filter by dish category
    $('#pick-category').on("change", function() {
        var category = $(this).val();
        var regex = new RegExp(category, 'gi');

        closeAllMenu();
        $('#accordion h3').hide()
        .each(function() {
            if($(this).find("input").val().match(regex)) {
                $(this).show();
            }
        });
    });

    $('#pick-table select').on("change", function() {
        var table = $(this).val();
        if (table == "All Tables") {
            $('.table').show();
        }
        else {
            $('.table').hide()
            .each(function() {
                if($(this).find('h3').text() == table) {
                    $(this).show();
                }
            });
        }
    });

    // Menu update page collapsibles
    $('#accordion').accordion({
        collapsible:true,
        active:false,

        beforeActivate: function(event, ui) {
             // The accordion believes a panel is being opened
             if (ui.newHeader[0]) {
                var currHeader  = ui.newHeader;
                var currContent = currHeader.next('.ui-accordion-content');
             // The accordion believes a panel is being closed
         } else {
            var currHeader  = ui.oldHeader;
            var currContent = currHeader.next('.ui-accordion-content');
        }
             // Since we've changed the default behavior, this detects the actual status
             var isPanelSelected = currHeader.attr('aria-selected') == 'true';

             // Toggle the panel's header
             currHeader.toggleClass('ui-corner-all',isPanelSelected).toggleClass('accordion-header-active ui-state-active ui-corner-top',!isPanelSelected).attr('aria-selected',((!isPanelSelected).toString()));

            // Toggle the panel's icon
            currHeader.children('.ui-icon').toggleClass('ui-icon-triangle-1-e',isPanelSelected).toggleClass('ui-icon-triangle-1-s',!isPanelSelected);

             // Toggle the panel's content
             currContent.toggleClass('accordion-content-active',!isPanelSelected)
             if (isPanelSelected) { currContent.slideUp(); }  else { currContent.slideDown(); }

            return false; // Cancel the default action
        }
    });

    // Dismiss tutorial messages
    $(".help").click(function(){
        $(this).hide();
    });

    // Toggle accordion icons
    $("#accordion h3").click(function(){
        var icon = $(this).find("i");
        if(icon.hasClass('icon-collapse')){
            icon.removeClass('icon-collapse').addClass('icon-collapse-top');
        } else {
            icon.removeClass('icon-collapse-top').addClass('icon-collapse');
        }
    });

    // for socket io
    var STAFF_MEAL_PAGES = {
        "new": ['/staff/main/'],
        "ack": ['/staff/main/', '/staff/history/', '/staff/tables/'],
        "askbill": ['/staff/main/', '/staff/history/', '/staff/tables/'],
        "closebill": ['/staff/main/', '/staff/report/', '/staff/tables/', '/staff/history/'],
    };
    var STAFF_MENU_PAGES = ['/staff/menu/'];
    var details = {
      'reconnect': true,
      'reconnection delay': 500,
      'max reconnection attempts': 10
    };
    if (host.indexOf("8000") !== -1) {
        socket = io.connect(host, details);
    }
    else {
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
                        handleRefresh(data, path);
                    }, (REFRESH_INTEVAL_CAP - seconds_since_page_load) * 1000);
                } else {
                    handleRefresh(data, path);
                }
            }
        }
    });

    if (outlet_ids !== null) {
        for (var i = 0, len = outlet_ids.length; i < len; i++) {
            socket.send("subscribe:" + outlet_ids[i]);
        }
    }

    // for masonry
    $("#main .wrapper").masonry({
        resizeable: true,
        itemSelector: '.item',
        columnWidth: 15,
    });

    // for request and order ack
    var STAFF_API_URLS = {
        "req": host+"/api/v1/ackreq",
        "bill": host+"/api/v1/closebill",
        "order": host+"/api/v1/ackorder",
        "note": host+"/api/v1/note",
        "dish": host+"/api/v1/dish",
        "spending": host+"/api/v1/spending",
        "newOrder": host+"/api/v1/meal-update",
        "table" : host + "/api/v1/table",
        "table-single" : host + "/api/v1/table-single-diner",
        "order_update" : host + "/api/v1/order",
    };

    window.csrftoken = $.cookie('csrftoken');

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
        };


        $.post(
            STAFF_API_URLS["note"],
            req_data
            ).done(function(data) {
                console.log("POST success!");
                button.parent().append("<p class='success'><i class='icon-ok-sign'></i> Note saved!</p>");


            }).fail(function(data) {
                console.log("POST failed");
                console.log(data);
            });
    };

    window.successMessage = function(name){
        var successMessage = "<p class='success'><i class='icon-ok-sign'></i> Dish details updated! </p>";
        return successMessage;
    };

    function getErrorMessage(name){
        var errorMessage = "<p class='error'><i class='icon-frown'></i> Form error. Changes are not saved. </p>";
        return errorMessage;
    }

    // Makes AJAX call to update dish API endpoint
    window.updateDish = function(elem){
        var button = $(elem);
        var form = button.parent();

        var id = button.attr('dish-id');
        var name = form.find('.name input').val();
        var price = form.find('.price input').val();
        var pos = form.find('.pos input').val();
        var desc = form.find('.description textarea').val();
        var quantity = form.find('.quantity select option:selected').val();
        var start_time = form.find('.start_time input').val();
        var end_time = form.find('.end_time input').val();

        console.log("Update dish " + id);

        var req_data = {
            "csrfmiddlewaretoken":csrftoken,
            "name":name,
            "price":price,
            "pos":pos,
            "desc":desc,
            "quantity":quantity,
            "start_time":start_time,
            "end_time":end_time,
            // "categories":categories
        };

        $.post(
            STAFF_API_URLS["dish"] + "/" + id,
            req_data
            ).done(function(data) {
                var notice_id = '#notice-' + id;
                $(notice_id).empty();
                $(notice_id).append(successMessage(name)).effect("highlight", {}, 3000);
                console.log("POST success!");
            }).fail(function(data) {
                var notice_id = '#notice-' + id;
                $(notice_id).empty();
                $(notice_id).append(getErrorMessage(name)).effect("highlight", {}, 3000);
                console.log("POST failed");
                console.log(data);
        });

    };

    // after change table in bulk, need to bind the popup event again
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

    $('.ack-button').each(function() {
        var button = $(this);
        var type = button.attr('rel');
        var item = button.parent();
        var req_data = {
            "csrfmiddlewaretoken":csrftoken
        };
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

            // console.log(seconds_left);
            var minutes = parseInt(seconds_left / 60, 10);
            var seconds = parseInt(seconds_left % 60, 10);

            // format countdown string + set tag value
            card.html('<i class="icon-time"></i> waited ' + minutes + " m, " + seconds + " s");

        }, 1000);
    });

    $('.pageDropdownChangeTable').click(function(){
        is_in_popup = false;
    });

    $('.tableDropdown').click(function(){
        var self = $(this);
        window.transfer_from_table = self.attr("data-tableId");
        console.log(transfer_from_table);
    });

    window.setOriginTable = function (object){
        var self = $(object);
        window.selected_userId = self.attr("data-userId");
        var table_title = $("#popup-table-" + selected_userId);
        window.transfer_from_table = table_title.attr("data-tableId");
    };

    window.startToSelectDishForNewOrder = function(object){
        var self = $(object);
        self.parent("div").find("input").toggle();
        if(self.html() != "Add"){
            self.html("Add");
            self.css({'margin-left': 10});
        } else {
            self.html("Add Order");
            self.css({'margin-left': 0});
            if (window.transfer_from_table && window.selected_userId && chosenDishId){
                var req_data = {
                    "csrfmiddlewaretoken":csrftoken,
                    "from_table" : window.transfer_from_table,
                    "diner_id" : selected_userId,
                    "dish_id" : chosenDishId
                };
                $.post(
                    STAFF_API_URLS["newOrder"],
                    req_data
                ).done(function(data) {
                    //{"quantity":1,"dish":
                    //{"price":"9.5","id":35,"name":"Crabbies Strawberry & Lime Ginger Beer"}}
                    var popup_order_container = $(".current-orders .order");
                    var page_order_container = $("#card-" + selected_userId + " .order");
                    popup_order_container.find(".no-order").remove();
                    page_order_container.find(".no-order").remove();

                    var source_for_popup = '<li id="popup-order-container-'+ data.id +'">' +
                    '<p>'+data.dish.name;
                    if(data.is_finished){
                        source_for_popup += '<span class="processed">(processed)</span>';
                    }
                    source_for_popup += '</p>'+
                    '<em class="pos">'+data.dish.pos+'</em>' +
                    '<a class="plus_order_icon_btn" data-orderId="'+data.id+'" href="#" onclick="incrementQuantityForOrder(this);"><i class="icon-plus-sign icon-2"></i></a>' +
                    '<em class="quantity">'+data.quantity+'x</em>' +
                    '<a class="minus_order_icon_btn" data-orderId="'+data.id+'" href="#" onclick="decrementQuantityForOrder(this);"><i class="icon-minus-sign icon-2"></i></a></li>';
                    $(source_for_popup).appendTo(popup_order_container);

                    var source_page = '<li id="page-order-container-'+ data.id +'">' +
                                    '<em class="quantity">' + data.quantity + 'x</em>' +
                                    '<p>' + data.dish.name + '</p>';
                    if(data.is_finished){
                        source_page += '<a class="popup-modal cancel_order_icon_btn" data-orderId="'+ data.id +'" href="#test-modal"><i class="icon-remove-sign icon-2"></i></a>';
                    } else {
                        source_page += '<em class="pos">'+ data.dish.pos +'</em>';
                    }
                    source_page += '</li>';
                    page_order_container.find(".end").before(source_page);

                    bind_popup();
                }).fail(function(data) {
                    console.log("adding new order fail");
                });
            }
        }
    };

    function trimToLen(str, len){
        var trimmedString = str.length > len ? str.substring(0, len - 3) + "..." : str + new Array(len - str.length).join(' ');
        return trimmedString;
    }

    window.chooseCategory = function(object){
        var chosenCat = $(object);
        var catButton = $('.cat-dropDown-btn');
        var dishButton = $('.dish-dropDown-btn');
        catButton.val(trimToLen($.trim(chosenCat.html()), 20));
        window.chosenCatId = chosenCat.attr("data-categoryId");
        dishButton.attr("data-dropdown", dishButton.attr("data-dropdown").substring(0, 28) + window.chosenCatId);
    };

    window.chooseDish = function(object){
        var chosenDish = $(object);
        var dishButton = $('.dish-dropDown-btn');
        dishButton.val(trimToLen($.trim(chosenDish.html()), 15));
        window.chosenDishId = chosenDish.attr("data-dishId");
    };

    $('.targetTable').click(function() {
        var self = $(this);
        targetTableId = self.attr("data-toTableId");
        var from_table_obj = $("#table-"+window.transfer_from_table);
        var to_table_obj = $("#table-" + targetTableId);
        var content_from_table = from_table_obj.html();
        var content_target_table = to_table_obj.html();
        var req_data = {
            "csrfmiddlewaretoken":csrftoken,
            "from_table" : window.transfer_from_table,
            "to_table" : targetTableId,
        };

        if(!is_in_popup){
            $.post(
                STAFF_API_URLS["table"],
                req_data
            ).done(function(data) {
                from_table_obj.html(content_target_table);
                to_table_obj.html(content_from_table);
                bind_popup();
            }).fail(function(data) {
                console.log("table transfer fail");
            });
        } else {
            req_data["diner_id"] = window.selected_userId;
            $.post(
                STAFF_API_URLS["table-single"],
                req_data
            ).done(function(data) {
                var card = $("#card-" + selected_userId);
                var cur_table = $("#popup-table-" + selected_userId);
                cur_table.html("Table " + $.trim(self.html()).substring(9));
                cur_table.attr("data-tableId", targetTableId);
                $(".user-"+selected_userId).html($.trim(self.html()).substring(9));
                card.appendTo("#table-" + targetTableId);
            }).fail(function(data) {
                console.log("table transfer fail");
            });
        }
    });

    //for cancel an order 
    window.incrementQuantityForOrder = function (object) {
        var plus_icon_clicked = $(object);
        var order_id = plus_icon_clicked.attr("data-orderId");
        var popup_order_container = $("#popup-order-container-" + order_id);
        var quantity_element = popup_order_container.find(".quantity");
        var page_order_container = $("#page-order-container-" + order_id);
        var quantity = parseInt(quantity_element.html(), 10);
        var req_data = {
            "csrfmiddlewaretoken":csrftoken,
            "order_id" : order_id,
            "new_quant" : quantity + 1
        };
        $.post(
            STAFF_API_URLS["order_update"],
            req_data
        ).done(function(data) {
            if(data.quantity >= 1){
                quantity_element.html(data.quantity + "x");
                page_order_container.find(".quantity").html(data.quantity + "x");
            } else {
                popup_order_container.remove();
                page_order_container.remove();
            }
                
        }).fail(function(data) {
                console.log("order update failed");
        });
    };

    window.decrementQuantityForOrder = function(object) {
        var minus_icon_clicked = $(object);
        var order_id = minus_icon_clicked.attr("data-orderId");
        var popup_order_container = $("#popup-order-container-" + order_id);
        var page_order_container = $("#page-order-container-" + order_id);
        var quantity_element = popup_order_container.find(".quantity");
        var quantity = parseInt(quantity_element.html(), 10);
        var req_data = {
            "csrfmiddlewaretoken":csrftoken,
            "order_id" : order_id,
            "new_quant" : quantity - 1
        };
        $.post(
            STAFF_API_URLS["order_update"],
            req_data
        ).done(function(data) {
            if(data.quantity >= 1){
                quantity_element.html(data.quantity + "x");
                page_order_container.find(".quantity").html(data.quantity + "x");
            } else {
                popup_order_container.remove();
                page_order_container.remove();
            }
                
        }).fail(function(data) {
                console.log("order update failed");
        });
    };
    
    $(document).on('click', '.popup-modal-dismiss', function (e) {
        e.preventDefault();
        $.magnificPopup.close();
    });
    $(document).on('click', '.popup-modal-ok', function (e) {
        e.preventDefault();
        $.magnificPopup.close();
        var order_li_obj = $("#page-order-container-" + order_to_modify);
        var order_li_num_obj = order_li_obj.find("em").first();
        var quantity = parseInt(order_li_obj.find(".quantity").html(), 10);
        var req_data = {
            "csrfmiddlewaretoken":csrftoken,
            "order_id" : order_to_modify,
            "new_quant" : quantity - 1
        };
        $.post(
            STAFF_API_URLS["order_update"],
            req_data
        ).done(function(data) {
            if(data.quantity >= 1){
                order_li_num_obj.html(data.quantity + "x");
            } else {
                order_li_obj.remove();
            }
                
        }).fail(function(data) {
                console.log("order update failed");
        });

    });
});
