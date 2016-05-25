//
//  AdmobInterstitialHelper.m
//  BDLive
//
//  Created by Khanh Le on 3/1/16.
//  Copyright © 2016 Khanh Le. All rights reserved.
//

#import "AdmobInterstitialHelper.h"

static NSString* adUnitId = @"ca-app-pub-5258267629624470/3660013545";

@interface AdmobInterstitialHelper()
/// The interstitial ad.
@property(nonatomic, strong) GADInterstitial *interstitial;


@end

@implementation AdmobInterstitialHelper

-(id)init {
    self = [super init];
    if (self) {
        
        
        [self load];
    }
    return self;
}


-(void)load {
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitId];
    self.interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADInterstitial automatically returns test ads when running on a
    // simulator.
    request.testDevices = @[
                            @"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
                            
                            ];

    
    [self.interstitial loadRequest:request];
}




#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
    [self load];

}
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    
}

-(void)show:(UIViewController*)controller {
    if (self.interstitial != nil && self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:controller];
    }
}

@end
