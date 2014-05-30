//
//  DishModifierItemCellRadio.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 29/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DishModifierItem.h"
#import "UIImage+Overlay.h"

typedef enum
{
    Unchecked = 0,
    Checked,
} radioCellState;

@interface DishModifierItemCellRadio : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedIndicatorImageview;
@property (weak, nonatomic) DishModifierItem *item;
@property (weak, nonatomic) IBOutlet UIView *tapTransitionsOverlay;
@property (nonatomic) radioCellState cellState;
@property (nonatomic, strong) UIColor *selectorColor;

- (void) check;
- (void) uncheck;
- (radioCellState) toggle;
- (void) render;

- (void) tapTransition;
@end
