//
//  XSUtils.h
//  BDLive
//
//  Created by Khanh Le on 12/12/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XSUtils : NSObject

+(NSString*)toDayOfWeek:(NSDate*)date;

+(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews;

+(NSString*)translateSymbolWDL:(NSString*)wdl;

+(UIColor*) makeColorByWDL:(NSString*)wdl;


+(void)popupHighlightedView:(UIView*)imageView;


+(NSString*)format_iBalance:(NSUInteger) iBalance;

+(float) get_tyleChapBong_SetBet:(NSString*)sKeo isHost:(BOOL)isHost;


+(UIImage*)imageBaseOnResolution:(NSString*)imagedName ext:(NSString*) ext;

+(float) convertFloatFromString_SetBet:(NSString*)sKeo;


+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+(void)adjustUIImageView:(UIImageView*)imgView image:(UIImage*)image;

+(NSString *) stringByStrippingHTML:(NSString*)s;

+(void)setTableFooter:(UITableView*)tableView tap:(UITapGestureRecognizer*) tap;


+(NSString*)getNextDay:(NSDate*)date dateFormat:(NSString*)dateFormat;
+(NSString*)getYesterday:(NSDate*)date dateFormat:(NSString*)dateFormat;
+(NSString*)getDateByGivenDateInterval:(NSDate*)date dateFormat:(NSString*)dateFormat dateInterval:(int)dateInterval;

+(NSDate*)getDateByGivenDateInterval:(NSDate*)date dateInterval:(int)dateInterval;


+(NSData*) hmac256ForKeyAndData:(NSString*)key  data:(NSString*)data;
+(NSString*) byteToNSString:(NSData*)theData;

@end
