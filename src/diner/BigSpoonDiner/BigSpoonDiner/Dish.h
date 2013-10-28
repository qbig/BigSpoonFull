//
//  Dish.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dish : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) int price;
@property (nonatomic) int ratings;

@property (nonatomic) int ID;
@property (nonatomic, strong) NSArray * categories;
@property (nonatomic, strong) NSURL * imgURL;
@property (nonatomic) int pos;
@property (nonatomic, strong) NSString* startTime;
@property (nonatomic, strong) NSString* endTime;
@property (nonatomic) int quantity;


- (id) initWithName: (NSString *) name
        Description: (NSString *) description
              Price: (int) price
            Ratings: (int) ratings
                 ID: (int) ID
         categories: (NSArray *) categories
             imgURL: (NSURL *) imgURL
                pos: (int) pos
          startTime: (NSString *)startTime
            endTime: (NSString *)endTime
           quantity: (int) quantity;

@end
