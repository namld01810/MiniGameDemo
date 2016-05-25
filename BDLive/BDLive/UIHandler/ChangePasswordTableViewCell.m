//
//  ChangePasswordTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 3/23/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "ChangePasswordTableViewCell.h"
#import "../Utils/XSUtils.h"

@implementation ChangePasswordTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    [[self.finishBtn layer] setCornerRadius:5.f];
    [[self.finishBtn layer] setMasksToBounds:YES];
    
    [self localizeLabels];
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) localizeLabels {
    
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-cpasswd-sdt", @"Phone number")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-cpasswd-mkht", @"Old password")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-cpasswd-mkm", @"New Password")];
    NSString* localizedTxt4 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-cpasswd-nlmk", @"Re-type password")];
    NSString* localizedTxt5 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-cpasswd-btn-ht", @"Finish")];
    
    
    self.sdtLabel.text = localizedTxt1;
    self.mkhtLabel.text = localizedTxt2;
    self.mkmLabel.text = localizedTxt3;
    self.nlmkLabel.text = localizedTxt4;
    [self.finishBtn setTitle:localizedTxt5 forState:UIControlStateNormal];
    
    
}

@end
