//
//  RatingAndFeedbackViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingAndFeedbackViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *ratingsTableView;
@property (strong, nonatomic) IBOutlet UITextField *feedbackTextField;
- (IBAction)ratingSubmitButtonPressed:(id)sender;
- (IBAction)ratingCancelButtonPressed:(id)sender;

- (IBAction)textFieldDidEndOnExit:(id)sender;


@end
