//
//  DiningSession.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 20/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface DiningSession : NSObject
@property (nonatomic, strong) NSMutableDictionary *dictForCurrentOrders;
@property (nonatomic, strong) NSMutableDictionary *dictForPastOrders;
@property (nonatomic, strong) NSString *currentOutletName;

- (void) switchToOutlet: (NSString*) outletName;
- (Order *) getCurrentOrderWithOutletName: (NSString*) currentOutletName;
- (Order *) getPastOrderWithOutletName: (NSString *) currentOutletName;
- (Order *) getCurrentOrder;
- (Order *) getPastOrder;
- (void) setCurrentOrder:(Order *)currentOrder;
- (void) setPastOrder:(Order *)pastOrder;
- (void) clearCurrentOrder;
- (void) clearPastOrder;
@end
