//
//  ExitMenuListDelegate.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 3/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@protocol ExitMenuListDelegate <NSObject>

- (void) exitMenuListWithCurrentOrder: (Order *) currentOrder PastOrder: (Order *) pastOrder andOutletID: (int) outletID;

@end
