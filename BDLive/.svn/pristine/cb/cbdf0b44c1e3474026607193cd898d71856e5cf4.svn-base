//
//  BxhTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 12/10/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "BxhTableViewCell.h"
#import "../Utils/XSUtils.h"



@implementation BxhTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)passValue:(NSArray*)list
{
    for(int i=0;i<self.contentView.subviews.count;++i) {
        UIView* view = [self.contentView.subviews objectAtIndex:i];
        if([view isKindOfClass:[UILabel class]]) {
            UILabel* tmp = (UILabel*)view;
            tmp.text = [list objectAtIndex:tmp.tag];
        }
    }
}

-(void)setCellBackground:(UIColor*)color
{
    self.contentView.backgroundColor = color;
}

@end
