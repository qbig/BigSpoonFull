//
//  ProfileViewController.h
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 27/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "HomeAndSettingsButtonView.h"
#import "User.h"
#import "Constants.h"
#import <AFHTTPRequestOperationManager.h>
#import "SSKeychain.h"
#import "TestFlight.h"

@interface ProfileViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) HomeAndSettingsButtonView *topRightButtonsView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UITextView *favoriteItemsTextView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *allergiesTextField;
@property (weak, nonatomic) IBOutlet UIButton *isVegetarianButton;

- (IBAction)toggleIsVegetarianDisplay:(UIButton *)sender;
- (IBAction)logout:(id)sender;

@end
