//
//  TopDaiGiaTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 3/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopDaiGiaTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bodyView;

@property (weak, nonatomic) IBOutlet UIImageView *cupImageView;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *starLabel;

@end
