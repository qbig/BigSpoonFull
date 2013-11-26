//
//  LoginViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "User.h"
#import "SSKeychain.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *emailLabel;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *fbButton;
@property (strong, nonatomic) IBOutlet UIView *mainView;

- (IBAction)submitButtonPressed:(id)sender;

- (IBAction)fbButtonPressed:(id)sender;

@end
