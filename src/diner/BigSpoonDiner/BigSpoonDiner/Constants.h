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
extern NSString* const  LIST_OUTLETS;
extern NSString* const REQUEST_URL;
extern NSString* const PROFILE_URL;
extern NSString* const ORDER_URL;
extern NSString* const BILL_URL;


// Dimentions (length, height, etc..):

extern int const ROW_HEIGHT_LIST_MENU;
extern int const ROW_HEIGHT_PHOTO_MENU;
extern int const HEIGHT_NAVIGATION_ITEM;
extern double const SCALE_OF_BUTTON;

// Others:
extern int const MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM;

@end
