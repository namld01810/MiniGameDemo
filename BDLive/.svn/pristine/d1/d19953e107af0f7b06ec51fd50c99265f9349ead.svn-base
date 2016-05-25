//
//  NSString+MD5.m
//  BDLive
//
//  Created by Khanh Le on 4/16/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}



- (NSString*)xmlSimpleUnescape
{
    return [[[[[self stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"]
               stringByReplacingOccurrencesOfString: @"&quot;" withString: @"\""]
              stringByReplacingOccurrencesOfString: @"&#39;" withString: @"'"]
             stringByReplacingOccurrencesOfString: @"&gt;" withString: @">"]
            stringByReplacingOccurrencesOfString: @"&lt;" withString: @"<"];

}

- (NSString *)xmlSimpleEscape
{
    return [[[[[self stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"]
               stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"]
              stringByReplacingOccurrencesOfString: @"'" withString: @"&#39;"]
             stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"]
            stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];

    }



@end