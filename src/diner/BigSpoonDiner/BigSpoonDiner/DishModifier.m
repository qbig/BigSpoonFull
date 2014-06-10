//
//  DishModifier.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 26/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DishModifier.h"

@implementation DishModifier



- (DishModifier *) initWithJsonDictionary: (NSDictionary *) dict{
    self = [super init];
//    {
//        "backgroundColor" : "434851",
//        "itemTitleColor" : "E29B5C",
//        "itemTextColor" : "FFFFFF",
//        "sections" : [
//                      {"itemTitle" : "Butter",
//                          "itemTitleDescription": "2nd butter onwards $0.50/ea",
//                          "type" : "count",
//                          "threshold" : 0.5,
//                          "items" : {
//                              "Salted" : 0.5 , 
//                              "Unsalted" : 0.5, 
//                              "Garlic + Herbs" : 0.5, 
//                              "Rum + Raisin" : 0.5
//                          }
//                      },
//          ...
//         ]
//    }
    self.backgroundColor = [dict objectForKey:@"backgroundColor"];
    self.itemTitleColor = [dict objectForKey:@"itemTitleColor"];
    self.itemTextColor = [dict objectForKey: @"itemTextColor"];
    NSMutableArray *sectionsArr = [[NSMutableArray alloc] init];
    for (NSDictionary* sectionDic in [dict objectForKey:@"sections"]){
        DishModifierSection *modSection = [[DishModifierSection alloc] initWithSectionJsonDict: sectionDic];
        [sectionsArr addObject:modSection];
    }
    self.modifierSections = sectionsArr;
    return self;
}

- (NSDictionary *) getAnswer{
    NSMutableDictionary *answer = [[NSMutableDictionary alloc] init];
    for ( DishModifierSection *section in self.modifierSections){
        for(DishModifierItem *item in section.items){
            if(item.itemCount != 0){
                [answer setObject: [NSNumber numberWithInt:item.itemCount] forKey: [NSString stringWithFormat: @"%@-%@", section.itemTitle, item.itemName]];
            }
        }
    }
    return answer;
}

- (void) cleanUp {
    for ( DishModifierSection *section in self.modifierSections){
        for(int i = 0; i < [section.items count]; i++){
            DishModifierItem *item = [section.items objectAtIndex: i];
            item.itemCount = 0;
        }
    }
}

- (void) setAnswer:(NSDictionary *)answer {
    [self cleanUp];
    for ( DishModifierSection *section in self.modifierSections){
        for(DishModifierItem *item in section.items){
            NSNumber *count = [answer objectForKey: [NSString stringWithFormat: @"%@-%@", section.itemTitle, item.itemName]];
            if(count){
                item.itemCount = [count intValue];
            }
        }
    }
}

- (double) getPriceChange {
    double result = 0;
    for ( DishModifierSection *section in self.modifierSections){
        result += [section getSum];
    }
    return result;
}

- (NSString *) getDetailsText{
    NSString *result = @"";
    for ( DishModifierSection *section in self.modifierSections){
        for(DishModifierItem *item in section.items){
            if (item.itemCount > 0){
                if ([section.type isEqualToString: DISH_MODIFIER_TYPE_RADIO]){
                    result = [result stringByAppendingString: [NSString stringWithFormat: @"%@: %@\n", section.itemTitle, item.itemName]];
                } else {
                    result = [result stringByAppendingString: [NSString stringWithFormat: @"%@ x %d\n", item.itemName, item.itemCount]];
                }
            }
        }
    }
    
    return result;
}
@end
