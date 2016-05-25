//
//  SplashViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "SplashViewController.h"
#import "LiveScoreViewController.h"
#import "LeagueViewController.h"
#import "FavouriteViewController.h"
#import "StatsViewController.h"
#import "MoreViewController.h"
#import "BXHViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "../Common/xs_common_inc.h"
#import "SettingsViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "../Models/AccInfo.h"
#import "../AdNetwork/AdNetwork.h"

#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"



@interface SplashViewController () <UIAlertViewDelegate, SOAPHandlerDelegate>

@property(nonatomic, strong) IBOutlet UIImageView *splashAnimate;


@property (strong, nonatomic) UIViewController *viewController;

@property(strong, nonatomic) LiveScoreViewController* livescoreController;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [AccInfo sharedInstance].isReview = YES;
    [self get_IOS_CONFIG];
    // Do any additional setup after loading the view.
    
    
//    [self animateSplashLogo];
    
    [self setupViewControllers];
    
    [self addNotification];
    
    self.splashAnimate.image = [XSUtils imageBaseOnResolution:@"splash_bg" ext:@"png"];
    
    
    [AdNetwork sharedInstance];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}


-(void)get_IOS_CONFIG {
    
    SOAPHandler * soapHandler = [SOAPHandler new];
    soapHandler.delegate = self;
    [soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Config_IOS_SoapMessage] soapAction:[PresetSOAPMessage get_wsFootBall_Config_IOS_SoapAction]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) animateSplashLogo
{
    UIImageView* animatedImageView = self.splashAnimate;
//    animatedImageView.animationImages = [NSArray arrayWithObjects:
//                                         [UIImage imageNamed:@"Logo-Loading1.png"],
//                                         [UIImage imageNamed:@"Logo-Loading2.png"],
//                                         [UIImage imageNamed:@"Logo-Loading3.png"],
//                                         [UIImage imageNamed:@"Logo-Loading4.png"],
//                                         [UIImage imageNamed:@"Logo-Loading5.png"],
//                                         [UIImage imageNamed:@"Logo-Loading6.png"],
//                                         [UIImage imageNamed:@"Logo-Loading7.png"],
//                                         [UIImage imageNamed:@"Logo-Loading8.png"],
//                                         nil];
    
    
    NSMutableArray *arrayImgs = [NSMutableArray new];
    for (int i=1; i<34; i++) {
        NSString* obj = [NSString stringWithFormat:@""];
        if (i < 10) {
            obj = [NSString stringWithFormat:@"ball000%d.png", i];
        } else {
            obj = [NSString stringWithFormat:@"ball00%d.png", i];
        }
        
        [arrayImgs addObject:[UIImage imageNamed:obj]];
    }
    
    animatedImageView.animationImages = arrayImgs;
    animatedImageView.animationDuration = 1.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];
}

- (void)setupViewControllers {
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *storyboard = self.storyboard;
    
    UIViewController *firstViewController = [storyboard instantiateViewControllerWithIdentifier:@"LiveScoreViewController"];
    self.livescoreController = (LiveScoreViewController*) firstViewController;
    
    UIViewController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:firstViewController];
    
    UIViewController *secondViewController = [storyboard instantiateViewControllerWithIdentifier:@"LeagueViewController"];
    UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:secondViewController];
    
    UIViewController *secondViewController2 = [storyboard instantiateViewControllerWithIdentifier:@"FavouriteViewController"];
    UIViewController *secondNavigationController2 = [[UINavigationController alloc]
                                                     initWithRootViewController:secondViewController2];
    
    UIViewController *secondViewController3 = [storyboard instantiateViewControllerWithIdentifier:@"BXHViewController"];
    UIViewController *secondNavigationController3 = [[UINavigationController alloc]
                                                     initWithRootViewController:secondViewController3];
    
    
    UIViewController *thirdViewController = [storyboard instantiateViewControllerWithIdentifier:@"MoreViewController"];
    UIViewController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:thirdViewController];
    
    
//    UIViewController *setController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
//    UIViewController *setNavigationController = [[UINavigationController alloc]
//                                                   initWithRootViewController:setController];
    
    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[firstNavigationController, secondNavigationController, secondNavigationController2, secondNavigationController3,
                                           thirdNavigationController]];
    
    self.viewController = tabBarController;

    
    [self customizeTabBarForController:tabBarController];
    
    
    
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"first", @"second", @"third", @"four", @"five"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
        
        
    }
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor: [UIColor blackColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}

-(void)onNotifyDBLivescoreDataLoadDone
{
    [self removeNotification]; // remove notification
    ZLog(@"load data done");
    self.livescoreController.isLoadingData = NO;
    
#if 1
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        
        [window setRootViewController:self.viewController];
        
        
        
        [window makeKeyAndVisible];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
            window.clipsToBounds = YES;
            window.frame =  CGRectMake(0, 20, window.frame.size.width, window.frame.size.height-20);
        }
        
        [self customizeInterface];
    });
#endif
}

-(void)onNotifyDBLivescoreDataLoadError
{
    self.livescoreController.isLoadingData = NO;
    ZLog(@"there is a problem during load data");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    });
    
}

-(void) addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyDBLivescoreDataLoadDone) name:kBDLive_OnLivescoreData_LoadDone object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyDBLivescoreDataLoadError) name:kBDLive_OnLivescoreData_LoadError object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAppReceiveRemoteNotification:) name:kAppDidReceiveRemoteNotification object:nil];
    
    
}

-(void) removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                    name:kBDLive_OnLivescoreData_LoadDone
                object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kBDLive_OnLivescoreData_LoadError
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAppDidReceiveRemoteNotification
                                                  object:nil];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(self.livescoreController != nil) {
        ZLog(@"retry to get data");
        [self.livescoreController retryFetchLivescoreList];
    }
}

-(void)onNotifyAppReceiveRemoteNotification:(NSDictionary*)userInfo
{
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    ZLog(@"onNotifyAppReceiveRemoteNotification");
    [((RDVTabBarController*)self.viewController) setSelectedIndex:2];
}

-(void)onSoapError:(NSError *)error {
    
}
-(void)onSoapDidFinishLoading:(NSData *)data {
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Config_IOSResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Config_IOSResult>"] objectAtIndex:0];
        
        
        
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
                int isReview = [(NSNumber*)[dict objectForKey:@"Value"] intValue];
                
                [AccInfo sharedInstance].isReview = (isReview == 1) ? YES : NO;
            }
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


@end
