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

// Others:
int const MAX_NUMBER_OF_TRIAL_RECONNECT = 3;

@end
