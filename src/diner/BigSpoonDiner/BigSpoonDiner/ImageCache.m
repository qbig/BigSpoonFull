//
//  ImageCache.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 18/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

@synthesize imgCache;

#pragma mark - Methods

static ImageCache* sharedImageCache = nil;

+(ImageCache*)sharedImageCache
{
    @synchronized([ImageCache class])
    {
        if (!sharedImageCache)
            sharedImageCache= [[self alloc] init];
        
        return sharedImageCache;
    }
    
    return nil;
}

+(id)alloc
{
    @synchronized([ImageCache class])
    {
        NSAssert(sharedImageCache == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedImageCache = [super alloc];
        
        return sharedImageCache;
    }
    
    return nil;
}

-(id)init{
    self = [super init];
    if (self != nil)
    {
        imgCache = [[NSCache alloc] init];
    }
    
    return self;
}

// Public methods:

- (void) addImageWithURL:(NSURL *)imageURL andImage:(UIImage *)image{
    if(image != nil){
        [imgCache setObject:image forKey:[imageURL absoluteString]];
    } else {
        NSLog(@"Error in - (void) addImageWithURL:(NSURL *)imageURL andImage:(UIImage *)image : inserting nil");
    }
}

- (NSString*) getImage:(NSURL *)imageURL{
    return [imgCache objectForKey:[imageURL absoluteString]];
}

- (BOOL) doesExist:(NSURL *)imageURL{
    if ([imgCache objectForKey:[imageURL absoluteString]] == nil)
    {
        return false;
    }
    return true;
}

@end
