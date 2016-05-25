//
//  CupModel.h
//  BDLive
//
//  Created by Khanh Le on 9/3/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CupModel : NSObject


@property(nonatomic) BOOL bCoLich;
@property(nonatomic) BOOL bVongActive;

@property(nonatomic) int iID_MaGiai;
@property(nonatomic) int iSTT;

@property(nonatomic, strong)NSString* sTen_en;
@property(nonatomic, strong)NSString* sTen;

@property(nonatomic, strong)NSString* sDanhSachBang;

//[0]	(null)	@"bCoLich" : @"1"
//[1]	(null)	@"sMoTa" : @"vòng bảng"
//[2]	(null)	@"sTen_en" : @"Group"
//[3]	(null)	@"sTen" : @"Vòng bảng"
//[4]	(null)	@"iID_MaGiai" : (long)27
//[5]	(null)	@"sTenGiai" : @"C1"
//[6]	(null)	@"sBang" : @"Group"
//[7]	(null)	@"iID_MaVong" : (long)1
//[8]	(null)	@"bVongActive" : @"1"

@end
