//
//  IAPItem.h
//  BDLive
//
//  Created by Khanh Le on 8/24/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAPItem : NSObject

@property(nonatomic) int iID_MaGoi;

@property(nonatomic) float realPrice;
@property(nonatomic) NSUInteger convertedPrice;

@property(nonatomic, strong)NSString* bundleId;



@end
