//
//  GameLabelX.m
//  BDLive
//
//  Created by Khanh Le on 5/6/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "GameLabelX.h"

#define PADDING 3

@implementation GameLabelX


- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, PADDING, 0, PADDING))];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    return CGRectInset([self.attributedText boundingRectWithSize:CGSizeMake(999, 999)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil], -PADDING, 0);
}


@end
