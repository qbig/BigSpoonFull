//
//  BigSpoonAnimationController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 14/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//


#import "BigSpoonAnimationController.h"

@implementation BigSpoonAnimationController
#pragma makr Animation

+ (void) animateTransitionOfUIView: (UIView *)view willShow: (BOOL) willShow{
    
    // view.alpha: how transparent it is. If 0, it still occupy its space on the screen
    // view.hidden: whether it is shown. If no, it will not occupy its space on the screen
    
    // Set the alpha to the other way. And set it back in the animation.
    if (willShow) {
        view.alpha = 0;
    } else{
        view.alpha = 1;
    }
    
    if (willShow) {
        [view setHidden: !willShow];
    }
    [UIView animateWithDuration:REQUEST_CONTROL_PANEL_TRANSITION_DURATION
                     animations:^{
                         if (willShow) {
                             view.alpha = 1;
                         } else{
                             view.alpha = 0;
                         }
                     }
                     completion:^(BOOL finished){
                         if (!willShow) {
                             [view setHidden: !willShow];
                         }
                     }];
}

+ (void) animateBadgeAfterUpdate: (UIView *)badgeView withOriginalFrame: (CGRect) oldFrameItemBadge{
    // newFrame is frame With Same Center And Zoomed width and height
    CGRect newFrame = CGRectMake(oldFrameItemBadge.origin.x -
                                 oldFrameItemBadge.size.width * (BADGE_ANMINATION_ZOOM_FACTOR - 1) / 2,
                                 oldFrameItemBadge.origin.y -
                                 oldFrameItemBadge.size.height * (BADGE_ANMINATION_ZOOM_FACTOR - 1) / 2,
                                 oldFrameItemBadge.size.width * BADGE_ANMINATION_ZOOM_FACTOR,
                                 oldFrameItemBadge.size.height * BADGE_ANMINATION_ZOOM_FACTOR);
    
    [UIView animateWithDuration:BADGE_ANMINATION_DURATION / 2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         badgeView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:BADGE_ANMINATION_DURATION / 2 animations:^{
                             badgeView.frame = oldFrameItemBadge;
                         }];
                     }];

}

+ (void) animateButtonWhenClicked:(UIView *)view{
        
    [UIView animateWithDuration:BUTTON_CLICK_ANIMATION_DURATION
                          delay:0
                        options: UIViewAnimationOptionAutoreverse
                     animations:^{
                         view.alpha = BUTTON_CLICK_ANIMATION_ALPHA;
                     }
                     completion:^(BOOL finished){
                         view.alpha = 1;
                     }];

    
}

+ (void) animateRequestButtonWhenClicked: (UIView*) view{
    [view setHidden: NO];
    
    // For some weired reason, cannot use auto-reverse here,
    // because that will conflict with the alertView and make the view blink
    
    [UIView animateWithDuration:BUTTON_CLICK_ANIMATION_DURATION
                          delay:0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         view.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:BUTTON_CLICK_ANIMATION_DURATION
                                               delay:0
                                             options: UIViewAnimationOptionAllowAnimatedContent
                                          animations:^{
                                              view.alpha = 0.2;
                                          }
                                          completion:^(BOOL finished){
                                              [view setHidden:YES];
                                          }];
                     
                     }];
    
}

@end
