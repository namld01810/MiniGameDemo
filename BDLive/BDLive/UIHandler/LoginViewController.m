//
//  LoginViewController.m
//  BDLive
//
//  Created by Khanh Le on 3/23/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "LoginViewController.h"
#import "../Common/xs_common_inc.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../Models/AccInfo.h"


@interface LoginViewController () <SOAPHandlerDelegate, UIAlertViewDelegate>

@property(nonatomic, weak) IBOutlet UITextField *phoneTxt;
@property(nonatomic, weak) IBOutlet UITextField *passwordTxt;

@property(nonatomic, weak) IBOutlet UIButton* loginBtn;

@property(nonatomic, weak) IBOutlet UILabel* phoneLabel;
@property(nonatomic, weak) IBOutlet UILabel* passwdLabel;

@property(nonatomic, strong) SOAPHandler* soapHandler;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-login-title.text", @"ĐĂNG NHẬP")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-login-phone-no.text", @"Số điện thoại")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-login-passwd.text", @"Mật khẩu")];
    NSString* localizedTxt4 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-register-btn-continue.text", @"Continue")];
    
    
    [[self.loginBtn layer] setCornerRadius:5.f];
    [[self.loginBtn layer] setMasksToBounds:YES];
    
    

    self.title = localizedTxt1;
    self.phoneLabel.text = [NSString stringWithFormat:@"%@:", localizedTxt2];
    self.passwdLabel.text = [NSString stringWithFormat:@"%@:", localizedTxt3];
    [self.loginBtn setTitle:localizedTxt4 forState:UIControlStateNormal];
    
    self.soapHandler = [SOAPHandler new];
    self.soapHandler.delegate = self;
    
    
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        self.navigationController.navigationBarHidden = YES;
        
        
    }
}

-(void) doLogin:(NSString*)phonenumber password:(NSString*)password
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.login", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getLoginSoapMessage:phonenumber otp:password] soapAction:[PresetSOAPMessage getLoginSoapAction]];
        
    });
}



-(IBAction)onLoginClick:(id)sender
{
    [self doLogin:self.phoneTxt.text password:self.passwordTxt.text];
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
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_LoginResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_LoginResult>"] objectAtIndex:0];
        
        
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
                NSString* sUser = [dict objectForKey:@"sUsername"];
                NSString* sToken = [dict objectForKey:@"sToKen"];
                NSUInteger iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] integerValue];
                int iErrCode = [(NSNumber*)[dict objectForKey:@"iErrCode"] intValue];
                
                [AccInfo sharedInstance].iBalance = iBalance;
                if (iErrCode == 1) {
                    // everything is fine
                    [[NSUserDefaults standardUserDefaults] setObject:sToken forKey:REGISTRATION_DEVICE_TOKEN_KEY];
                    [[NSUserDefaults standardUserDefaults] setObject:self.phoneTxt.text forKey:REGISTRATION_ACOUNT_KEY];
                    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTxt.text forKey:REGISTRATION_ACOUNT_PASSWORD];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:iBalance] forKey:ACOUNT_BALANCE];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self performSelectorOnMainThread:@selector(onLoginSucceeded:) withObject:nil waitUntilDone:NO];
                } else {
                    // login error
                    [self performSelectorOnMainThread:@selector(onLoginFailed:) withObject:nil waitUntilDone:NO];
                }
            }
        }
        

        
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}


-(void)onLoginSucceeded:(id)sender
{
//    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:@"Đăng nhập thành công!" delegate:self cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil, nil];
//    [view show];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)onLoginFailed:(id)sender
{
//    "acc-login-alert-title.text" = "Lỗi đăng nhập";
//    "acc-login-alert-msg-error.text" = "Sai số điện thoại hoặc mật khẩu. Vui lòng thử lại!";
//    "acc-login-alert-btn-retry.text" = "Thử lại";
    
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-login-alert-title.text", @"Lỗi đăng nhập")];
    NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-login-alert-msg-error.text", @"Sai số điện thoại hoặc mật khẩu. Vui lòng thử lại!")];
    NSString* localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-login-alert-btn-retry.text", @"Thử lại")];
    
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:localizedTxt1 message:localizedTxt2 delegate:nil cancelButtonTitle:localizedTxt3 otherButtonTitles:nil, nil];
    [view show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
