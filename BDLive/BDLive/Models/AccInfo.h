//
//  AccInfo.h
//  BDLive
//
//  Created by Khanh Le on 3/24/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel;

@interface AccInfo : NSObject


+ (AccInfo*) sharedInstance;

@property(nonatomic) NSUInteger iBalance;

@property(nonatomic, strong) id lsDuDoan;
@property(nonatomic, strong) id topCaoThu;
@property(nonatomic, strong) id topDaiGia;


@property(nonatomic, strong) NSString *dispName;
@property(nonatomic, strong) UserModel *accModel;

@property(nonatomic) BOOL isReview;

-(void) getAccInfo;


@end
