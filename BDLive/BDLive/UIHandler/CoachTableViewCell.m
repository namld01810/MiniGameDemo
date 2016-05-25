//
//  CoachTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 7/28/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "CoachTableViewCell.h"
#import "../Utils/XSUtils.h"

@implementation CoachTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
