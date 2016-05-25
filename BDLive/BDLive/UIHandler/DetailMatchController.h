//
//  DetailMatchController.h
//  BDLive
//
//  Created by Khanh Le on 12/10/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDController.h"

@class LivescoreModel;
@interface DetailMatchController : BDController

@property(nonatomic)NSUInteger iID_MaTran;
@property(nonatomic, strong)LivescoreModel *matchModel;

@property (strong, nonatomic) IBOutlet UIImageView *flagImg;
@property (strong, nonatomic) IBOutlet UILabel *tenGiaiDau;

@property (strong, nonatomic) IBOutlet UIImageView *logoDoiNha;

@property (strong, nonatomic) IBOutlet UILabel *tenDoiNha;

@property (strong, nonatomic) IBOutlet UILabel *thoigianThiDau;

@property (strong, nonatomic) IBOutlet UIImageView *logoDoiKhach;

@property (strong, nonatomic) IBOutlet UILabel *tenDoiKhach;

@property (strong, nonatomic) IBOutlet UILabel *labelFT;
@property (strong, nonatomic) IBOutlet UILabel *labelHT;

@property (strong, nonatomic) IBOutlet UILabel *labelResult;

@property (strong, nonatomic) IBOutlet UIImageView *clockImg;






-(void) fetchMatchDetailById;


@end
