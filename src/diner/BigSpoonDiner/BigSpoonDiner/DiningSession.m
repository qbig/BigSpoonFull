//
//  DiningSession.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 20/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import "DiningSession.h"

@implementation DiningSession

- (id) init{
    self = [super init];
    if (self) {
        self.dictForCurrentOrders = [[NSMutableDictionary alloc] init];
        self.dictForPastOrders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) switchToOutlet: (NSString*) outletName {
    self.currentOutletName = outletName;
}

- (Order *) getCurrentOrderWithOutletName: (NSString*) currentOutletName {
    self.currentOutletName = currentOutletName;
    if ([self.dictForCurrentOrders objectForKey:currentOutletName]){
        return (Order *) [self.dictForCurrentOrders objectForKey:currentOutletName];
    } else {
        Order *newOrder = [[Order alloc] init];
        [self.dictForCurrentOrders setObject:newOrder forKey:currentOutletName];
        return newOrder;
    }
}

- (Order *) getPastOrderWithOutletName: (NSString *) currentOutletName {
    self.currentOutletName = currentOutletName;
    if ([self.dictForPastOrders objectForKey:currentOutletName]){
        return (Order *) [self.dictForPastOrders objectForKey:currentOutletName];
    } else {
        Order *newPastOrder = [[Order alloc] init];
        [self.dictForPastOrders setObject:newPastOrder forKey:currentOutletName];
        return newPastOrder;
    }
}

- (Order *) getCurrentOrder {
    return [self getCurrentOrderWithOutletName:self.currentOutletName];
}

- (Order *) getPastOrder {
    return [self getPastOrderWithOutletName:self.currentOutletName];
}

- (void) setCurrentOrder:(Order *)currentOrder {
    [self.dictForCurrentOrders setObject:currentOrder forKey:self.currentOutletName];
}

- (void) setPastOrder:(Order *)pastOrder {
    [self.dictForPastOrders setObject:pastOrder forKey:self.currentOutletName];
}

- (void) clearCurrentOrder {
    [self setCurrentOrder: [[Order alloc] init]];
}

- (void) clearPastOrder {
    [self setPastOrder: [[Order alloc] init]];
}

@end
