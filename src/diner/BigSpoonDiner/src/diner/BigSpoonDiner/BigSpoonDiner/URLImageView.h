//
//  URLImageView.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLImageView : UIImageView  {
    NSMutableData *_receivedData;
    UIActivityIndicatorView *_loadingIndicatorView;
    void (^_completionBlock)(BOOL finished);
}

@property BOOL suppressLoadingIndicator;

- (void)startLoading:(NSString*)url completion:(void (^)(BOOL finished))completion;
- (void)startLoading:(NSString*)url;

@end
