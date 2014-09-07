//
//  DishModifierSection.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 27/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DishModifierSection.h"

@implementation DishModifierSection
- (DishModifierSection *) initWithSectionJsonDict: (NSDictionary *) dict{
    self = [super init];
//    {"itemTitle" : "Butter",
//        "itemTitleDescription": "2nd butter onwards $0.50/ea",
//        "type" : "count",
//        "threshold" : 0.5,
//        "items" : {
//            "Salted" : 0.5 ,
//            "Unsalted" : 0.5,
//            "Garlic + Herbs" : 0.5,
//            "Rum + Raisin" : 0.5
//        }
//    },
    self.itemTitle = [dict objectForKey:@"itemTitle"];
    self.itemTitleDescription = [dict objectForKey:@"itemTitleDescription"];
    self.type = [dict objectForKey:@"type"];
    self.threshold = [[dict objectForKey:@"threshold"] doubleValue];
    
    NSDictionary *itemsInfo = [dict objectForKey:@"items"];
    NSDictionary *itemsSequences = [dict objectForKey:@"item-sequences"];
    NSMutableArray *itemsArr = [[NSMutableArray alloc] init];

    for(id itemName in itemsInfo) {
        DishModifierItem *item = [[DishModifierItem alloc] init];
        item.itemName = itemName;
        item.itemCount = 0;
        item.itemPrice = [[itemsInfo objectForKey:itemName] doubleValue];
        [itemsArr addObject: item];
    }
    
    itemsArr = [[itemsArr sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first = [[itemsSequences objectForKey: ((DishModifierItem*)a).itemName] integerValue];
        int second = [[itemsSequences objectForKey: ((DishModifierItem*)b).itemName] integerValue];

        return first >= second;
    }] mutableCopy];
    
    if ([self.type isEqualToString:DISH_MODIFIER_TYPE_RADIO]) {
        // set default radio option
        ((DishModifierItem*)[itemsArr objectAtIndex:0]).itemCount = 1;
    }
    self.items = itemsArr;
    return self;
}

- (double) getSum {
    double result = 0;
    for (DishModifierItem *item in self.items){
        result += item.itemPrice * item.itemCount;
    }
    
    
    if (result < 0){
        // downsize for price reduce
        return result;
    } else {
        // addition
        result -= self.threshold;
        return result > 0 ? result : 0;
    }
}
@end
