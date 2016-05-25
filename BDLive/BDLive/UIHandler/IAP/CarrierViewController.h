//
//  CarrierViewController.h
//  BDLive
//
//  Created by Khanh Le on 8/31/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSUInteger _CARRIER_MOBI_FONE_ID_ = 1;
static const NSUInteger _CARRIER_VINA_FONE_ID_ = 2;
static const NSUInteger _CARRIER_VIETTEL_ID_ = 3;







@interface CarrierViewController : UIViewController

@property(nonatomic) NSUInteger carrierId;
@property(nonatomic, strong) NSString* telcoCode;

@end
