//
//  ChangePasswordViewController.m
//  BDLive
//
//  Created by Khanh Le on 3/23/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "../Common/xs_common_inc.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "ChangePasswordTableViewCell.h"

#define NIB_PASSWD_CELL @"NIB_PASSWD_CELL"


@interface ChangePasswordViewController () <UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, strong) ChangePasswordTableViewCell* mycell;

@property(nonatomic, strong) SOAPHandler* soapHandler;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.soapHandler = [SOAPHandler new];
    self.soapHandler.delegate = self;
    NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-cpasswd-hdr-title", @"password change")];
    self.title = localizedTxt1;
    
    
    UINib *cell = [UINib nibWithNibName:@"ChangePasswordTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:NIB_PASSWD_CELL];
    
    
    

    
    
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


#pragma tableview
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.height + 100.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChangePasswordTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PASSWD_CELL];
    NSString* phonenumber = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
    NSString* oldPass = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_PASSWORD];
    cell.phoneTxt.text = phonenumber;
    cell.oldPassTxt.text = oldPass;
    
    [cell.finishBtn addTarget:self action:@selector(onFinishClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.mycell = cell;
    
    return cell;
}

-(void)onFinishClick:(id)sender
{
    if(self.mycell.passNewTxt.text.length > 0 && [self.mycell.passNewTxt.text isEqualToString:self.mycell.reNewPassTxt.text]) {
        ZLog(@"everything is fine, send request to change password now");
        
        [self doChangePassword:self.mycell.phoneTxt.text oldPass:self.mycell.oldPassTxt.text myPass:self.mycell.passNewTxt.text];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Lỗi mật khẩu" message:@"Mật khẩu nhập lại không giống nhau." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}



-(void) doChangePassword:(NSString*)phonenumber oldPass:(NSString*)oldPass myPass:(NSString*)myPass
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.changePass", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getChangePasswordSoapMessage:phonenumber oldPass:oldPass myPass:myPass] soapAction:[PresetSOAPMessage getChangePasswordSoapAction]];
        
    });
}



-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    });
}
-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_Change_PasswordResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_Change_PasswordResult>"] objectAtIndex:0];
        
        if ([jsonStr isEqualToString:@"1"]) {
            // change password successfully
            [[NSUserDefaults standardUserDefaults] setObject:self.mycell.passNewTxt.text forKey:REGISTRATION_ACOUNT_PASSWORD];
            [self performSelectorOnMainThread:@selector(onChangePasswordSucceeded:) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(onChangePasswordFailed:) withObject:nil waitUntilDone:NO];
        }
        
        
        
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}



-(void)onChangePasswordSucceeded:(id)sender
{
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:@"Đổi mật khẩu thành công!" delegate:self cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil, nil];
    [view show];
    
}

-(void)onChangePasswordFailed:(id)sender
{
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:@"Đổi mật khẩu không thành công. Vui lòng thử lại!" delegate:nil cancelButtonTitle:@"Thử lại" otherButtonTitles:nil, nil];
    [view show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
