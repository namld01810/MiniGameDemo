//
//  PInfoTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 3/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "PInfoTableViewCell.h"
#import "PaddingLabel.h"
#import "../../Utils/XSUtils.h"

@implementation PInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIColor* bcolor = [UIColor colorWithRed:224.0f/255.0 green:224.0f/255.0 blue:224.0f/255.0 alpha:1];;
    
    self.bodyView.layer.borderColor = bcolor.CGColor;
    self.bodyView.layer.borderWidth = 0.7f;
    [self.bodyView.layer setCornerRadius:5.0f];
//    self.bodyView.backgroundColor = [UIColor redColor];
    
    self.sMobile.text = @"";
    
    [self localizeLabels];
  
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) localizeLabels {
    
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-info-ttdd", @"Thông tin dự đoán")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-info-sldd", @"Số lần dự đoán")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-info-slddt", @"Số lần dự đoán thắng")];
    NSString* localizedTxt4 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-info-slddb", @"Số lần dự đoán thua")];
    NSString* localizedTxt5 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-info-sldd-cho", @"Số dự đoán chờ kết quả")];
    NSString* localizedTxt6 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-info-sao-thang", @"Sao đã thắng")];
    NSString* localizedTxt7 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-info-sao-thua", @"Sao đã thua")];
    NSString* localizedTxt8 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-personal", @"Thông tin cá nhân")];
    NSString* localizedTxt9 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-ten-hien-thi", @"Tên hiển thị")];
    
    NSString* localizedTxt10 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-gender", @"Giới tính")];
    NSString* localizedTxt11 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-mobile-phone", @"Di động")];
    
    NSString* localizedTxt12 = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-birthday", @"Birthday")];
    
    
    
    self.ttDuDoanLabel.text = localizedTxt1;
    self.solanDDLabel.text = localizedTxt2;
    self.solanDDThangLabel.text = localizedTxt3;
    self.solanDDThuaLabel.text = localizedTxt4;
    self.solanDDChoLabel.text = localizedTxt5;
    self.saoThangLabel.text = localizedTxt6;
    self.saoThuaLabel.text = localizedTxt7;
    
    self.ttCanhanLabel.text = localizedTxt8;
    self.tenHienThiLabel.text = localizedTxt9;
    self.gioitinhLabel.text = localizedTxt10;
    self.sodidongLabel.text = localizedTxt11;
    self.ngaysinhLabel.text = localizedTxt12;
    
    
}

@end
