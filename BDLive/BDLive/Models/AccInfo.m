//
//  AccInfo.m
//  BDLive
//
//  Created by Khanh Le on 3/24/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "AccInfo.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../Common/xs_common_inc.h"
#import "../Models/UserModel.h"


@interface AccInfo () <SOAPHandlerDelegate>

@property(nonatomic, strong) SOAPHandler *soapHandler;

@end


@implementation AccInfo

static AccInfo *instance = nil;

+ (AccInfo*) sharedInstance
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
        self.iBalance = 0;
        self.soapHandler = [SOAPHandler new];
        self.soapHandler.delegate = self;
        
        self.accModel = [UserModel new];
        
        self.isReview = NO;
        

        self.lsDuDoan = nil;
        self.topDaiGia = nil;
        self.topCaoThu = nil;
        
        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:ACOUNT_DISPLAY_NAME];
        if (obj) {
            self.dispName = obj;
        }
        
    }
    return self;
}



// get account info once start app
-(void) getAccInfo
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.chuyengia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        if (account!=nil) {
            [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getAccountInfoMessage:account] soapAction:[PresetSOAPMessage getAccountInfoSoapAction]];
            
            
        }
        
        
        
    });
}



-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lỗi tải dữ liệu" message:kBDLive_OnLoadDataError_Message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        
//        [alert show];
        
    });
    
    
}

-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        
        if ([xmlData rangeOfString:@"<wsUsers_ThongTinResult>"].location != NSNotFound) {
            // user info
            [self handle_wsUsers_ThongTinResult:xmlData];
        } else {
            ZLog(@"unhandle responseee: %@", xmlData);
        }
        
        
    }@catch(NSException *ex) {
        
//        [self onSoapError:nil];
    }
    
}


-(void) handle_wsUsers_ThongTinResult:(NSString*)xmlData
{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_ThongTinResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_ThongTinResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            UserModel* userModel = [UserModel new];
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                NSString* username = [dict objectForKey:@"UserName"];
                NSString* sHoTen = [dict objectForKey:@"sHoTen"];
                NSUInteger iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] integerValue];
                NSUInteger iBalance_Snap = [(NSNumber*)[dict objectForKey:@"iBalance_Snap"] integerValue];
                NSUInteger iBalance_Hao = [(NSNumber*)[dict objectForKey:@"iBalance_Hao"] integerValue];
                NSString* dNgaySinh = [dict objectForKey:@"dNgaySinh"];;
                NSString* bGioiTinh = [dict objectForKey:@"bGioiTinh"];;
                NSString* sEmail = [dict objectForKey:@"sEmail"];
                NSString* sMobile = [dict objectForKey:@"sMobile"];
                
                NSString* iSoLanDuDoan = [dict objectForKey:@"iSoLanDuDoan"];
                NSString* iSoLanDuDoanThang = [dict objectForKey:@"iSoLanDuDoanThang"];
                NSString* iSoLanDuDoanThua = [dict objectForKey:@"iSoLanDuDoanThua"];
                NSString* iSoDuDoanChoKetQua = [dict objectForKey:@"iSoDuDoanChoKetQua"];
                NSString* iXuThang = [dict objectForKey:@"iXuThang"];
                NSString* iXuThua = [dict objectForKey:@"iXuThua"];
                NSString* iXuDuocThuong = [dict objectForKey:@"iXuDuocThuong"];
                NSString* iXuDuocTraLai = [dict objectForKey:@"iXuDuocTraLai"];
                
                
                
                userModel.username = (username!=nil) ? username : @"";
                userModel.sHoTen = (sHoTen!=nil) ? sHoTen : @"";
                userModel.iBalance = iBalance;
                
                userModel.iBalance_Hao = iBalance_Hao;
                userModel.iBalance_Snap = iBalance_Snap;
                userModel.dNgaySinh = (![dNgaySinh isKindOfClass:[NSNull class]]) ? dNgaySinh : @"";
                userModel.bGioiTinh = [bGioiTinh boolValue];
                userModel.sEmail = (![sEmail isKindOfClass:[NSNull class]]) ? sEmail : @"";
                userModel.sMobile = (![sMobile isKindOfClass:[NSNull class]]) ? sMobile : @"";;
                
                userModel.iSoLanDuDoan = iSoLanDuDoan;
                userModel.iSoLanDuDoanThang = iSoLanDuDoanThang;
                userModel.iSoLanDuDoanThua = iSoLanDuDoanThua;
                userModel.iXuThang = iXuThang;
                userModel.iXuThua = iXuThua;
                userModel.iXuDuocThuong = iXuDuocThuong;
                userModel.iXuDuocTraLai = iXuDuocTraLai;
                
                
            }
            
            
            self.accModel = userModel;
            self.iBalance = userModel.iBalance;
            self.dispName = userModel.sHoTen;
            [[NSUserDefaults standardUserDefaults] setObject:self.dispName forKey:ACOUNT_DISPLAY_NAME];
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
}




@end
