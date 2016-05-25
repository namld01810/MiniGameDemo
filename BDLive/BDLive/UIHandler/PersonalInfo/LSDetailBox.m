//
//  LSDetailBox.m
//  BDLive
//
//  Created by Khanh Le on 3/27/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "LSDetailBox.h"

@implementation LSDetailBox

-(void)awakeFromNib {
    [self localizeLabels];
}


-(void)localizeLabels {
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-title", @"Chi tiết")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-date", @"Ngày")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-match", @"Trận")];
    NSString* localizedTxt4 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-tyso", @"Tỷ số")];
    NSString* localizedTxt5 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-keo", @"Kèo")];
    NSString* localizedTxt6 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-select", @"Chọn")];
    NSString* localizedTxt7 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-dat", @"Đặt")];
    NSString* localizedTxt8 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-recv", @"Nhận")];
    NSString* localizedTxt9 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-result", @"Kết quả")];
    
    
    
    NSString* localizedTxt_kickoff = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ls-detail-box-date-thoigianthidau", @"kick-off date")];
    
    self.l_detailLabel.text = localizedTxt1;
    self.l_dateLabel.text = localizedTxt2;
    self.l_tranLabel.text = localizedTxt3;
    self.l_tysoLabel.text = localizedTxt4;
    self.l_keoLabel.text = localizedTxt5;
    self.l_chonLabel.text = localizedTxt6;
    self.l_datLabel.text = localizedTxt7;
    self.l_nhanLabel.text = localizedTxt8;
    self.l_ketquaLabel.text = localizedTxt9;
    
    self.dateMatchLabel.text = localizedTxt_kickoff;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
