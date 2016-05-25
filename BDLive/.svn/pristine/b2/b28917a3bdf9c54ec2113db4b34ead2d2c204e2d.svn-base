//
//  ConfirmationBoxView.m
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "ConfirmationBoxView.h"
#import "../Utils/XSUtils.h"

@implementation ConfirmationBoxView


-(void)awakeFromNib
{
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-cbox-title.text", @"Xác nhận số điện thoại")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-cbox-body.text", @"Đây có phải số điện thoại của bạn không?")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-cbox-btn-edit.text", @"Thay đổi")];
    
    self.boxTitle.text = localizedTxt1;
    self.bodyLabel.text = localizedTxt2;
    [self.editButton setTitle:localizedTxt3 forState:UIControlStateNormal];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self andSubViews:YES];
}


-(IBAction)onChangePhoneClick:(id)sender
{
    
    if([self.delegate respondsToSelector:@selector(onChangePhoneClick:)]) {
        [self.delegate onChangePhoneClick:sender];
    }
    
}

-(IBAction)onOkClick:(id)sender
{
    if([self.delegate respondsToSelector:@selector(onOkClick:)]) {
        [self.delegate onOkClick:sender];
    }
}

@end
