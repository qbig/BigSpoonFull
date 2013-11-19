//
//  UIViewController+KeyboardEvents.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 19/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface UIViewController (KeyboardEvents)

// Usage:

// Define these metnods in the ViewController:
//
// Bind the textField action to them:
//
// Edit Did Begin ==> textFieldDidBeginEditing
// Editing Did End ==> textFinishEditing
// Did End on Exit (this is when user press "return" button) ==> textFinishEditing

 /*
- (IBAction)textFieldDidBeginEditing:(id)sender {
    
    //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
}

- (IBAction)textFinishEditing:(id)sender {
    
    [sender resignFirstResponder];
    
    //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}
  
*/

-(void)setViewMovedUp:(BOOL)movedUp;

@end
