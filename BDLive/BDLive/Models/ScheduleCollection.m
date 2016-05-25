//
//  ScheduleCollection.m
//  BDLive
//
//  Created by Khanh Le on 8/6/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "ScheduleCollection.h"

@implementation ScheduleCollection

-(id) init {
    self = [super init];
    if(self) {
        self.listLivescoreKeys = [NSMutableArray new];
        self.listLivescore = [NSMutableDictionary new];
    }
    return self;
}

@end
