//
//  RequestWaterViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 28/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestWaterViewController : UIViewController

@property (nonatomic) int quantityOfColdWater;
@property (nonatomic) int quantityOfWarmWater;

@property (strong, nonatomic) IBOutlet UIView *controlPanelView;


@property (strong, nonatomic) IBOutlet UILabel *quantityOfColdWaterLabel;
@property (strong, nonatomic) IBOutlet UILabel *quantityOfWarmWaterLabel;

- (IBAction)plusColdWaterPressed:(id)sender;
- (IBAction)minusColdWaterPressed:(id)sender;

- (IBAction)plusWarmWaterPressed:(id)sender;
- (IBAction)minusWarmWaterPressed:(id)sender;


- (IBAction)okayButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
