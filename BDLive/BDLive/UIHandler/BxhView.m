//
//  BxhView.m
//  BDLive
//
//  Created by Khanh Le on 12/10/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "BxhView.h"
#import "../Utils/XSUtils.h"




@implementation BxhView



- (void)awakeFromNib {
    // Initialization code
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self andSubViews:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
