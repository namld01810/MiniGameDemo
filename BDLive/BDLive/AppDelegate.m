//
//  AppDelegate.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "AppDelegate.h"
#import "SOAPHandler/PresetSOAPMessage.h"
#import "SOAPHandler/SOAPHandler.h"
#import "Common/xs_common_inc.h"
#import "UIHandler/ToastAlert.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Models/AccInfo.h"
#import <dlfcn.h>
#import "Utils/Reachability.h"
//#import <StartApp/StartApp.h>
#import "iRate.h"

#define  kFApplicationName @"Football365"
#define kFApplicationBundleID @"com.ptech.LiveScore007"



@interface AppDelegate () <UIApplicationDelegate, SOAPHandlerDelegate>

@property(nonatomic, strong) SOAPHandler *soapHandler;

@end

@implementation AppDelegate




#ifdef kFApplicationBundleID
+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].applicationBundleID = kFApplicationBundleID;
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    
    
    [iRate sharedInstance].applicationName = kFApplicationName;
    
    //enable preview mode
//    [iRate sharedInstance].previewMode = YES;
}
#endif //kFApplicationBundleID

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
   
    
    
    
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self testNetworkConnection];
    self.soapHandler = [[SOAPHandler alloc] init];
    self.soapHandler.delegate = self;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        // ios8 and later
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        // register push notification
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    
    // if have any notifcation, we must handle it
    if(launchOptions!=nil) {
        if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
//            [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
            [self handleDidReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
        }
        
    }
    
    // fetch info now
    [[AccInfo sharedInstance] getAccInfo];
    
    
    
//    //
//    void* sbServices = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
//    int (*SBSLaunchApplicationWithIdentifier)(CFStringRef identifier, Boolean suspended) = dlsym(sbServices, "SBSLaunchApplicationWithIdentifier");
//    int result = SBSLaunchApplicationWithIdentifier((CFStringRef)@"com.ptech.XoSo", false);
//    dlclose(sbServices);
    
    
    // hide status bar for ios7 only
    float devVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (devVersion >= 7 && devVersion < 8)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationFade];
    }
    
    

    
    [self initStartAppAd];
    


    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //PP*1674CODE 4029357733 SGP
    
    [self backgroundHandler:application];
    

    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
//    NSLog(@"resultString: %@", resultString);
    
    [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:@"TySo24h_LastInBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"enter foreground now");
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kAppDidBecomeActive" object:nil];
    
    
    // fb handler
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) backgroundHandler:(UIApplication *)application {
    
#if 1
    // important to get app running in background
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    // end khanh
#endif
}

#pragma Handle push notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)webDeviceToken {
    
    NSString *deviceToken = [[webDeviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    const unsigned *tokenBytes = [webDeviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSLog(@"hexToken: %@", hexToken);
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:hexToken delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    
    NSString* deviceTokenTmp = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY];
    if(deviceTokenTmp!=nil) {
        if([hexToken rangeOfString:deviceTokenTmp].location != NSNotFound) {
            NSLog(@"save token already in user preference!");
            return;
        } else {
            NSLog(@"got new device token, need to replace previous one");
        }
        
        
    }
    
    [[NSUserDefaults standardUserDefaults]
     setObject:hexToken forKey:@"TySo24_DeviceToken"];
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleDidReceiveRemoteNotification:userInfo];
   
    
}

-(void)handleDidReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary* apsDict = [userInfo objectForKey:@"aps"];
    NSString* matran = [userInfo objectForKey:@"matran"];
    NSString* alertMsg = [apsDict objectForKey:@"alert"];
    
    NSLog(@"userinfo : %@", userInfo);
    
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(matran!=nil) {
//                int state = [UIApplication sharedApplication].applicationState;
                NSLog(@"handleDidReceiveRemoteNotification: matran: %@, alert: %@", matran, alertMsg);
                [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveRemoteNotification object:nil userInfo:userInfo];
            }
            
        });
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppShouldReloadFavouriteList object:nil userInfo:userInfo];
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];

        ToastAlert *alert = [[ToastAlert alloc] initWithText:[NSString stringWithFormat:@"Thông báo: %@", alertMsg]];
        alert.userInfo = userInfo;
        alert.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismissAlert:)];
        tap.numberOfTapsRequired = 1;
        [alert addGestureRecognizer:tap];
        
        [window.rootViewController.view addSubview:alert];
        _alert = alert;
    }
    
    
    
}

-(void)onDismissAlert:(id)sender
{
    [_alert removeFromSuperview];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveRemoteNotification object:nil userInfo:_alert.userInfo];
    
    _alert = nil;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppGotFBLoginCallback object:nil];
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}


-(void)testNetworkConnection
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"INTERNET_CONN"];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    
    if(status == NotReachable)
    {
        //No internet
        NSLog(@"No internet");
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        NSLog(@"Wifi internet");
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:9999] forKey:@"INTERNET_CONN"];
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        NSLog(@"3G internet");
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"INTERNET_CONN"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)initStartAppAd
{
    // initialize the SDK with your appID and devID
    //STAStartAppSDK* sdk = [STAStartAppSDK sharedInstance];
    //sdk.appID = @"your app Id";
    //sdk.devID = @"your developer id";
    
//    [sdk showSplashAd];  // display the splash screen
//    sdk.preferences = [STASDKPreferences prefrencesWithAge:22 andGender:STAGender_Male];
//    
//    STASplashPreferences *splashPreferences = [[STASplashPreferences alloc] init];
//    splashPreferences.splashMode = STASplashModeTemplate;
//    splashPreferences.splashTemplateTheme = STASplashTemplateThemeOcean;
//    splashPreferences.splashLoadingIndicatorType = STASplashLoadingIndicatorTypeDots;
//    splashPreferences.splashTemplateIconImageName = @"StartAppIcon";
//    splashPreferences.splashTemplateAppName = @"StartApp Example App";
//    
//    [sdk showSplashAdWithPreferences:splashPreferences];
}


@end
