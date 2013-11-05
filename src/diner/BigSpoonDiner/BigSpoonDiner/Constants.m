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


// Dimentions:

int const ROW_HEIGHT_LIST_MENU = 59;
int const ROW_HEIGHT_PHOTO_MENU = 196;
int const HEIGHT_NAVIGATION_ITEM = 63;
double const SCALE_OF_BUTTON = 2.85;
int const ITEM_LIST_SCROLL_WIDTH = 320;
int const ITEM_LIST_SCROLL_HEIGHT = 1100;

// Animations:
double const BADGE_ANMINATION_DURATION = 0.3;
double const BADGE_ANMINATION_ZOOM_FACTOR = 1.5;

// Others:
int const MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM = 15;

@end
