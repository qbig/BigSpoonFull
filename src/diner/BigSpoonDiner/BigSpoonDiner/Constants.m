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
NSString* const ORDER_URL = @"http://122.248.199.242/api/v1/meal";


// Others:
int const ROW_HEIGHT_LIST_MENU = 59;
int const ROW_HEIGHT_PHOTO_MENU = 186;

@end
