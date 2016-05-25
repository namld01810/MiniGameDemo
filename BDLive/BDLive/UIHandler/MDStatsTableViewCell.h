//
//  MDStatsTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 5/11/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDStatsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *sLeftInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *sRightInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *rView;

@property (weak, nonatomic) IBOutlet UIView *lView;



@property (weak, nonatomic) IBOutlet UIView *rpView;

@property (weak, nonatomic) IBOutlet UIView *lpView;

@end
