//
//  AttackOverDefenseTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 12/29/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "AttackOverDefenseTableViewCell.h"
#import "../../Utils/XSUtils.h"

@implementation AttackOverDefenseTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    [self.colLabel1 sizeToFit];
//    [self.colLabel2 sizeToFit];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
