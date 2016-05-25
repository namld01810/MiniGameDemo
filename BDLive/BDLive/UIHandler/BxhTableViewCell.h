//
//  BxhTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 12/10/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BxhTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *sttLabel;

@property (strong, nonatomic) IBOutlet UILabel *ptsLabel;
@property (strong, nonatomic) IBOutlet UILabel *gpLabel;

@property (strong, nonatomic) IBOutlet UILabel *wLabel;

@property (strong, nonatomic) IBOutlet UILabel *dLabel;

@property (strong, nonatomic) IBOutlet UILabel *lLabel;

@property (strong, nonatomic) IBOutlet UILabel *gaLabel;

@property (strong, nonatomic) IBOutlet UILabel *gfLabel;

@property (strong, nonatomic) IBOutlet UILabel *hsLabel;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

-(void)passValue:(NSArray*)list;


@end
