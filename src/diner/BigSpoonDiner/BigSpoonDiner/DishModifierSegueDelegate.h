//
//  DishModifierSegueDelegate.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dish.h"

@protocol DishModifierSegueDelegate <NSObject>
- (void) dishModifierPopupDidSaveWithUpdatedModifier: (Dish *) newDishWithModifier;
- (void) dishModifierPopupDidCancel;
@end
