//
//  RegistrationViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//


#import "RegistrationViewController.h"
#import "../Common/xs_common_inc.h"
#import "ConfirmationBoxView.h"
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"

#include <stdlib.h> // random


@interface RegistrationViewController () <ConfirmationBoxViewDel, TTTAttributedLabelDelegate, SOAPHandlerDelegate, UIAlertViewDelegate>

@property(nonatomic, strong) IBOutlet UITextField *phoneTxt;

@property(nonatomic, strong) IBOutlet UILabel *introLabel;
@property(nonatomic, strong) IBOutlet UILabel *hintLabel;
@property(nonatomic, strong) IBOutlet TTTAttributedLabel *resendLabel;

@property(nonatomic, strong) IBOutlet UIButton *confirmButton;

@property(nonatomic, strong) UIView *confirmView;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic) BOOL isFinalizing;

@property(nonatomic) NSUInteger counterClock;


@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) NSString *submitedPhone;

@property(nonatomic) NSUInteger defPasswd;

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register.text", @"TẠO TÀI KHOẢN MỚI")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-phonenumber.text", @"Nhập số điện thoại của bạn")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-btn-continue.text", @"Tiếp tục")];
    
    self.title = localizedTxt;
    self.isFinalizing = NO;
    self.counterClock = 60;
    
    
    
    [[self.confirmButton layer] setCornerRadius:5.f];
    [[self.confirmButton layer] setMasksToBounds:YES];
    
    self.resendLabel.delegate = self;
    
    self.soapHandler = [SOAPHandler new];
    self.soapHandler.delegate = self;
    
    self.introLabel.text = [NSString stringWithFormat:@"%@:", localizedTxt2];
    [self.confirmButton setTitle:localizedTxt3 forState:UIControlStateNormal];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        self.navigationController.navigationBarHidden = YES;
        
        if(self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}


-(void)showConfirmationBox
{
    [self.phoneTxt resignFirstResponder];
    
    
    
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    coverView.backgroundColor = [UIColor colorWithRed:207/255 green:207/255 blue:207/255 alpha:0.5f];
    
    
    
    ConfirmationBoxView *box = [[[NSBundle mainBundle] loadNibNamed:@"ConfirmationBoxView" owner:nil options:nil] objectAtIndex:0];
    
    box.phoneLabel.text = self.phoneTxt.text;
    box.layer.cornerRadius = 5;
    box.layer.masksToBounds = YES;
    
    box.layer.borderWidth = 1.0f;
    box.layer.borderColor = [UIColor blackColor].CGColor;
    box.delegate = self;
    
    box.center = coverView.center;
    
    
    
    
    [coverView addSubview:box];
    [self.view addSubview:coverView];
    
    
    self.confirmView = coverView;
    
    [UIView beginAnimations:nil context:nil]; // begin animation
    [UIView setAnimationDuration:0.6];
    
    
    [UIView commitAnimations]; // commit animation
}

-(void) finishRegistration:(NSString*)phonenumber otp:(NSString*)otp
{
    
    
    NSString* deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"TySo24_DeviceToken"];
    if(deviceToken == nil) {
        deviceToken = @"";
    }
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.sms", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getRegistrationSoapMessage:phonenumber sMatKhau:otp id_Device:deviceToken] soapAction:[PresetSOAPMessage getRegistrationSoapAction]];
        
    });
}

-(void)validatePhonenumber:(NSString*)phonenumber
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.sms", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getValidationPhonenumberSoapMessage:phonenumber] soapAction:[PresetSOAPMessage getValidationPhonenumberSoapAction]];
        
    });
}

-(IBAction)onNextClick:(id)sender
{
    
    if(self.isFinalizing) {
        // submit phone number and sms verification code
//        if ([self.phoneTxt.text isEqualToString:[NSString stringWithFormat:@"%d", self.defPasswd]]) {
        if(YES) {
            [self finishRegistration:self.submitedPhone otp:self.phoneTxt.text];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mật khẩu nhập không đúng" message:@"Xin mời nhập lại mật khẩu bên trên!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    } else {
        //wsUsers_Check_Login
//        [self showConfirmationBox];
        if(self.phoneTxt.text && self.phoneTxt.text.length > 3) {
            [self validatePhonenumber:self.phoneTxt.text];
        }
        
    }
    
    
}


-(void) onChangePhoneClick:(id) sender
{
    [self.confirmView removeFromSuperview];
    [self.phoneTxt becomeFirstResponder];
    
    self.confirmView = nil;
}
-(void) onOkClick:(id)sender
{
    NSString* phonenumber = self.phoneTxt.text;
    self.submitedPhone = phonenumber;
    [self.confirmView removeFromSuperview];
    
    [self.phoneTxt becomeFirstResponder];
    
    self.confirmView = nil;
    
    self.phoneTxt.text = @"";
    self.phoneTxt.placeholder = @"Mật khẩu";
//    self.introLabel.text = @"Nhập mã bên dưới";
    
    int r = 123456 + arc4random_uniform(100000);
    self.defPasswd = r;
    
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-cbox-inp-passwd.text", @"Nhập mật khẩu của bạn")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-btn-finish.text", @"Hoàn tất")];
    
    self.introLabel.text = [NSString stringWithFormat:@"%@:", localizedTxt1];

    
    // set phonetext is secure
    self.phoneTxt.enabled = NO;
    self.phoneTxt.secureTextEntry = YES;
    self.phoneTxt.enabled = YES;
    [self.phoneTxt becomeFirstResponder];
    
    
    self.hintLabel.hidden = YES;
    self.hintLabel.text = [NSString stringWithFormat:@"Hệ thống sẽ yêu cầu bạn đổi mật khẩu khi đăng nhập lần đầu. Bạn hãy ghi nhớ mật khẩu này: %lu", self.defPasswd];
//    self.resendLabel.hidden = NO;
    
    
    [self.confirmButton setTitle:localizedTxt3 forState:UIControlStateNormal];
    
    
    self.isFinalizing = YES;
    
//    if(self.timer == nil) {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onClockCountdown:) userInfo:nil repeats:YES];
//    }
//    
//    [self requestSMSVerificationCode:phonenumber];
}

-(void)onClockCountdown:(id) sender
{
    
    self.counterClock--;
    if(self.counterClock == 0) {
        [self.timer invalidate];
        
        
        @try {
            [self.resendLabel addLinkToPhoneNumber:@"0979666888" withRange:[self.resendLabel.text rangeOfString:@"vào đây"]];
        }
        @catch (NSException *exception) {
            //
            ZLog(@"make hyperlink error: %@", exception);
        }
        
    }
    self.hintLabel.text = [NSString stringWithFormat:@"Nếu bạn không nhận được mã truy cập trong vòng %lus", self.counterClock];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    ZLog(@"request send new sms verification code again");
    
}

-(void)requestSMSVerificationCode:(NSString*)phonenumber
{
    
}


-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
    });
}
-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if([xmlData rangeOfString:@"wsUsers_RegisterResult"].location != NSNotFound) {
            // handle response for registration
            NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_RegisterResult>"] objectAtIndex:1];
            jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_RegisterResult>"] objectAtIndex:0];
            
            if([jsonStr isEqualToString:@"1"]) {
                ZLog(@"submit phone ok");
                
                [self performSelectorOnMainThread:@selector(onLoginSucceeded:) withObject:nil waitUntilDone:NO];
            } else {
                ZLog(@"submit phone failed");
                [self performSelectorOnMainThread:@selector(onLoginFailed:) withObject:nil waitUntilDone:NO];
            }
        } else if([xmlData rangeOfString:@"wsUsers_Check_LoginResult"].location != NSNotFound) {
            // validate phone number
            ZLog(@"validate phone number");
            [self handle_wsUsers_Check_LoginResult:xmlData];
        } else {
            // handle other case
            NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_LoginResult>"] objectAtIndex:1];
            jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_LoginResult>"] objectAtIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:jsonStr forKey:REGISTRATION_DEVICE_TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:self.submitedPhone forKey:REGISTRATION_ACOUNT_KEY];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //onLoginSucceeded
            [self performSelectorOnMainThread:@selector(onLoginSucceeded:) withObject:nil waitUntilDone:NO];
        }
        
        
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}

-(void)onLoginSucceeded:(id)sender
{
    
    NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-cbox-succeed.text", @"Đăng ký thành công!")];
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-btn-continue.text", @"Tiếp tục")];

    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:localizedTxt delegate:self cancelButtonTitle:localizedTxt1 otherButtonTitles:nil, nil];
    [view show];

}

-(void)onLoginFailed:(id)sender
{
    NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-cbox-failed.text", @"Đăng ký không thành công!")];
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-btn-back.text", @"Quay lại")];
    
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:localizedTxt delegate:self cancelButtonTitle:localizedTxt1 otherButtonTitles:nil, nil];
    [view show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)handle_wsUsers_Check_LoginResult:(NSString*)xmlData
{
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_Check_LoginResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_Check_LoginResult>"] objectAtIndex:0];
        
        
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
                int errorCode = [(NSNumber*)[dict objectForKey:@"iErrCode"] intValue];
                if(errorCode == -1) {
                    // phone number is available
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showConfirmationBox];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"alert-phone-existed-error.text", @"Số điện thoại đã được đăng ký.")];
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizedTxt delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    });
                }
            }
        }
    }
    @catch (NSException *exception) {
        [self onSoapError:nil];
    }
    
}

@end
