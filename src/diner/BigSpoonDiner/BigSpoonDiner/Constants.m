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
NSString* const LIST_OUTLETS = @"http://122.248.199.242/api/v1/outlets";
NSString* const REQUEST_URL = @"http://122.248.199.242/api/v1/request";
NSString* const PROFILE_URL = @"http://122.248.199.242/api/v1/profile";
NSString* const ORDER_URL = @"http://122.248.199.242/api/v1/meal";
NSString* const BILL_URL = @"http://122.248.199.242/api/v1/askbill";
NSString* const RATING_URL = @"http://122.248.199.242/api/v1/rating";
NSString* const FEEDBACK_URL = @"http://122.248.199.242/api/v1/review";
NSString* const DISH_CATEGORY_URL = @"http://122.248.199.242/api/v1/categories";

// Dimentions:

int const ROW_HEIGHT_LIST_MENU = 59;
int const ROW_HEIGHT_PHOTO_MENU = 196;
double const SCALE_OF_BUTTON = 2.85;
int const ITEM_LIST_SCROLL_WIDTH = 320;
int const ITEM_LIST_SCROLL_HEIGHT = 1100;
int const ITEM_LIST_TABLE_ROW_HEIGHT = 59;
int const ITEM_LIST_TABLE_INITIAL_HEIGHT = 192;
int const RATING_STAR_WIDTH = 80;
int const RATING_STAR_HEIGHT = 15;
int const AVERAGE_PIXEL_PER_CHAR = 8;
int const CATEGORY_BUTTON_OFFSET = 5;
int const CATEGORY_BUTTON_BORDER_WIDTH = 1;

// Coordinates:

int const REQUEST_WATER_VIEW_X = 40;
int const REQUEST_WATER_VIEW_Y = 150;
int const RATING_AND_FEEDBACK_X = 18;
int const RATING_AND_FEEDBACK_Y = 70;

// Animations:

double const BADGE_ANMINATION_DURATION = 0.4;
double const BADGE_ANMINATION_ZOOM_FACTOR = 2.1;
double const REQUEST_CONTROL_PANEL_TRANSITION_DURATION = 0.6;
double const BUTTON_CLICK_ANIMATION_DURATION = 0.15;
double const BUTTON_CLICK_ANIMATION_ALPHA = 0.45;

// Others:

int const NUM_OF_RATINGS = 5;
int const MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM = 15;

@end
