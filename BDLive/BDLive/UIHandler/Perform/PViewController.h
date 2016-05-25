//
//  PViewController.h
//  BDLive
//
//  Created by Khanh Le on 12/29/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../BDController.h"

@class LivescoreModel;

@interface PViewController : BDController

@property(nonatomic) NSUInteger p_type;

@property(nonatomic) NSUInteger iID_MaTran;

@property(nonatomic, weak) LivescoreModel* model;

@end
