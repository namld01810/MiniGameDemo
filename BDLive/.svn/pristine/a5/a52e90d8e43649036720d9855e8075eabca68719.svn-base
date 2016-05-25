//
//  Asia2TableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 4/27/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "Asia2TableViewCell.h"
#import "../../Utils/XSUtils.h"


@implementation Asia2TableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-tai-txt", @"Over")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-xiu-txt", @"Under")];
    
    
    self.oLabel.text = [NSString stringWithFormat:@"%@ 2.5", localizedTxt1];
    self.uLabel.text = [NSString stringWithFormat:@"%@ 2.5", localizedTxt2];

    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)resetCellState {
    UIColor* originalC = [UIColor colorWithRed:(51/255.f) green:(51/255.f) blue:(51/255.f) alpha:1.0f];
    self.label1.backgroundColor = originalC;
    self.label2.backgroundColor = originalC;
    self.xLabel.backgroundColor = originalC;
    self.uLabel.backgroundColor = originalC;
    self.oLabel.backgroundColor = originalC;
}

@end
