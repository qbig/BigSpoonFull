//
//  MenuViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuViewController;

@protocol MenuViewControllerDelegate <NSObject>
- (void)MenuViewControllerHomeButtonPressed: (MenuViewController *)controller;
@end

@interface MenuViewController : UIViewController


@property (nonatomic, weak) id <MenuViewControllerDelegate> delegate;

- (IBAction)homeButtonPressed:(id)sender;

@end
