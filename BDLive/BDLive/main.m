//
//  main.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Utils/NSTimeZone+CountryCode.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        
        NSString *firstUse = [[NSUserDefaults standardUserDefaults] objectForKey:@"TYSO24H_FIRST_USE"];
        if (firstUse == nil || ![firstUse isEqualToString:@"1"]) {
            NSString* countryCode = [NSTimeZone countryCodeFromLocalizedName];
            countryCode = [countryCode uppercaseString];
            
            NSString* lang = @"vi";
            if ([countryCode isEqualToString:@"VN"]) {
                lang = @"vi";
            } else {
                lang = @"en";
            }
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:lang, nil] forKey:@"AppleLanguages"];
            [[NSUserDefaults standardUserDefaults] synchronize]; //to make the change immediate
        }
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
