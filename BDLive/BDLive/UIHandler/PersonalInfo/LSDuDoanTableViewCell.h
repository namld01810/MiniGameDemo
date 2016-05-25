//
//  LSDuDoanTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 3/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSDuDoanTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sttLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@property (weak, nonatomic) IBOutlet UILabel *matchLabel;

@property (weak, nonatomic) IBOutlet UILabel *keoLabel;


@property (weak, nonatomic) IBOutlet UILabel *selectionLabel;

@property (weak, nonatomic) IBOutlet UILabel *winlostLabel;

@end
