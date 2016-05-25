//
//  GameTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "GameTableViewCell.h"
#import "../Utils/XSUtils.h"
#import "../Models/AccInfo.h"

@implementation GameTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [self.htButton setTitle:@"" forState:UIControlStateNormal];
        [self.htButton setBackgroundImage:[UIImage imageNamed:@"ic_hoantat.png"] forState:UIControlStateNormal];
    }
    
    if ([AccInfo sharedInstance].iBalance <=0) {
        // disable slider
        self.oppositeSlider.enabled = NO;
        self.hostSlider.enabled = NO;
    } else {
        self.oppositeSlider.maximumValue = [AccInfo sharedInstance].iBalance;
        self.hostSlider.maximumValue = [AccInfo sharedInstance].iBalance;
        
        self.oppositeSlider.enabled = YES;
        self.hostSlider.enabled = YES;
    }
    
    self.hostDD.textColor = [UIColor blackColor];
    self.oppositeDD.textColor = [UIColor blackColor];
    
    NSString* localizeNS = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-NS.txt", @"Nhập sao")];
    NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
    self.hostNS.text = localizeNS;
    self.oppositeNS.text = localizeNS;
    
    self.hostDD.text = [NSString stringWithFormat:@"%@: 0 ☆", localizeDD];
    self.oppositeDD.text = [NSString stringWithFormat:@"%@: 0 ☆", localizeDD];
    
    self.originalKeo.hidden = YES;
    
    self.g_NSLabel.text = localizeNS;
    self.g_NSLabel2.text = localizeNS;
    self.g_DD_1x2_Khach.text = [NSString stringWithFormat:@"%@: 0 ☆", localizeDD];
    self.g_DD_1x2_Nha.text = [NSString stringWithFormat:@"%@: 0 ☆", localizeDD];
    self.g_DD_uo_Khach.text = [NSString stringWithFormat:@"%@: 0 ☆", localizeDD];
    self.g_DD_uo_Nha.text = [NSString stringWithFormat:@"%@: 0 ☆", localizeDD];
    self.g_xLabel.text = [NSString stringWithFormat:@"0 ☆"];
    
    
    
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
    
    
    [self setNSBorder:nil];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setNSBorder:(UIColor*)bcolor {
    if(YES) {
//        UIColor* tmp_bcolor = [[UIColor alloc] initWithRed:34.0/255.f green:91.f blue:34.f alpha:1.f];
//        self.txlabelBorder.layer.borderColor = tmp_bcolor.CGColor;
//        self.txlabelBorder.layer.borderWidth = 0.5f;
//        
//        self.asialabelBorder.layer.borderColor = tmp_bcolor.CGColor;
//        self.asialabelBorder.layer.borderWidth = 0.5f;
//        
//        [self.txlabelBorder.layer setCornerRadius:3.5f];
//        [self.asialabelBorder.layer setCornerRadius:3.5f];
        
//        UIColor* tmp_bcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_bet_box_bg_color.png"]];
//        self.asialabelBorder.backgroundColor = tmp_bcolor;
//        self.txlabelBorder.backgroundColor = tmp_bcolor;
        
        [[self.txlabelBorder layer] setCornerRadius:5.0f];
        [[self.txlabelBorder layer] setMasksToBounds:YES];
        
        [[self.asialabelBorder layer] setCornerRadius:5.0f];
        [[self.asialabelBorder layer] setMasksToBounds:YES];
        
        return;
    }
    if(bcolor == nil) {
        bcolor = [[UIColor alloc] initWithRed:230.0/255.f green:0.f blue:0.f alpha:1.f];
    }
    
    self.hostNS.layer.borderColor = bcolor.CGColor;
    self.hostNS.layer.borderWidth = 0.5f;
    [self.hostNS.layer setCornerRadius:5.0f];
    
    self.oppositeNS.layer.borderColor = bcolor.CGColor;
    self.oppositeNS.layer.borderWidth = 0.5f;
    [self.oppositeNS.layer setCornerRadius:5.0f];
}

@end


@implementation BetGameButton

@end
