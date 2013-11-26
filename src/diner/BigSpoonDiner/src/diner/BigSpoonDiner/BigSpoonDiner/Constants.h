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
extern NSString* const RATING_URL;
extern NSString* const FEEDBACK_URL;
extern NSString* const DISH_CATEGORY_URL;
extern NSString* const ORDER_HISTORY_URL;
extern NSString* const SOCKET_URL;
extern int const SOCKET_PORT;

// Dimentions (length, height, etc..):

extern int const ROW_HEIGHT_LIST_MENU;
extern int const ROW_HEIGHT_PHOTO_MENU;
extern double const SCALE_OF_BUTTON;
extern int const ITEM_LIST_SCROLL_WIDTH;
extern int const ITEM_LIST_SCROLL_HEIGHT;
extern int const CATEGORY_BUTTON_SCROLL_WIDTH;
extern int const ITEM_LIST_TABLE_ROW_HEIGHT;
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

// Fonts:

extern double const CATEGORY_BUTTON_FONT;

// Others:

extern int const NUM_OF_RATINGS;
extern int const MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM;


@end
