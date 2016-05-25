//
//  IAPButton.h
//  BDLive
//
//  Created by Khanh Le on 8/24/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAPButton : UIButton

@property(nonatomic) CGFloat realPrice;
@property(nonatomic) NSUInteger convertedPrice;


@property(nonatomic) NSUInteger buttonIndex;

@end
