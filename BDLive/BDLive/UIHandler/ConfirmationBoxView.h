//
//  ConfirmationBoxView.h
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfirmationBoxViewDel<NSObject>

@optional
-(void) onChangePhoneClick:(id) sender;
-(void) onOkClick:(id)sender;

@end

@interface ConfirmationBoxView : UIView


@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;

@property (strong, nonatomic) id<ConfirmationBoxViewDel> delegate;

@property (weak, nonatomic) IBOutlet UILabel *boxTitle;

@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end
