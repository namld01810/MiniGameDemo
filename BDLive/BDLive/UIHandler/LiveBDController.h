//
//  LiveBDController.h
//  BDLive
//
//  Created by Khanh Le on 12/16/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "BDController.h"

@interface LiveBDController : BDController

-(void) fetchListLeageLiveByCountry:(NSString*)iID_MaGiai;
-(void)fetch_wsFootBall_VongDau;
-(void)fetch_wsFootBall_BangXepHang;
-(void)fetch_wsFootBall_SVD;


@property (weak, nonatomic) IBOutlet UIView *headerLiveBDView;
@property (weak, nonatomic) IBOutlet UIImageView *icLivescoreImageView;

@property(assign) BOOL loadFirstTime;

@property(nonatomic) NSUInteger iID_MaGiai;

@property(nonatomic) NSUInteger selectedDateIndex;

@property(nonatomic, strong) NSString* sTenGiai;

@property(nonatomic) BOOL bGiaiCup;

@property (weak, nonatomic) IBOutlet UIScrollView *fixtureScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *groupScrollView;


@end
