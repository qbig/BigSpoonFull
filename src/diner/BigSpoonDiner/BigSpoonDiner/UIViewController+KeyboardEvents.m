//
//  UIViewController+KeyboardEvents.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 19/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "UIViewController+KeyboardEvents.h"

@implementation UIViewController (KeyboardEvents)

#pragma mark - Keybaord Events

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: KEYBOARD_APPEARING_DURATION]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= OFFSET_FOR_KEYBOARD;
        rect.size.height += OFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += OFFSET_FOR_KEYBOARD;
        rect.size.height -= OFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
