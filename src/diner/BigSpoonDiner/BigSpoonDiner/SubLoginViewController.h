//
//  SubLoginViewController.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 25/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+KeyboardEvents.h"
#import <Mixpanel.h>
#import "TestFlight.h"
#import "User.h"
#import "SSKeychain.h"

@interface SubLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
- (IBAction)loginButtonPressed:(id)sender;
@end
