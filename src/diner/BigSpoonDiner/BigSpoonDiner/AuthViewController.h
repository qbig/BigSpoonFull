//
//  AuthViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Constants.h"

@interface AuthViewController : UIViewController <NSURLConnectionDelegate>


@property (strong, nonatomic) IBOutlet UITextField *firstNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *lastNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailAddressLabel;
@property (strong, nonatomic) IBOutlet UITextField *passwordLabel;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;


- (IBAction)submitButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end
