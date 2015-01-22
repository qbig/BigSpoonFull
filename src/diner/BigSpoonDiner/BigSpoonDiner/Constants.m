//
//  Constants.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 22/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Constants.h"

@implementation Constants

// Request URLs:
//#define DEV  0;
#ifdef DEV
//NSString* const BASE_URL = @"http://46.137.234.248/";
//NSString* const USER_SIGNUP = @"http://46.137.234.248/api/v1/user";
//NSString* const USER_LOGIN = @"http://46.137.234.248/api/v1/login";
//NSString* const USER_LOGIN_WITH_FB = @"http://46.137.234.248/api/v1/fblogin";
//NSString* const LIST_OUTLETS = @"http://46.137.234.248/api/v1/outlets";
//NSString* const REQUEST_URL = @"http://46.137.234.248/api/v1/request";
//NSString* const PROFILE_URL = @"http://46.137.234.248/api/v1/profile";
//NSString* const ORDER_URL = @"http://46.137.234.248/api/v1/meal";
//NSString* const BILL_URL = @"http://46.137.234.248/api/v1/askbill";
//NSString* const RATING_URL = @"http://46.137.234.248/api/v1/rating";
//NSString* const FEEDBACK_URL = @"http://46.137.234.248/api/v1/review";
//NSString* const DISH_CATEGORY_URL = @"http://46.137.234.248/api/v1/categories";
//NSString* const ORDER_HISTORY_URL = @"http://46.137.234.248/api/v1/mealhistory";
//NSString* const SOCKET_URL = @"46.137.234.248";

NSString* const BASE_URL = @"http://175.41.178.102/";
NSString* const USER_SIGNUP = @"http://175.41.178.102/api/v1/user";
NSString* const USER_LOGIN = @"http://175.41.178.102/api/v1/login";
NSString* const USER_LOGIN_WITH_FB = @"http://175.41.178.102/api/v1/fblogin";
NSString* const LIST_OUTLETS = @"http://175.41.178.102/api/v1/outlets";
NSString* const REQUEST_URL = @"http://175.41.178.102/api/v1/request";
NSString* const PROFILE_URL = @"http://175.41.178.102/api/v1/profile";
NSString* const ORDER_URL = @"http://175.41.178.102/api/v1/meal";
NSString* const BILL_URL = @"http://175.41.178.102/api/v1/askbill";
NSString* const RATING_URL = @"http://175.41.178.102/api/v1/rating";
NSString* const FEEDBACK_URL = @"http://175.41.178.102/api/v1/review";
NSString* const DISH_CATEGORY_URL = @"http://175.41.178.102/api/v1/categories";
NSString* const ORDER_HISTORY_URL = @"http://175.41.178.102/api/v1/mealhistory";
NSString* const SOCKET_URL = @"175.41.178.102";

#else
NSString* const BASE_URL = @"http://bigspoon.biz/"; //NSString* const BASE_URL = @"http://46.137.234.248/";
NSString* const USER_SIGNUP = @"http://bigspoon.biz/api/v1/user";
NSString* const USER_LOGIN = @"http://bigspoon.biz/api/v1/login";
NSString* const USER_LOGIN_WITH_FB = @"http://bigspoon.biz/api/v1/fblogin";
NSString* const LIST_OUTLETS = @"http://bigspoon.biz/api/v1/outlets";
NSString* const REQUEST_URL = @"http://bigspoon.biz/api/v1/request";
NSString* const PROFILE_URL = @"http://bigspoon.biz/api/v1/profile";
NSString* const ORDER_URL = @"http://bigspoon.biz/api/v1/meal";
NSString* const BILL_URL = @"http://bigspoon.biz/api/v1/askbill";
NSString* const RATING_URL = @"http://bigspoon.biz/api/v1/rating";
NSString* const FEEDBACK_URL = @"http://bigspoon.biz/api/v1/review";
NSString* const DISH_CATEGORY_URL = @"http://bigspoon.biz/api/v1/categories";
NSString* const ORDER_HISTORY_URL = @"http://bigspoon.biz/api/v1/mealhistory";
NSString* const SOCKET_URL = @"bigspoon.biz";

#endif


NSString* const KEY_FOR_SHOW_TUT_DEFAULT = @"hasShownTutorial";
int const SOCKET_PORT = 8000;
NSString * const BG_DEFAULT_DISH_PHOTO_URL = @"media/restaurant/dishes/default.jpg";
// Dimensions:

int const ROW_HEIGHT_LIST_MENU = 69;
int const ROW_HEIGHT_PHOTO_MENU = 210;
double const SCALE_OF_BUTTON = 2.85;
int const ITEM_LIST_SCROLL_WIDTH = 320;
int const ITEM_LIST_SCROLL_HEIGHT = 900;
int const CATEGORY_BUTTON_SCROLL_WIDTH = 20;
int const ITEM_LIST_TABLE_ROW_HEIGHT = 46;
int const ITEM_LIST_ADD_NOTE_TEXT_FIELD_HEIGHT = 40;
int const ORDERED_ITEM_LIST_TABLE_ROW_HEIGHT = 44;
int const ITEM_LIST_TABLE_INITIAL_HEIGHT = 192;
int const RATING_STAR_WIDTH = 127;
int const RATING_STAR_HEIGHT = 15;
int const AVERAGE_PIXEL_PER_CHAR = 8;
int const CATEGORY_BUTTON_OFFSET = 5;
int const CATEGORY_BUTTON_BORDER_WIDTH = 1;
int const OFFSET_FOR_KEYBOARD = 152;
int const OFFSET_FOR_KEYBOARD_SIGN_UP = 240;
int const HEIGHT_REQUEST_BAR = 60;
int const HEIGHT_NAVIGATION_BAR = 0;
float const IPHONE_4_INCH_HEIGHT = 568.0;
float const IPHONE_35_INCH_HEIGHT = 480.0;
int const IPHONE_4_INCH_TABLE_VIEW_OFFSET = 45;
int const IPHONE_35_INCH_TABLE_VIEW_OFFSET = 133;
int const ORDER_ITEM_VIEW_HEIGHT = 21;
int const ORDER_ITEM_VIEW_WIDTH = 280;
int const ORDER_CONFIRM_ALERT_MAXIUM_HEIGHT = 280;
int const ORDER_CONFIRM_ALERT_TITLE_HEIGHT = 30;
int const HISTORY_DETAIL_SCROLLING_EXTRA = 380;
int const ITEM_PAGE_EMPTY_CURRENT_ORDER_OFFSET = 310;

// Colours

float const CATEGORY_BUTTON_COLOR_RED = 118 / 256.0;
float const CATEGORY_BUTTON_COLOR_GREEN = 225 / 256.0;
float const CATEGORY_BUTTON_COLOR_BLUE = 222 / 256.0;

// Animations:

double const BADGE_ANMINATION_DURATION = 0.4;
double const BADGE_ANMINATION_ZOOM_FACTOR = 2.1;
double const REQUEST_CONTROL_PANEL_TRANSITION_DURATION = 0.6;
double const BUTTON_CLICK_ANIMATION_DURATION = 0.15;
double const BUTTON_CLICK_ANIMATION_ALPHA = 0.45;
double const KEYBOARD_APPEARING_DURATION = 0.3;
double const TOAST_VIEW_DURATION = 5;
double const TOAST_VIEW_DURATION_SHORT = 2;


// Fonts:

double const CATEGORY_BUTTON_FONT = 19.0;

// Texts:
NSString* const ENABLE_LOCATION_ALERT_TITLE = @"One more thing" ;
NSString* const ENABLE_LOCATION_ALERT = @"BigSpoon requires your location to send orders. \nEnable BigSpoon in iPhone's Settings>Privacy>Location services" ;

NSString* const CANNOT_DETECT_LOCATION_ALERT_TITLE = @"BigSpoon couldn't find you" ;
NSString* const CANNOT_DETECT_LOCATION_ALERT = @"Orders can only be sent when you are at the restaurant.\nIf you are already there, kindly speak to the friendly waiter for your orders. ";


// Dictionary keys:
NSString* const BIGSPOON_SSKEYCHAIN_NAME = @"BigSpoon";
NSString* const EMAIL_USER_INFO_KEY = @"email";
NSString* const FIRSTNAME_USER_INFO_KEY = @"firstName";
NSString* const LASTNAME_USER_INFO_KEY = @"lastName";
NSString* const PROFILE_PHOTO_URL_USER_INFO_KEY = @"profilePhotoURL";
NSString* const PREVIOUS_LOGIN_EMAIL=@"previousLoginEmail";


// SocketIO Message Token:
NSString* const SOCKET_IO_TOKEN_BILL_CLOSED = @"bill has been closed";

// Others:

int const NUM_OF_RATINGS = 5;
int const MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM = 15;
double const LOCATION_CHECKING_DIAMETER = 300;
double const LONGEST_NETWORK_WAITING_TIME = 3.0;
double const LOCATION_FILTER_DISTANCE_100KM = 100000;
NSString* const OUTLET_ID_PREFIX = @"outlet";
NSString* const OUTLET_INFO_FOR_ID_PREFIX = @"outletWithId";
NSString* const FB_SESSION_IS_OPEN = @"FBSessionIsOpen";
NSString* const FB_TOKEN_VERIFIED = @"FBTokenIsVerified";
NSString* const EMAIL_LOGIN_SUCCESS = @"emailLoginSuccess";
NSString* const FEEDBACK_TEXT_PLACEHOLDER = @"Your feedback here...";
NSString* const DISH_OVERLAY_NORMAL = @"black-overlay.png";
NSString* const DISH_OVERLAY_OUT_OF_STOCK = @"out_of_stock.png";
NSString* const DISH_MODIFIER_TYPE_COUNT = @"count";
NSString* const DISH_MODIFIER_TYPE_RADIO = @"radio";
NSString* const USER_FEEDBACK_TEXT_PLACEHOLDER = @"Your feedback here...";


// Notification
NSString* const NOTIF_NEW_DISH_INFO_RETRIEVED = @"RetrievedNewDishesAndTableInfo";
NSString* const NOTIF_NEW_DISH_INFO_FAILED = @"DishAndTableRequestNetworkFailure";
NSString* const NOTIF_FB_LOGIN_FAILED = @"fbLoginFailed";
NSString* const NOTIF_ORDER_UPDATE = @"OrderUpdated";
NSString* const NOTIF_SHOULD_ASK_LOCATION_PERMIT_NOT = @"ShouldAskLocationPermitNow";
NSString* const SHOW_NOTE = @"showNote";
NSString* const HIDE_NOTE = @"hideNote";

@end
