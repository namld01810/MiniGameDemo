//
//  LivescoreModel.m
//  BDLive
//
//  Created by Khanh Le on 12/11/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "LivescoreModel.h"
#import "AccInfo.h"

@implementation LivescoreModel

-(NSString*) get_sTyLe_ChapBong:(NSString*)sTyLe_ChapBong
{
    NSString* ret = @"";
    @try {
        NSArray* list = [sTyLe_ChapBong componentsSeparatedByString:@"*"];
        list = [[list objectAtIndex:1] componentsSeparatedByString:@"*"];
        
        return [list objectAtIndex:0];
    }@catch(NSException *ex) {
        
    }
    
    
    return ret;
}

-(NSString*) get_dThoiGianThiDau:(NSDate*)dThoiGianThiDau
{
    NSString* ret = @"";
    @try {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM"];
        
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"HH:mm"];
        
        
        
        NSString *theDate = [dateFormat stringFromDate:dThoiGianThiDau];
        NSString *theTime = [timeFormat stringFromDate:dThoiGianThiDau];

        return [NSString stringWithFormat:@"%@, %@", theDate, theTime];
    }@catch(NSException *ex) {
        
    }
    
    
    return ret;
}



-(NSString*) get_sTyLe_ChapBong_ChauAu_Live:(NSString*)sTyLe_ChapBong {
    NSString* ret = @"";
    @try {
        NSArray* list = [sTyLe_ChapBong componentsSeparatedByString:@"*"];
        ret = [NSString stringWithFormat:@"1X2: %@ - %@ - %@", [list objectAtIndex:0],[list objectAtIndex:1],[list objectAtIndex:2]];
    }
    @catch (NSException *exception) {
        
    }
    
    return ret;
}
-(NSString*) get_sTyLe_ChapBong_TaiSuu_Live:(NSString*)sTyLe_ChapBong {
    NSString* ret = @"";
    @try {
        NSArray* list = [sTyLe_ChapBong componentsSeparatedByString:@"*"];
        ret = [NSString stringWithFormat:@"U/O: %@", [list objectAtIndex:1]];
    }
    @catch (NSException *exception) {
        
    }
    
    return ret;
}


-(void)adjustImageURLForReview {
    BOOL isReview = [AccInfo sharedInstance].isReview;
    if(isReview) {
        self.sLogoDoiKhach = [NSString stringWithFormat:@"%@-isreview", self.sLogoDoiKhach];
        self.sLogoDoiNha = [NSString stringWithFormat:@"%@-isreview", self.sLogoDoiNha];
        self.sLogoGiai = [NSString stringWithFormat:@"%@-isreview", self.sLogoGiai];
        self.sLogoQuocGia = [NSString stringWithFormat:@"%@-isreview", self.sLogoQuocGia];
    }
}

@end
