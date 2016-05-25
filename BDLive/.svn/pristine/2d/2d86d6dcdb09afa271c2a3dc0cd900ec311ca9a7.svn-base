//
//  AdNetwork.h
//  BDLive
//
//  Created by Khanh Le on 9/4/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADRequest.h>
//#import <GoogleMobileAds/GADBannerView.h>




@interface AdNetwork : NSObject

+ (AdNetwork*) sharedInstance;

-(GADBannerView*)createAdMobBannerView:(UIViewController*) rootViewController admobDelegate:(id<GADBannerViewDelegate>) delegate tableView:(UITableView*)tableView;
@property(nonatomic, strong) NSString* admobIdBanner;
@property(nonatomic, strong) NSString* admobIdInter;


@property(nonatomic, strong) NSString* sAd_Url;
@property(nonatomic, strong) NSString* sAd_Url_Image;




@end
