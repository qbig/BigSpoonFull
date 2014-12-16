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
#import "EAIntroView.h"

@interface SubLoginViewController : UIViewController  <EAIntroDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) EAIntroView *intro;
- (IBAction)loginButtonPressed:(id)sender;
@end
