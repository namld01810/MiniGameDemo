//
//  LSDuDoanTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 3/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "LSDuDoanTableViewCell.h"
#import "../../Utils/XSUtils.h"

@implementation LSDuDoanTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self localizedLabels];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)localizedLabels{
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-stt", @"Stt")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-date", @"Ngày")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-match", @"Trận")];
    NSString* localizedTxt4 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-ret", @"Kết quả")];
    
    self.sttLabel.text = localizedTxt1;
    self.dateLabel.text = localizedTxt2;
    self.matchLabel.text = localizedTxt3;
    self.winlostLabel.text = localizedTxt4;
}

@end
