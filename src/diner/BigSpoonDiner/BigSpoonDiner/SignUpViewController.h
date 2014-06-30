//
//  AuthViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mixpanel.h>
#import "User.h"
#import "Constants.h"
#import "SSKeychain.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIViewController+KeyboardEvents.h"
#import "TestFlight.h"

@interface SignUpViewController : UIViewController <NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UITextField *firstNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailAddressLabel;
@property (strong, nonatomic) IBOutlet UITextField *passwordLabel;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UILabel *signupLabel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)submitButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

- (IBAction)textFinishEditing:(id)sender;
- (IBAction)textFieldDidBeginEditing:(id)sender;

@end
