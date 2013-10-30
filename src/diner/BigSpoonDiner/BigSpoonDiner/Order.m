//
//  order.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 29/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Order.h"

@interface Order ()

@end

@implementation Order

#pragma mark Public Methods

- (id) init{
    self = [super init];
    if (self) {
        // Initialization code
        self.dishes = [[NSMutableArray alloc] init];
        self.quantity = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addDish: (Dish *) dish{
    // If added before, just update its index:
    if ([self.dishes containsObject:dish]) {
        
        int index = [self getIndexOfDish:dish];
        int quantity = [self getQuantityOfDish:dish];
        
        NSNumber *newQuantity = [NSNumber numberWithInt: quantity + 1];
        [self.quantity setObject:newQuantity atIndexedSubscript: index];
        
    }
    
    // If it's new, add it:
    else{
        [self.dishes addObject: dish];
        [self.quantity addObject: [NSNumber numberWithInt:1]];
    }
}

- (void) minusDish:(Dish *)dish{
    if ([self.dishes containsObject:dish]) {
        
        int index = [self getIndexOfDish:dish];
        int quantity = [self getQuantityOfDish:dish];
        NSNumber* quantityObject = [self getQuantityObjectOfDish:dish];
        
        // Still have more than one quantity, just decrease the number:
        if (quantity > 1) {
            NSNumber *newQuantity = [NSNumber numberWithInt: quantity - 1];
            [self.quantity setObject:newQuantity atIndexedSubscript: index];
        }
        
        // Have less than one quantity, if minus, becomes 0 quantity, so just remove it:
        else{
            [self.quantity removeObject: quantityObject];
            [self.dishes removeObject:dish];
        }
        
    }
}

- (int) getQuantityOfDish: (Dish *) dish{
    if ([self.dishes containsObject:dish]) {
        NSNumber *quantity = [self getQuantityObjectOfDish:dish];
        return quantity.integerValue;
    } else{
        return 0;
    }
}

- (int) getQuantityOfDishID: (int) dishID{
    
    // Iterate through the dishes:
    for (int i = 0; i < [self.dishes count]; i++) {
        Dish *dish = [self.dishes objectAtIndex:i];
        if (dish.ID == dishID) {
            NSNumber *quantity = [self getQuantityObjectOfDish:dish];
            return quantity.integerValue;
        }
    }
    
    // The dishID not found:
    return 0;
}

- (int) getTotalQuantity{
    int totalQuantity = 0;
    
    for (NSNumber *n in self.quantity) {
        totalQuantity += [n integerValue];
    }
    
    return totalQuantity;
}

- (int) getTotalPrice{
    int totalPrice = 0;
    for (int i = 0; i < [self.dishes count]; i++) {
        Dish *newDish = (Dish *)[self.dishes objectAtIndex:i];
        int quantity = [self getQuantityOfDish:newDish];
        
        totalPrice += newDish.price * quantity;
    }
    return totalPrice;
}

- (int) getNumberOfDishes{
    return [self.dishes count];
}


- (void) mergeWithAnotherOrder: (Order *)newOrder{
    for (int i = 0; i < [newOrder getNumberOfDishes]; i++) {
        Dish *newDish = (Dish *)[newOrder.dishes objectAtIndex:i];
        int newQuantity = [newOrder getQuantityOfDish:newDish];
        
        if ([self.dishes containsObject:newDish]) {
            
            int selfQuantity = [self getQuantityOfDish:newDish];
            int index = [self getIndexOfDish:newDish];
            
            NSNumber *numObject = [NSNumber numberWithInt: newQuantity + selfQuantity];
            [self.quantity setObject: numObject atIndexedSubscript:index];
            
        } else{
            
            [self.dishes addObject:newDish];
            NSNumber *newQuantityObject = [NSNumber numberWithInt:newQuantity];
            [self.quantity addObject:newQuantityObject];
            
        }
    }
}

#pragma mark Private Functions

- (NSNumber *) getQuantityObjectOfDish: (Dish *) dish{
    int index = [self getIndexOfDish:dish];
    return (NSNumber *)[self.quantity objectAtIndex: index];
}

- (int) getIndexOfDish: (Dish *) dish{
    return [self.dishes indexOfObject:dish];
}



@end
