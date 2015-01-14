$(document).ready(function() {
    var page_start_time_in_seconds = new Date().getTime() / 1000;
    var host = "http://" + location.host;
    var timeout_obj;
    window.transfer_from_table;
    window.transfer_to_table;
    window.order_to_modify;
    window.selected_userId;
    window.order_quant_before_change;
    window.is_in_popup = false;
    if (window.REFRESH_INTEVAL_CAP === undefined) {
        window.REFRESH_INTEVAL_CAP = 30;
    }
    var csrftoken = $.cookie('csrftoken');
    $.ajaxSetup({
        headers: {
            "X-CSRFToken": csrftoken
        }
    });
    // ==========  behavior  =========
    // if idle time is more than 2 mins, go back to "New Order" page
    window.idleTimeMinutes = 0;
    window.timerIncrement = function() {
        window.idleTimeMinutes = window.idleTimeMinutes + 1;
        if (window.idleTimeMinutes >= 2 && window.location.pathname !== "/staff/main/") { // 2 minutes and not already in main page
            window.location = "/staff/main/";
        }
    };
    var idleInterval = setInterval(timerIncrement, 60000); // 1 minute
    //Zero the idle timer on mouse movement.
    $(this).mousemove(function(e) {
        window.idleTimeMinutes = 0;
    });
    $(this).mouseup(function(e) {
        window.idleTimeMinutes = 0;
    });
    // ==========  behavior  =========
    // Stop opening a new page when using as a web app on ipad
    $(document).on("click", "a.main-nav, a.add", function(event) {
        event.preventDefault();
        window.location = $(this).attr("href");
    });

    // ==========  Menu page specific  =========
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
        $('#accordion h3').hide().each(function() {
            if ($(this).text().match(regex)) {
                $(this).show();
            }
        });
    });
    // filter by dish category
    $('#pick-category').on("change", function() {
        var category = $(this).val();
        var regex = new RegExp(category, 'gi');
        closeAllMenu();
        $('#accordion h3').hide().each(function() {
            if ($(this).find("input").val().match(regex)) {
                $(this).show();
            }
        });
    });
    // Menu update page collapsibles
    $('#accordion').accordion({
        collapsible: true,
        active: false,
        beforeActivate: function(event, ui) {
            // The accordion believes a panel is being opened
            if (ui.newHeader[0]) {
                var currHeader = ui.newHeader;
                var currContent = currHeader.next('.ui-accordion-content');
                $("img.lazy").Lazy({
                    bind: "event",
                    delay: 0
                });
                // The accordion believes a panel is being closed
            } else {
                var currHeader = ui.oldHeader;
                var currContent = currHeader.next('.ui-accordion-content');
            }
            // Since we've changed the default behavior, this detects the actual status
            var isPanelSelected = currHeader.attr('aria-selected') == 'true';
            // Toggle the panel's header
            currHeader.toggleClass('ui-corner-all', isPanelSelected).toggleClass('accordion-header-active ui-state-active ui-corner-top', !isPanelSelected).attr('aria-selected', ((!isPanelSelected).toString()));
            // Toggle the panel's icon
            currHeader.children('.ui-icon').toggleClass('ui-icon-triangle-1-e', isPanelSelected).toggleClass('ui-icon-triangle-1-s', !isPanelSelected);
            // Toggle the panel's content
            currContent.toggleClass('accordion-content-active', !isPanelSelected)
            if (isPanelSelected) {
                currContent.slideUp();
            } else {
                currContent.slideDown();
            }
            return false; // Cancel the default action
        }
    });
    // Toggle accordion icons
    $("#accordion h3").click(function() {
        var icon = $(this).find("i");
        if (icon.hasClass('icon-collapse')) {
            icon.removeClass('icon-collapse').addClass('icon-collapse-top');
        } else {
            icon.removeClass('icon-collapse-top').addClass('icon-collapse');
        }
    });
    // ==========  Table page specific  =========
    var filterTable = function() {
        var table = $(this).val();
        if (table == "Occupied Tables") {
            $('.table').hide().each(function() {
                var currentTable = $(this);
                if (currentTable.find('.active').size() >= 1) {
                    currentTable.show();
                }
            });
        } else if (table == "All Tables") {
            $('.table').show();
        } else {
            $('.table').hide().each(function() {
                if ($(this).find('h3').text() == table) {
                    $(this).show();
                }
            });
        }
    };
    $('#pick-table select').on("change", filterTable);
    // ==========  behavior  =========
    // Dismiss tutorial messages
    $(".help").click(function() {
        $(this).hide();
    });

    // ==========  behavior  =========
    // in profile popup: save note
    window.saveNote = function(elem) {
        var button = $(elem);
        var user = button.attr('user');
        var outlet = button.attr('outlet');
        var content = button.parent().find('.notes').val();
        var req_data = {
            "csrfmiddlewaretoken": csrftoken,
            "outlet": outlet,
            "user": user,
            "content": content,
        };
        $.post(STAFF_API_URLS["note"], req_data).done(function(data) {
            console.log("POST success!");
            button.parent().append("<p class='success'><i class='icon-ok-sign'></i> Note saved!</p>");
        }).fail(function(data) {
            console.log("POST failed");
            console.log(data);
        });
    };
    window.successMessage = function(name) {
        var successMessage = "<p class='success'><i class='icon-ok-sign'></i> Dish details updated! </p>";
        return successMessage;
    };

    function getErrorMessage(name) {
        var errorMessage = "<p class='error'><i class='icon-frown'></i> Form error. Changes are not saved. </p>";
        return errorMessage;
    }
    // Menu page specific
    // Makes AJAX call to update dish API endpoint
    window.updateDish = function(event, elem) {
        event.preventDefault();
        var button = $(elem);
        var form = button.parent();
        var id = button.attr('dish-id');
        var category_id = button.attr('cate-id');
        var category_name = button.attr('cate-name');
        var category_desc = button.attr('cate-desc');
        var name = form.find('.name input').val();
        var price = form.find('.price input').val();
        var pos = form.find('.pos input').val();
        var desc = form.find('.description textarea').val();
        var quantity = form.find('.quantity select option:selected').val();
        var start_time = form.find('.start_time input').val();
        var end_time = form.find('.end_time input').val();
        var is_active = form.find('input[name="isActiveCheckbox"]:checked').length > 0 ? 1 : 0;
        var photo = form.find('.photo input').val();
        console.log("Update dish " + id);
        var req_data = {
            "id": id,
            "csrfmiddlewaretoken": csrftoken,
            "name": name,
            "price": price,
            "pos": pos,
            "desc": desc,
            "quantity": quantity,
            "start_time": start_time,
            "end_time": end_time,
            "is_active": is_active,
            "photo": photo,
            "outlet": OUTLET_IDS[0],
            //"categories": [category_id]
            //"categories":[{'id': category_id, 'name': category_name, 'desc': category_desc}]
        };
        console.log(req_data);
        $.post(STAFF_API_URLS["dish"] + "/" + id, req_data).done(function(data) {
            var notice_id = '#notice-' + id;
            $(notice_id).empty();
            $(notice_id).append(successMessage(name)).effect("highlight", {}, 3000);
            console.log("POST success!");
            console.log(data);
        }).fail(function(data) {
            var notice_id = '#notice-' + id;
            $(notice_id).empty();
            $(notice_id).append(getErrorMessage(name)).effect("highlight", {}, 3000);
            console.log("POST failed");
            console.log(data);
        });
    };
    $('.fileupload').each(function() {
        var self = $(this);
        var dishUrl = '/staff/menu/dish/' + self.attr('dish-id');
        var img = self.parent().parent().parent().find('.lazy');
        self.fileupload({
            url: dishUrl,
            crossDomain: false,
            beforeSend: function(xhr, settings) {},
            dataType: 'json',
            done: function(e, data) {
                img.attr("src", data.result.files[0].thumbnailUrl);
            },
            progressall: function(e, data) {
                // var progress = parseInt(data.loaded / data.total * 100, 10);
                // $('#progress .progress-bar').css(
                //     'width',
                //     progress + '%'
                // );
            }
        }).prop('disabled', !$.support.fileInput).parent().addClass($.support.fileInput ? undefined : 'disabled');
    });
    // ==========  behavior  =========
    // after change table in bulk, need to bind the popup event again
    window.bind_popup = function bind_popup() {
        // for User profile pop up
        $(".user-profile-link").magnificPopup({
            type: 'ajax',
            settings: {
                cache: false
            },
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
            settings: {
                cache: false
            },
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
        $('.cancel_order_icon_btn').click(function() {
            var icon_clicked = $(this);
            order_to_modify = icon_clicked.attr('data-orderId');
        });
    };
    bind_popup();

    // ==========  behavior  =========
    // Changing tables
    $('.pageDropdownChangeTable').click(function() {
        is_in_popup = false;
    });
    // Change table in page
    $('.tableDropdown').click(function() {
        var self = $(this);
        window.transfer_from_table = self.attr("data-tableId");
        console.log(transfer_from_table);
    });
    // Change table in pop
    window.setOriginTable = function(object) {
        var self = $(object);
        window.selected_userId = self.attr("data-userId");
        var table_title = $("#popup-table-" + selected_userId);
        window.transfer_from_table = table_title.attr("data-tableId");
    };
    // Change table in pop
    $('.targetTable').click(function() {
        var self = $(this);
        targetTableId = self.attr("data-toTableId");
        var from_table_obj = $("#table-" + window.transfer_from_table);
        var to_table_obj = $("#table-" + targetTableId);
        var content_from_table = from_table_obj.html();
        var content_target_table = to_table_obj.html();
        var req_data = {
            "csrfmiddlewaretoken": csrftoken,
            "from_table": window.transfer_from_table,
            "to_table": targetTableId,
        };
        if (!is_in_popup) {
            $.post(STAFF_API_URLS["table"], req_data).done(function(data) {
                from_table_obj.html(content_target_table);
                to_table_obj.html(content_from_table);
                bind_popup();
            }).fail(function(data) {
                console.log("table transfer fail");
            });
        } else {
            req_data["diner_id"] = window.selected_userId;
            $.post(STAFF_API_URLS["table-single"], req_data).done(function(data) {
                var card = $("#card-" + selected_userId);
                var cur_table = $("#popup-table-" + selected_userId);
                cur_table.html("Table " + $.trim(self.html()).substring(9));
                cur_table.attr("data-tableId", targetTableId);
                $(".user-" + selected_userId).html($.trim(self.html()).substring(9));
                card.appendTo("#table-" + targetTableId);
            }).fail(function(data) {
                console.log("table transfer fail");
            });
        }
    });
    // Add new dish in popup
    window.startToSelectDishForNewOrder = function(object) {
        var self = $(object);
        self.parent("div").find("input").toggle();
        if (self.html() != "Add") {
            self.html("Add");
            self.css({
                'margin-left': 10
            });
        } else {
            self.html("Add Order");
            self.css({
                'margin-left': 0
            });
            if (window.transfer_from_table && window.selected_userId && chosenDishId) {
                var req_data = {
                    "csrfmiddlewaretoken": csrftoken,
                    "from_table": window.transfer_from_table,
                    "diner_id": selected_userId,
                    "dish_id": chosenDishId
                };
                $.post(STAFF_API_URLS["newOrder"], req_data).done(function(data) {
                    //{"quantity":1,"dish":
                    //{"price":"9.5","id":35,"name":"Crabbies Strawberry & Lime Ginger Beer"}}
                    var popup_order_container = $(".current-orders .order");
                    var page_order_container = $("#card-" + selected_userId + " .order");
                    popup_order_container.find(".no-order").remove();
                    page_order_container.find(".no-order").remove();
                    var source_for_popup = '<li id="popup-order-container-' + data.id + '">' + '<p>' + data.dish.name;
                    if (data.is_finished) {
                        source_for_popup += '<span class="processed">(processed)</span>';
                    }
                    source_for_popup += '</p>' + '<em class="pos">' + data.dish.pos + '</em>' + '<a class="plus_order_icon_btn" data-orderId="' + data.id + '" href="#" onclick="incrementQuantityForOrder(this);"><i class="icon-plus-sign icon-2"></i></a>' + '<em class="quantity">' + data.quantity + 'x</em>' + '<a class="minus_order_icon_btn" data-orderId="' + data.id + '" href="#" onclick="decrementQuantityForOrder(this);"><i class="icon-minus-sign icon-2"></i></a></li>';
                    $(source_for_popup).appendTo(popup_order_container);
                    var source_page = '<li id="page-order-container-' + data.id + '">' + '<em class="quantity">' + data.quantity + 'x</em>' + '<p>' + data.dish.name + '</p>';
                    if (data.is_finished) {
                        source_page += '<a class="popup-modal cancel_order_icon_btn" data-orderId="' + data.id + '" href="#test-modal"><i class="icon-remove-sign icon-2"></i></a>';
                    } else {
                        source_page += '<em class="pos">' + data.dish.pos + '</em>';
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

    function trimToLen(str, len) {
        var trimmedString = str.length > len ? str.substring(0, len - 3) + "..." : str + new Array(len - str.length).join(' ');
        return trimmedString;
    }
    window.chooseCategory = function(object) {
        var chosenCat = $(object);
        var catButton = $('.cat-dropDown-btn');
        var dishButton = $('.dish-dropDown-btn');
        catButton.val(trimToLen($.trim(chosenCat.html()), 20));
        window.chosenCatId = chosenCat.attr("data-categoryId");
        dishButton.attr("data-dropdown", dishButton.attr("data-dropdown").substring(0, 28) + window.chosenCatId);
    };
    window.chooseDish = function(object) {
        var chosenDish = $(object);
        var dishButton = $('.dish-dropDown-btn');
        dishButton.val(trimToLen($.trim(chosenDish.html()), 15));
        window.chosenDishId = chosenDish.attr("data-dishId");
    };
    //for cancel an order in popup
    window.incrementQuantityForOrder = function(object) {
        var plus_icon_clicked = $(object);
        var order_id = plus_icon_clicked.attr("data-orderId");
        var popup_order_container = $("#popup-order-container-" + order_id);
        var quantity_element = popup_order_container.find(".quantity");
        var page_order_container = $("#page-order-container-" + order_id);
        var quantity = parseInt(quantity_element.html(), 10);
        var req_data = {
            "csrfmiddlewaretoken": csrftoken,
            "order_id": order_id,
            "new_quant": quantity + 1
        };
        $.post(STAFF_API_URLS["order_update"], req_data).done(function(data) {
            if (data.quantity >= 1) {
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
            "csrfmiddlewaretoken": csrftoken,
            "order_id": order_id,
            "new_quant": quantity - 1
        };
        $.post(STAFF_API_URLS["order_update"], req_data).done(function(data) {
            if (data.quantity >= 1) {
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
    $(document).on('click', '.popup-modal-dismiss', function(e) {
        e.preventDefault();
        $.magnificPopup.close();
    });
    $(document).on('click', '.popup-modal-ok', function(e) {
        e.preventDefault();
        $.magnificPopup.close();
        var order_li_obj = $("#page-order-container-" + order_to_modify);
        var order_li_num_obj = order_li_obj.find("em").first();
        var quantity = parseInt(order_li_obj.find(".quantity").html(), 10);
        var req_data = {
            "csrfmiddlewaretoken": csrftoken,
            "order_id": order_to_modify,
            "new_quant": quantity - 1
        };
        $.post(STAFF_API_URLS["order_update"], req_data).done(function(data) {
            if (data.quantity >= 1) {
                order_li_num_obj.html(data.quantity + "x");
            } else {
                order_li_obj.remove();
            }
        }).fail(function(data) {
            console.log("order update failed");
        });
    });
});