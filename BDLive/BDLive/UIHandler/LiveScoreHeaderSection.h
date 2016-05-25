//
//  LiveScoreHeaderSection.h
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveScoreHeaderSection : UITableViewHeaderFooterView

@property (strong, nonatomic) IBOutlet UIImageView *countryFlag;

@property (strong, nonatomic) IBOutlet UILabel *aliasLabel;

@property (strong, nonatomic) IBOutlet UIButton *statButton;
@property (strong, nonatomic) IBOutlet UIImageView *bxhImg;


@property (strong, nonatomic) IBOutlet UIView *bxhView;


@property (weak, nonatomic) IBOutlet UIView *pinView;

@property (weak, nonatomic) IBOutlet UIButton *pinButton;

@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;

-(void) resetViewState;


@end
