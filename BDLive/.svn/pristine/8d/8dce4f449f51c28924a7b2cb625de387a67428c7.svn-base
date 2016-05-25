//
//  AdNetwork.m
//  BDLive
//
//  Created by Khanh Le on 9/4/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "AdNetwork.h"
#import "../Common/xs_common_inc.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString* admob_inter = @"admob_inter";
static NSString* admob_banner = @"admob_banner";
static const int ADMOB_TYPE = 1;

static NSString* ad_url = @"ad_url";
static NSString* ad_url_image = @"ad_url_image";

static NSString* ad_use_admob = @"ad_use_admob";


@interface AdNetwork () <SOAPHandlerDelegate> {
    
    
}

@property(nonatomic, strong)NSMutableArray* admobBannerViews;

@end


@implementation AdNetwork

static AdNetwork *instance = nil;

+ (AdNetwork*) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    
    return instance;
    
}


- (id)init {
    if (self = [super init]) {
        // init
        NSString* admobBannerId = [[NSUserDefaults standardUserDefaults] objectForKey:admob_banner];
        NSString* admobInterId = [[NSUserDefaults standardUserDefaults] objectForKey:admob_inter];
        
        NSString* sAd_Url = [[NSUserDefaults standardUserDefaults] objectForKey:ad_url];
        NSString* sAd_Url_Image = [[NSUserDefaults standardUserDefaults] objectForKey:ad_url_image];
        
        self.admobIdBanner = (admobBannerId!=nil) ? admobBannerId : ADMOB_ID_BANNER;
        self.admobIdInter = (admobInterId!=nil) ? admobInterId : ADMOB_ID_INTER;
        
        
        self.sAd_Url = (sAd_Url!=nil) ? sAd_Url : @"";
        self.sAd_Url_Image = (sAd_Url_Image!=nil) ? sAd_Url_Image : @"";
        
        self.admobBannerViews = @[].mutableCopy;
        
        [self fetchAdNetworkConfiguration];
        
    }
    return self;
}


-(GADBannerView*)createAdMobBannerView:(UIViewController*) rootViewController admobDelegate:(id<GADBannerViewDelegate>) delegate tableView:(UITableView*)tableView
{
    
    
    NSString* sActive = [[NSUserDefaults standardUserDefaults] objectForKey:ad_use_admob];
    if (sActive) {
        if (![sActive boolValue]) {
            
            [self loadAdUrlImage:tableView];
            return nil;
        }
    }
    
    
    GADBannerView* bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = self.admobIdBanner;
    
    bannerView.rootViewController = rootViewController;
    
    
    GADRequest *request = [GADRequest request];
    
    request.testDevices = [NSArray arrayWithObjects:kGADSimulatorID, @"c4c63e85399b44428b53b87e877076aad759ffc3", @"576e01a9931afc8f1f149e93f2b4357f", @"3543b88160b73ff7e117f0e0fff25494", nil];
    
    
    bannerView.delegate = delegate;
    [bannerView loadRequest:request];
    
    [self.admobBannerViews addObject:bannerView];
    
    return bannerView;
}

-(void)fetchAdNetworkConfiguration {
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.adnetwork", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), myQueue, ^{
        SOAPHandler *soap = [SOAPHandler new];
        soap.delegate = self;
        
        [soap sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Ad_Network_SoapMessage] soapAction:[PresetSOAPMessage get_wsFootBall_Ad_Network_SoapAction]];
        
    });
}

-(void)onSoapDidFinishLoading:(NSData *)data {
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Ad_NetworkResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Ad_NetworkResult>"] objectAtIndex:0];
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                int iAd_Type = [(NSNumber*)[dict objectForKey:@"iAd_Type"] intValue];
                NSString* sAd_Url = [dict objectForKey:@"sAd_Url"];
                NSString* sAd_Url_Image = [dict objectForKey:@"sAd_Url_Image"];
                
                BOOL bActive = [[dict objectForKey:@"bActive"] boolValue];
                BOOL bBanner = [[dict objectForKey:@"bBanner"] boolValue];
                NSString* Ad_Id = [dict objectForKey:@"Ad_Id"];
                
                if (iAd_Type == ADMOB_TYPE) {
                    if (bBanner) {
                        [[NSUserDefaults standardUserDefaults] setObject:Ad_Id forKey:admob_banner];
                        self.admobIdBanner = Ad_Id;
                    } else {
                        [[NSUserDefaults standardUserDefaults] setObject:Ad_Id forKey:admob_inter];
                        self.admobIdInter = Ad_Id;
                    }
                    
                    if (bActive) {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:ad_use_admob];
                    }
                    
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:sAd_Url forKey:ad_url];
                    [[NSUserDefaults standardUserDefaults] setObject:sAd_Url_Image forKey:ad_url_image];
                    if (bActive) {
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ad_use_admob];
                    }
                    
                    self.sAd_Url = sAd_Url;
                    self.sAd_Url_Image = sAd_Url_Image;
                }
                
                
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    @catch (NSException *exception) {
        //
    }
    
}


-(void)loadAdUrlImage:(UITableView*)tableView {
    
    
//    downloadImageWithURL:options:progress:completed^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
    
    __weak UITableView* weakTblView = tableView;
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.sAd_Url_Image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        

        UIImageView* imgView = [[UIImageView alloc] initWithImage:image];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAdImageUrlTap:)];
            tap.numberOfTapsRequired = 1;
            imgView.userInteractionEnabled = YES;
            [imgView addGestureRecognizer:tap];
            weakTblView.tableHeaderView = imgView;
            

        
        
    }];
    
    
//    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.sAd_Url]
//                          options:0
//                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
//     {
//         // progression tracking code
//     }
//                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
//     {
//         if (image)
//         {
//             
//             [XSUtils adjustUIImageView:view.countryFlag image:image];
//             [view.countryFlag setImage:image];
//             
//         }
//     }];
}

-(void)onAdImageUrlTap:(id)sender {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.sAd_Url]];
}

@end
