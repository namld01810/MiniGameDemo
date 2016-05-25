//
//  PlayerModel.h
//  BDLive
//
//  Created by Khanh Le on 7/28/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SUBS_PLAYER_IN 1
#define SUBS_PLAYER_OUT 2

@interface PlayerModel : NSObject

@property(nonatomic, strong) NSString* playerNo;
@property(nonatomic, strong) NSString* playerName;
@property(nonatomic, strong) NSString* subsMin;

@property(nonatomic) int subsType;

@end
