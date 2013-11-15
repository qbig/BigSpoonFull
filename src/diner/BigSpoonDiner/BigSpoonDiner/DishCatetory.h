//
//  DishCatetory.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 16/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DishCatetory : NSObject

@property (nonatomic) int ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;

- (id) initWithID: (int) i name: (NSString*) n andDescription: (NSString*) d;


@end
