//
//  PHeaderTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 12/30/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "PHeaderTableViewCell.h"
#import "../../Utils/XSUtils.h"

@implementation PHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-last5m", @"Kết quả 5 trận gần nhất")];
    self.l_last5matches.text = localizedTxt3;
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
