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

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) HomeAndSettingsButtonView *topRightButtonsView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;

@end
