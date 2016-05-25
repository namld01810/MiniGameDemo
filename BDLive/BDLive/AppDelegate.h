//
//  AppDelegate.h
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ToastAlert;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIBackgroundTaskIdentifier bgTask;
    ToastAlert *_alert;
}

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) UIViewController *viewController;



@end

