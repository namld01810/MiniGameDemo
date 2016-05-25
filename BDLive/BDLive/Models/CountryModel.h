//
//  CountryModel.h
//  BDLive
//
//  Created by Khanh Le on 12/11/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryModel : NSObject

//[0]	(null)	@"sLogo" : @"http://210.245.94.14:84/Uploads/ThumsLibraries/Images/2014/11/29/131305383.jpg"
//[1]	(null)	@"sMaQuocGia_GoalServe" : @"england"
//[2]	(null)	@"iID_MaQuocGia" : (long)1
//[3]	(null)	@"sMaQuocGia" : @"ANH"
//[4]	(null)	@"sTenQuocGia" : @"Anh"
//[5]	(null)	@"sMaQuocGia_en" : @"England"

@property(nonatomic, strong) NSString* sLogo;
@property(nonatomic, strong) NSString* sMaQuocGia_GoalServe;
@property(nonatomic) int iID_MaQuocGia;
@property(nonatomic, strong) NSString* sMaQuocGia;
@property(nonatomic, strong) NSString* sTenQuocGia;
@property(nonatomic, strong) NSString* sMaQuocGia_en;


@end
