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
#import "TestFlight.h"
#import <Mixpanel.h>
#import "EAIntroView.h"

@interface LoginViewController : UIViewController <EAIntroDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *fbButton;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) EAIntroView *intro;

- (IBAction)fbButtonPressed:(id)sender;

@end
