//
//  LineupsTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 5/11/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "LineupsTableViewCell.h"

#import "../Utils/XSUtils.h"


@implementation LineupsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.leftSubImage.hidden = YES;
    self.leftSubLabel.hidden = YES;
    self.rightSubImage.hidden = YES;
    self.rightSubLabel.hidden = YES;
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
