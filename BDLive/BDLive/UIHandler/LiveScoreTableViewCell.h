//
//  LiveScoreTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDButton.h"

@interface LiveScoreTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *liveLabel;
@property (strong, nonatomic) IBOutlet UILabel *hostTeamLabel;

@property (strong, nonatomic) IBOutlet UILabel *oppositeTeam;


@property (strong, nonatomic) IBOutlet UILabel *halfTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *fullTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *finishRetLabel; // finish result label

@property (strong, nonatomic) IBOutlet UIImageView *clockImg;

@property (strong, nonatomic) IBOutlet UIImageView *flashLive;

@property (strong, nonatomic) id matchModel;

@property (strong, nonatomic) IBOutlet BDButton *compPredictor;

@property (strong, nonatomic) IBOutlet BDButton *expertPredictor;
@property (strong, nonatomic) IBOutlet BDButton *performanceInfo;

@property (strong, nonatomic) IBOutlet BDButton *setbetButton;

@property (strong, nonatomic) IBOutlet BDButton *favouriteBtn;

@property (weak, nonatomic) IBOutlet UIView *highlightedView;

@property (weak, nonatomic) IBOutlet UILabel *keoLabel;

@property (weak, nonatomic) IBOutlet UILabel *matchTimeLabel;




@property (weak, nonatomic) IBOutlet UILabel *uoLabel;

@property (weak, nonatomic) IBOutlet UILabel *xLabel;




@property(nonatomic)NSUInteger iID_MaTran;

-(void)animateFlashLive;
-(void)stopAnimateFlashLive;

-(void)resetViewState;

@end
