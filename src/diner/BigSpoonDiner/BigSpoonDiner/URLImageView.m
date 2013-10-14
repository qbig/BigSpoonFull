//
//  URLImageView.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "URLImageView.h"

#import "URLImageView.h"

@implementation URLImageView
//
// Start loading the image whose URL is specified in url
//
- (void)startLoading:(NSString*)url {
    [self startLoading:url completion:nil];
}

- (void)startLoading:(NSString*)url completion:(void (^)(BOOL finished))completion {
    if (!url)
        return;
    
    _completionBlock = completion;
    
    if (!self.suppressLoadingIndicator) {
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_loadingIndicatorView];
        _loadingIndicatorView.center = self.center;
        [_loadingIndicatorView startAnimating];
    }
    
    _receivedData = [[NSMutableData alloc] init];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                                                delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_completionBlock) {
        _completionBlock(NO);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [[UIImage alloc] initWithData:_receivedData];
    
    if (_loadingIndicatorView) {
        [_loadingIndicatorView stopAnimating];
        [_loadingIndicatorView removeFromSuperview];
        _loadingIndicatorView = nil;
    }
    
    if (!image) {
        if (_completionBlock) {
            _completionBlock(NO);
        }
    }
    else {
        self.image = image;
        if (_completionBlock) {
            _completionBlock(YES);
        }
    }
}
@end
