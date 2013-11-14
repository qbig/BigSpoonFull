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
#import "RatingCell.h"

@interface RatingAndFeedbackViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// Key: dishID; Value: rating between 0 to 5.
@property (strong, nonatomic) NSMutableDictionary *ratings;

@property (strong, nonatomic) Order* currentOrder;
@property (strong, nonatomic) IBOutlet UITableView *ratingsTableView;
@property (strong, nonatomic) IBOutlet UITextField *feedbackTextField;
@property (strong, nonatomic) IBOutlet UIImageView *ratingImage;


- (IBAction)ratingSubmitButtonPressed:(id)sender;
- (IBAction)ratingCancelButtonPressed:(id)sender;
- (IBAction)textFieldDidEndOnExit:(id)sender;

- (void) reloadDataWithOrder: (Order *) currentOrder;



@end
