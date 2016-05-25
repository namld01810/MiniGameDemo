//
//  LiveScoreTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "LiveScoreTableViewCell.h"
#import "../Utils/XSUtils.h"

@implementation LiveScoreTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.liveLabel.hidden = YES;
    self.clockImg.hidden = YES;
    self.compPredictor.hidden = YES;
    self.expertPredictor.hidden = YES;

    self.flashLive.hidden = YES;
    self.setbetButton.hidden = YES;
    self.keoLabel.hidden = NO;
    
    [self.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_hidden.png"] forState:UIControlStateNormal];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)stopAnimateFlashLive
{
    [self.flashLive stopAnimating];
    self.flashLive.hidden = YES;
}

-(void)animateFlashLive
{
    self.flashLive.hidden = NO;
    UIImageView* animatedImageView = self.flashLive;
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"flash-light.png"],
                                         [UIImage imageNamed:@"flash-dark.png"],
                                         nil];
    animatedImageView.animationDuration = 1.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];
}

-(void)resetViewState
{
    self.liveLabel.hidden = YES;
    self.clockImg.hidden = YES;
    self.compPredictor.hidden = YES;
    self.expertPredictor.hidden = YES;

    self.flashLive.hidden = YES;
    self.highlightedView.hidden = YES;
    self.setbetButton.hidden = YES;
    self.keoLabel.hidden = NO;
    
    [self.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_hidden.png"] forState:UIControlStateNormal];
    
    self.fullTimeLabel.hidden = NO;
    self.halfTimeLabel.hidden = NO;
    self.finishRetLabel.hidden = NO;
    
    self.fullTimeLabel.text = @"FT";
    self.halfTimeLabel.text = @"HT 0 - 1";
    self.finishRetLabel.text = @"0 - 0";
    self.keoLabel.text = @"";
}

@end
