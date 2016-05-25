//
//  AppStoreTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 8/24/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPButton.h"

@interface AppStoreTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet IAPButton *leftButton;

@property (weak, nonatomic) IBOutlet IAPButton *rightButton;


@property (weak, nonatomic) IBOutlet UILabel *leftPrice;

@property (weak, nonatomic) IBOutlet UILabel *rightPrice;

@property (weak, nonatomic) IBOutlet UILabel *leftPriceStar;
@property (weak, nonatomic) IBOutlet UILabel *rightPriceStar;

@end
