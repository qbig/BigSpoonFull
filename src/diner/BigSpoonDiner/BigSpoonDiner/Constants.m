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

NSString* const BASE_URL = @"http://122.248.199.242/";
NSString* const  USER_SIGNUP = @"http://122.248.199.242/api/v1/user";
NSString* const USER_LOGIN = @"http://122.248.199.242/api/v1/login";
NSString* const USER_LOGIN_WITH_FB = @"http://122.248.199.242/api/v1/fblogin";
NSString* const LIST_OUTLETS = @"http://122.248.199.242/api/v1/outlets";
NSString* const REQUEST_URL = @"http://122.248.199.242/api/v1/request";
NSString* const PROFILE_URL = @"http://122.248.199.242/api/v1/profile";
NSString* const ORDER_URL = @"http://122.248.199.242/api/v1/meal";
NSString* const BILL_URL = @"http://122.248.199.242/api/v1/askbill";
NSString* const RATING_URL = @"http://122.248.199.242/api/v1/rating";
NSString* const FEEDBACK_URL = @"http://122.248.199.242/api/v1/review";
NSString* const DISH_CATEGORY_URL = @"http://122.248.199.242/api/v1/categories";
NSString* const ORDER_HISTORY_URL = @"http://122.248.199.242/api/v1/mealhistory";
NSString* const SOCKET_URL = @"122.248.199.242";
int const SOCKET_PORT = 8000;

// Dimensions:

int const ROW_HEIGHT_LIST_MENU = 59;
int const ROW_HEIGHT_PHOTO_MENU = 280;
double const SCALE_OF_BUTTON = 2.85;
int const ITEM_LIST_SCROLL_WIDTH = 320;
int const ITEM_LIST_SCROLL_HEIGHT = 900;
int const CATEGORY_BUTTON_SCROLL_WIDTH = 20;
int const ITEM_LIST_TABLE_ROW_HEIGHT = 59;
int const ITEM_LIST_TABLE_INITIAL_HEIGHT = 192;
int const RATING_STAR_WIDTH = 80;
int const RATING_STAR_HEIGHT = 15;
int const AVERAGE_PIXEL_PER_CHAR = 8;
int const CATEGORY_BUTTON_OFFSET = 5;
int const CATEGORY_BUTTON_BORDER_WIDTH = 1;
int const OFFSET_FOR_KEYBOARD = 152;
int const OFFSET_FOR_KEYBOARD_SIGN_UP = 80;
int const HEIGHT_REQUEST_BAR = 60;
int const HEIGHT_NAVIGATION_BAR = 0;
float const IPHONE_4_INCH_HEIGHT = 568.0;
float const IPHONE_35_INCH_HEIGHT = 480.0;
int const IPHONE_4_INCH_TABLE_VIEW_OFFSET = 45;
int const IPHONE_35_INCH_TABLE_VIEW_OFFSET = 133;

// Colours

float const CATEGORY_BUTTON_COLOR_RED = 0 / 256.0;
float const CATEGORY_BUTTON_COLOR_GREEN = 135 / 256.0;
float const CATEGORY_BUTTON_COLOR_BLUE = 198 / 256.0;

// Animations:

double const BADGE_ANMINATION_DURATION = 0.4;
double const BADGE_ANMINATION_ZOOM_FACTOR = 2.1;
double const REQUEST_CONTROL_PANEL_TRANSITION_DURATION = 0.6;
double const BUTTON_CLICK_ANIMATION_DURATION = 0.15;
double const BUTTON_CLICK_ANIMATION_ALPHA = 0.45;
double const KEYBOARD_APPEARING_DURATION = 0.3;

// Fonts:

double const CATEGORY_BUTTON_FONT = 16.0;


// Others:

int const NUM_OF_RATINGS = 5;
int const MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM = 15;
double const LOCATION_CHECKING_DIAMETER = 100;

@end
