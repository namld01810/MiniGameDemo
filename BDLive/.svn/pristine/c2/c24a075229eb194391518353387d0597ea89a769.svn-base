//
//  NSTimeZone+CountryCode.m
//  BDLive
//
//  Created by Khanh Le on 4/15/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "NSTimeZone+CountryCode.h"

@implementation NSTimeZone (CountryCode)

+ (NSString *)countryCodeFromLocalizedName
{
    
    NSString *countryCode = @"";
    @try {
        [NSTimeZone resetSystemTimeZone];
        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
        NSString *localizedName = [timeZone localizedName:NSTimeZoneNameStyleShortGeneric locale:[NSLocale systemLocale]];
        
        NSString* cName = [localizedName uppercaseString];
        if ([cName isEqualToString:@"VN"] ||
            [cName isEqualToString:@"(VN)"] ||
            [cName isEqualToString:@"VIETNAM"] ||
            [cName isEqualToString:@"(VIETNAM)"] ||
            [cName isEqualToString:@"(VIET NAM)"] ||
            [cName isEqualToString:@"VIET NAM"]) {
            return @"VN";
        } else {
            return @"EN";
        }
        
        NSArray *components = [localizedName componentsSeparatedByString:@"("];
        
        if ([components count] > 0) {
            // What's inside the parentheses
            id lastComponent = [components lastObject];
            if ([lastComponent isKindOfClass:[NSString class]]) {
                NSString *lastString = lastComponent;
                NSRange whitespaceRange = [lastString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSRange closingParenthesesRange = [lastString rangeOfString:@")"];
                lastString = [lastString substringToIndex:closingParenthesesRange.location];
                
                // We found a space or more than two characters, it means it's not a country code, it's a two words name
                if (whitespaceRange.location != NSNotFound || [lastString length] > 2) {
                    id firstComponent = [components objectAtIndex:0];
                    if ([firstComponent isKindOfClass:[NSString class]]) {
                        NSString *firstString = firstComponent;
                        countryCode = [firstString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    }
                } else
                    countryCode = lastString;
            }
        }

    }
    @catch (NSException *exception) {
        return @"VN";
    }
    
    
    return countryCode;
}

@end
