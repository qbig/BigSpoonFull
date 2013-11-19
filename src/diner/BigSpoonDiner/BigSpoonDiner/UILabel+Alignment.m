//
//  UILabel+Alignment.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 19/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "UILabel+Alignment.h"

@implementation UILabel (extendAlignmentMetnods)

- (void) alignTop{
    CGSize fontSize = [self.text sizeWithAttributes:@{
                                                      NSFontAttributeName:self.font
                                                      }];
    
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    CGRect theStringFrame = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                              NSFontAttributeName:self.font
                                                              }
                                                    context:nil];
    CGSize theStringSize = theStringFrame.size;
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

- (void) alignBottom{
    CGSize fontSize = [self.text sizeWithAttributes:@{
                                                      NSFontAttributeName:self.font
                                                      }];
    
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    
    CGRect theStringFrame = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                              NSFontAttributeName:self.font
                                                              }
                                                    context:nil];
    CGSize theStringSize = theStringFrame.size;
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}

@end
