//
//  MoreTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 12/12/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *moreImg;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UISwitch *langSwitchUI;

@property (weak, nonatomic) IBOutlet UISegmentedControl *en_vi_Switched;

@end
