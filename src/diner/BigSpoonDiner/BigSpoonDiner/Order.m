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
        self.notes = [[NSMutableDictionary alloc] init];
        self.modifierAnswers = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void) addDish: (Dish *) dish{
    if (![self containsDishWithDishID:dish.ID] || dish.canBeCustomized) {
        [self.dishes addObject: dish];
        [self.quantity addObject: [NSNumber numberWithInt:1]];
        
        if ( dish.canBeCustomized){
            [self setModifierAnswer: [dish.customOrderInfo getAnswer] atIndex: [self.dishes count] - 1];
        }
    } else {
        // If added before, just update its index:
        int index = [self getIndexOfDishByDish:dish];
        int quantity = [self getQuantityOfDishByDish:dish];
        [self.quantity setObject:[NSNumber numberWithInt: quantity + 1] atIndexedSubscript: index];
    }
}

- (void) incrementDishWithId: (int)dishId {
    int index = [self getIndexOfDishByDishID:dishId];
    int quantity = [self getQuantityOfDishByID:dishId];
    [self.quantity setObject:[NSNumber numberWithInt: quantity + 1] atIndexedSubscript: index];
}

- (void) decrementDishWithId: (int)dishId {
    int index = [self getIndexOfDishByDishID:dishId];
    int quantity = [self getQuantityOfDishByID:dishId];
    if(quantity > 1){
        [self.quantity setObject:[NSNumber numberWithInt: quantity - 1] atIndexedSubscript: index];
    } else if (quantity == 1){
        [self removeDishWithID:dishId];
    }
}

- (void) incrementDishAtIndex: (int)dishIndex {
    int quantity = [[self.quantity objectAtIndex:dishIndex] intValue];
    [self.quantity setObject:[NSNumber numberWithInt: quantity + 1] atIndexedSubscript: dishIndex];
}

- (void) decrementDishAtIndex: (int)dishIndex {
    int quantity = [[self.quantity objectAtIndex:dishIndex] intValue];
    if(quantity > 1){
        [self.quantity setObject:[NSNumber numberWithInt: quantity - 1] atIndexedSubscript: dishIndex];
    } else if (quantity == 1){
        [self removeDishAtIndex: dishIndex];
    }
}

- (NSString *) getModifierDetailsTextAtIndex: (int) dishIndex{
    Dish *targetingDish = (Dish *) [self.dishes objectAtIndex: dishIndex];
    if (! targetingDish.canBeCustomized){
        return @"";
    } else {
        DishModifier *modifierForDish = targetingDish.customOrderInfo;
        [modifierForDish setAnswer: [self getModifierAnswerAtIndex:dishIndex]];
        return [modifierForDish getDetailsText];
    }
}

- (NSDictionary *) getMergedTextForNotesAndModifier {
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
    for(NSString *key in self.notes){
        [result setObject:self.notes[key] forKey: key];
    }
    
    for(NSString *key in self.modifierAnswers){
        int dishIndex = [key integerValue];
        Dish *dish = [self.dishes objectAtIndex:dishIndex];
        [dish.customOrderInfo setAnswer: self.modifierAnswers[key]];
        NSString *answerText = [dish.customOrderInfo getDetailsText];
        if (self.notes[key]){
            [result setObject:[NSString stringWithFormat: @"%@\nnote:%@", answerText, self.notes[key]] forKey:key];
        } else {
            result[key] = answerText;
        }
    }
    
    return  result;
}

- (void) decrementDishName: (NSString*) dishName{
    int index = [self getIndexOfDishByDishName:dishName];
    int quantity = [self getQuantityOfDishByName:dishName];
    [self.quantity setObject:[NSNumber numberWithInt: quantity - 1] atIndexedSubscript: index];
}

- (void) minusDish:(Dish *)dish{
    if ([self containsDishWithDishID:dish.ID]) {
        
        int index = [self getIndexOfDishByDish:dish];
        int quantity = [self getQuantityOfDishByDish:dish];
        
        // Still have more than one quantity, just decrease the number:
        if (quantity > 1) {
            NSLog(@"Quantity minus one!");
            NSNumber *newQuantity = [NSNumber numberWithInt: quantity - 1];
            [self.quantity setObject:newQuantity atIndexedSubscript: index];
        }
        
        // Have less than one quantity, if minus, becomes 0 quantity, so just remove it:
        else{
            NSLog(@"Removed!!");
            NSLog(@"Before removed: dishes: %d", [self.dishes count]);
            NSLog(@"Before removed: quantity: %d", [self.quantity count]);
            
            // Can't use: [self.quantity removeObjectAtIndex: quantityObject]; The object equality comparision ist not be accurate.
            [self.quantity removeObjectAtIndex: index];
            [self removeDishWithID:dish.ID];
        }
        
    }
}

- (void) addNote: (NSString*) note forDishAtIndex: (int) dishIndex {
    if ([note length] > 0) {
        [self.notes setObject:note forKey:[NSString stringWithFormat:@"%d", dishIndex]];
    } else {
        [self.notes removeObjectForKey:[NSString stringWithFormat:@"%d", dishIndex]];
    }    
}

- (NSString*) getNoteForDishAtIndex: (int) dishIndex {
    return [self.notes objectForKey:[NSString stringWithFormat:@"%d", dishIndex]];
}

- (NSDictionary *) getModifierAnswerAtIndex: (int) index{
    return [self.modifierAnswers objectForKey: [NSString stringWithFormat: @"%d", index]];
}

- (void) setModifierAnswer:(NSDictionary *)modifierAnswer atIndex: (int) index{
    [self.modifierAnswers setObject:modifierAnswer forKey: [NSString stringWithFormat:@"%d", index]];
}

- (int) getQuantityOfDishByDish: (Dish *) dish{
    // require: Dish is not customizable
    
    if ([self containsDishWithDishID:dish.ID]) {
        NSNumber *quantity = [self getQuantityObjectOfDish:dish];
        return quantity.integerValue;
    } else{
        return 0;
    }
}

- (int) getQuantityOfDishByID: (int) dishID{
    // require: Dish is not customizable
    
    for (int i = 0; i < [self.dishes count]; i++) {
        Dish *dish = [self.dishes objectAtIndex:i];
        if (dish.ID == dishID) {
            NSNumber *quantity = [self getQuantityObjectOfDish:dish];
            return quantity.integerValue;
        }
    }
    
    return 0;
}

- (int) getQuantityOfDishByName: (NSString*) dishName{
    
    for (int i = 0; i < [self.dishes count]; i++) {
        Dish *dish = [self.dishes objectAtIndex:i];
        if ([dish.name isEqualToString:dishName]) {
            NSNumber *quantity = [self getQuantityObjectOfDish:dish];
            return quantity.integerValue;
        }
    }
    
    return 0;
}

- (int) getTotalQuantity{
    int totalQuantity = 0;
    
    for (NSNumber *n in self.quantity) {
        totalQuantity += [n integerValue];
    }
    
    return totalQuantity;
}

- (double) getTotalPrice{
    double totalPrice = 0;
    for (int i = 0; i < [self.dishes count]; i++) {
        Dish *newDish = (Dish *)[self.dishes objectAtIndex:i];
        int quantity = [self getQuantityOfDishByDish:newDish];
        if(newDish.canBeCustomized){
            [newDish.customOrderInfo setAnswer: [self getModifierAnswerAtIndex:i]];
            totalPrice += [newDish.customOrderInfo getPriceChange] + newDish.price;
        } else {
            totalPrice += newDish.price * quantity;
        }
    }
    return totalPrice;
}

- (void) mergeWithAnotherOrder: (Order *)newOrder{
    
    for (int i = 0; i < [newOrder.dishes count]; i++) {
        
        Dish *newDish = (Dish *)[newOrder.dishes objectAtIndex:i];
        int newQuantity = [newOrder getQuantityOfDishByDish:newDish];
        
        if (newDish.canBeCustomized){
            
            [self.dishes addObject:newDish];
            [self.quantity addObject: [NSNumber numberWithInt:1]];
            [self setModifierAnswer: [newOrder getModifierAnswerAtIndex:i] atIndex: [self.dishes count] - 1];
            
        } else if ([self containsDishWithDishID: newDish.ID]) {

            int selfQuantity = [self getQuantityOfDishByDish:newDish];
            int index = [self getIndexOfDishByDish:newDish];
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

- (NSNumber *) getQuantityObjectOfDish: (Dish *) newDish{
    int index = [self getIndexOfDishByDish:newDish];
    return (NSNumber *)[self.quantity objectAtIndex: index];
}

- (int) getIndexOfDishByDish: (Dish *) newDish{
    return [self getIndexOfDishByDishID:newDish.ID];
}

- (int) getIndexOfDishByDishID: (int) dishID{
    for (int i = 0; i < [self.dishes count]; i++) {
        Dish * myDish = [self.dishes objectAtIndex:i];
        if (myDish.ID == dishID) {
            return i;
        }
    }
    return -1;
}

- (int) getIndexOfDishByDishName: (NSString*) dishName{
    for (int i = 0; i < [self.dishes count]; i++) {
        Dish * myDish = [self.dishes objectAtIndex:i];
        if ([myDish.name isEqualToString:dishName]) {
            return i;
        }
    }
    return -1;
}

- (Dish *) getDishByID: (int) newDishID{
    for (Dish *dish in self.dishes) {
        if (dish.ID == newDishID) {
           // NSLog(@"Contains: %d!", dishID);
            return dish;
        }
    }
    //NSLog(@"No Contain: %d!", dishID);
    return nil;
}

- (BOOL) containsDishWithDishID: (int) newDishID{
    return [self getDishByID:newDishID] != nil;
}

- (BOOL) containDessert {
    for (Dish *dish in self.dishes) {
        // 4 is the dessert category
        if ( ((NSNumber*)[dish.categories objectAtIndex:0]).intValue == 4) {
            return true;
        }
    }
    return false;
}

- (void) removeDishAtIndex: (int) dishIndex {
    NSString* dishIndexAsKey = [NSString stringWithFormat:@"%d", dishIndex];
    if ([self.dishes count] - 1 >= dishIndex){
        [self.modifierAnswers removeObjectForKey:dishIndexAsKey];
        [self.notes removeObjectForKey:dishIndexAsKey];
        // shift index after the one being removed, by 1
        for (int i = dishIndex + 1; i < [self.dishes count]; i ++) {
            if ([self.notes objectForKey:[NSString stringWithFormat:@"%d", i]]){
                [self.notes setObject:[self.notes objectForKey:[NSString stringWithFormat:@"%d", i]] forKey: [NSString stringWithFormat:@"%d", i - 1]];
                [self.notes removeObjectForKey:[NSString stringWithFormat:@"%d", i]];
            }
            
            if ([self.modifierAnswers objectForKey:[NSString stringWithFormat:@"%d", i]]){
                [self.modifierAnswers setObject:[self.modifierAnswers objectForKey:[NSString stringWithFormat:@"%d", i]] forKey:[NSString stringWithFormat:@"%d", i - 1]];
                [self.modifierAnswers removeObjectForKey:[NSString stringWithFormat:@"%d", i]];
            }
        }
        
        [self.quantity removeObjectAtIndex:dishIndex];
        [self.dishes removeObjectAtIndex:dishIndex];
    }
}

- (void) removeDishWithID: (int) newDishID{
    
    Dish *dishToBeRemoved = nil;
    
    for (Dish *dish in self.dishes) {
        if (dish.ID == newDishID) {
            dishToBeRemoved = dish;
            break;
        }
    }
    int index = [self getIndexOfDishByDish:dishToBeRemoved];
    [self.quantity removeObjectAtIndex:index];
    [self.dishes removeObject: dishToBeRemoved];
    [self.notes removeObjectForKey:[NSString stringWithFormat:@"%d", dishToBeRemoved.ID]];
}

@end
