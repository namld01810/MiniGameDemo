//
//  CommentBoxView.m
//  BDLive
//
//  Created by Khanh Le on 5/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "CommentBoxView.h"

@implementation CommentBoxView

-(void)awakeFromNib {

    UIColor *bcolor = [[UIColor alloc] initWithRed:230.0/255.f green:0.f blue:0.f alpha:1.f];
    self.commentTxtView.layer.borderColor = bcolor.CGColor;
    self.commentTxtView.layer.borderWidth = 0.5f;
    [self.commentTxtView.layer setCornerRadius:5.0f];
    
    
    [[self.sendButton layer] setCornerRadius:5.0f];
    [[self.sendButton layer] setMasksToBounds:YES];
    
    [[self layer] setCornerRadius:5.0f];
    [[self layer] setMasksToBounds:YES];
    
    

    NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"CommentBoxView-comment.text", @"Comment")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"CommentBoxView-send-btn.text", @"Send")];
    
    self.commentLabel.text = localizedTxt;
    [self.sendButton setTitle:localizedTxt2 forState:UIControlStateNormal];
}

@end
