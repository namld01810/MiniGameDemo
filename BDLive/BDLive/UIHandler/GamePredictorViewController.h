//
//  GamePredictorViewController.h
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDController.h"

@class LivescoreModel;
@class GameTableViewCell;
@interface GamePredictorViewController : BDController

@property(nonatomic, strong) LivescoreModel *selectedModel;

+(void)updateLiveScoreTableViewCell:(GameTableViewCell*)cell model:(LivescoreModel*)model;

@end
