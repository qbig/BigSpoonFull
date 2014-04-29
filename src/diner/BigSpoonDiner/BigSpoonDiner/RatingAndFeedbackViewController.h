//
//  RatingAndFeedbackViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "Dish.h"
#import "User.h"
#import "RatingCell.h"
#import "Constants.h"
#import "BigSpoonAnimationController.h"
#import <AFHTTPRequestOperation.h>
#import "UIViewController+KeyboardEvents.h"
#import "TestFlight.h"
#import "Toast+UIView.h"
#import "ModalSegueDelegate.h"
#import "SubmitRatingAndFeedbackSuccessDelegate.h"

@interface RatingAndFeedbackViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>

// Key: dishID; Value: rating between 0 to 5.
@property (strong, nonatomic) NSMutableDictionary *ratings;

@property (strong, nonatomic) Order* orderToRate;
@property (nonatomic) int outletID;
@property (strong, nonatomic) IBOutlet UITableView *ratingsTableView;
@property (nonatomic) float initialY;
@property (weak, nonatomic) id <ModalSegueDelegate, SubmitRatingAndFeedbackSuccessDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *feedbackTextview;

- (IBAction)ratingSubmitButtonPressed:(id)sender;
- (IBAction)ratingCancelButtonPressed:(id)sender;

- (void) reloadDataWithOrder: (Order *) currentOrder andOutletID: (int) outletID;



@end
