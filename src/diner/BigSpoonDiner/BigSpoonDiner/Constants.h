//
//  Constants.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 22/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

// Request URLs:

extern NSString* const BASE_URL;
extern NSString* const  USER_SIGNUP;
extern NSString* const  USER_LOGIN;
extern NSString* const  USER_LOGIN_WITH_FB;
extern NSString* const  LIST_OUTLETS;
extern NSString* const REQUEST_URL;
extern NSString* const PROFILE_URL;
extern NSString* const ORDER_URL;
extern NSString* const BILL_URL;
extern NSString* const RATING_URL;
extern NSString* const FEEDBACK_URL;
extern NSString* const DISH_CATEGORY_URL;
extern NSString* const ORDER_HISTORY_URL;
extern NSString* const SOCKET_URL;
extern NSString* const KEY_FOR_SHOW_TUT_DEFAULT;
extern int const SOCKET_PORT;

// Dimentions (length, height, etc..):

extern int const ROW_HEIGHT_LIST_MENU;
extern int const ROW_HEIGHT_PHOTO_MENU;
extern double const SCALE_OF_BUTTON;
extern int const ITEM_LIST_SCROLL_WIDTH;
extern int const ITEM_LIST_SCROLL_HEIGHT;
extern int const CATEGORY_BUTTON_SCROLL_WIDTH;
extern int const ITEM_LIST_TABLE_ROW_HEIGHT;
extern int const ITEM_LIST_TABLE_ROW_HEIGHT_EXPANDED;
extern int const ORDERED_ITEM_LIST_TABLE_ROW_HEIGHT;
extern int const ITEM_LIST_TABLE_INITIAL_HEIGHT;
extern int const RATING_STAR_WIDTH;
extern int const RATING_STAR_HEIGHT;
extern int const AVERAGE_PIXEL_PER_CHAR;
extern int const CATEGORY_BUTTON_OFFSET;
extern int const CATEGORY_BUTTON_BORDER_WIDTH;
extern int const OFFSET_FOR_KEYBOARD;
extern int const OFFSET_FOR_KEYBOARD_SIGN_UP;
extern int const HEIGHT_REQUEST_BAR;
extern int const HEIGHT_NAVIGATION_BAR;
extern float const IPHONE_4_INCH_HEIGHT;
extern float const IPHONE_35_INCH_HEIGHT;
extern int const IPHONE_4_INCH_TABLE_VIEW_OFFSET;
extern int const IPHONE_35_INCH_TABLE_VIEW_OFFSET;
extern int const ORDER_ITEM_VIEW_WIDTH;
extern int const ORDER_ITEM_VIEW_HEIGHT;
extern int const ORDER_CONFIRM_ALERT_MAXIUM_HEIGHT;
extern int const ORDER_CONFIRM_ALERT_TITLE_HEIGHT;
extern int const HISTORY_DETAIL_SCROLLING_EXTRA;
// Colours

extern float const CATEGORY_BUTTON_COLOR_RED;
extern float const CATEGORY_BUTTON_COLOR_GREEN;
extern float const CATEGORY_BUTTON_COLOR_BLUE;

// Animations

extern double const BADGE_ANMINATION_DURATION;
extern double const BADGE_ANMINATION_ZOOM_FACTOR;
extern double const REQUEST_CONTROL_PANEL_TRANSITION_DURATION;
extern double const BUTTON_CLICK_ANIMATION_DURATION;
extern double const BUTTON_CLICK_ANIMATION_ALPHA;
extern double const KEYBOARD_APPEARING_DURATION;
extern double const TOAST_VIEW_DURATION;

// Fonts:

extern double const CATEGORY_BUTTON_FONT;


// Texts:
extern NSString* const ENABLE_LOCATION_ALERT_TITLE;
extern NSString* const ENABLE_LOCATION_ALERT;

extern NSString* const CANNOT_DETECT_LOCATION_ALERT_TITLE;
extern NSString* const CANNOT_DETECT_LOCATION_ALERT;


// SocketIO Message Token:
extern NSString* const SOCKET_IO_TOKEN_BILL_CLOSED;

// Others:

extern int const NUM_OF_RATINGS;
extern int const MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM;
extern double const LOCATION_CHECKING_DIAMETER;
extern double const LONGEST_NETWORK_WAITING_TIME;
extern NSString* const OUTLET_ID_PREFIX;
extern NSString* const OUTLET_INFO_FOR_ID_PREFIX;
extern NSString* const FB_SESSION_IS_OPEN;
extern NSString* const FB_TOKEN_VERIFIED;
extern NSString* const FEEDBACK_TEXT_PLACEHOLDER;
extern NSString* const DISH_OVERLAY_NORMAL;
extern NSString* const DISH_OVERLAY_OUT_OF_STOCK;
extern NSString* const DISH_MODIFIER_TYPE_COUNT;
extern NSString* const DISH_MODIFIER_TYPE_RADIO;

// Notification Name
extern NSString* const NOTIF_NEW_DISH_INFO_RETRIEVED;
extern NSString* const NOTIF_NEW_DISH_INFO_FAILED;
extern NSString* const NOTIF_ORDER_UPDATE;
extern NSString* const NOTIF_SHOULD_ASK_LOCATION_PERMIT_NOT;
extern NSString* const SHOW_NOTE;
extern NSString* const HIDE_NOTE;

// Dictionary keys:
extern NSString* const BIGSPOON_SSKEYCHAIN_NAME;
extern NSString* const EMAIL_USER_INFO_KEY;
extern NSString* const FIRSTNAME_USER_INFO_KEY;
extern NSString* const LASTNAME_USER_INFO_KEY;
extern NSString* const PROFILE_PHOTO_URL_USER_INFO_KEY;
@end
