//
//  ImageCache.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 18/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

@property (nonatomic, retain) NSCache *imgCache;

+ (ImageCache*)sharedImageCache;
- (void) addImageWithURL:(NSURL *)imageURL andImage:(UIImage *)image;
- (UIImage*) getImage:(NSURL *)imageURL;
- (BOOL) doesExist:(NSURL *)imageURL;

@end
