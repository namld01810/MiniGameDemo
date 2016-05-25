//
//  SettingsViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "SettingsViewController.h"
#import "MoreTableViewCell.h"
#import "RegistrationViewController.h"
#import "../Common/xs_common_inc.h"
#import "PersonalInfoViewController.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "ChatZone/ChatViewController.h"
#import "ChatZone/ChatNavViewController.h"
#import "LoginViewController.h"
#import "ChangePasswordViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AccInfo.h"

@interface UILangagueAlertView : UIAlertView

@property(nonatomic, strong) NSString* sLang;

@end

@implementation UILangagueAlertView


@end


@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, FBLoginViewDelegate, SOAPHandlerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) IBOutlet UILabel* cancelLabel;

@property(nonatomic, strong) IBOutlet UITableView* tableView;

@property(nonatomic, strong) NSMutableArray* datasource;
@property(nonatomic, strong) NSMutableDictionary* datasourceDict;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setupCancelLabel];
    
    [self setupDatasouce];
    
    [self addNotification];
    
    
    
    
    
    
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg) {
        PersonalInfoViewController *info = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
        if (self.segmentIndex == 1) {
            info.segmentIndex = self.segmentIndex;
        }
        
        [self.navigationController pushViewController:info animated:NO];
    }
    
    
    // setup nib files
    UINib *cell = [UINib nibWithNibName:@"MoreTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"MoreTableViewCell"];
    
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

-(void)viewWillLayoutSubviews {
#if 0
    float devVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (devVersion >= 7 && devVersion < 8)
    {
        self.view.clipsToBounds = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = 0.0;
        if(UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            screenHeight = screenRect.size.height;
        else
            screenHeight = screenRect.size.width;
        CGRect screenFrame = CGRectMake(0, 20, self.view.frame.size.width,screenHeight-20);
        CGRect viewFr = [self.view convertRect:self.view.frame toView:nil];
        if (!CGRectEqualToRect(screenFrame, viewFr))
        {
            self.view.frame = screenFrame;
            self.view.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
#endif
}

-(void)setupCancelLabel
{

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancelClick:)];
    tap.numberOfTapsRequired = 1;
    self.cancelLabel.userInteractionEnabled = YES;
    [self.cancelLabel addGestureRecognizer:tap];
    
    
    UIColor* bcolor = [UIColor grayColor];
    self.cancelLabel.layer.borderColor = bcolor.CGColor;
    self.cancelLabel.layer.borderWidth = 0.3f;
    [self.cancelLabel.layer setCornerRadius:3.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)setupDatasouce
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self removeNotification];
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isLogin = NO;
    
    self.navigationController.navigationBarHidden = YES;
    self.datasource = [NSMutableArray new];
    self.datasourceDict = [NSMutableDictionary new];
    
    
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {

        
        [self.datasource addObject:@"acc-sign-up.text"];
        [self.datasource addObject:@"acc-sign-in.text"];
        [self.datasource addObject:@"acc-fb-sign-in.text"];
        
        
        
        [self.datasourceDict setValue:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-sign-up.text", @"Mở tài khoản")] forKey:@"acc-sign-up.text"];
        [self.datasourceDict setValue:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-sign-in.text", @"Đăng nhập")] forKey:@"acc-sign-in.text"];
        [self.datasourceDict setValue:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-fb-sign-in.text", @"Đăng nhập bằng Facebook")] forKey:@"acc-fb-sign-in.text"];
        
//        
//        
//        [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-sign-up.text", @"Mở tài khoản")]];
//        [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-sign-in.text", @"Đăng nhập")]];
//        [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-fb-sign-in.text", @"Đăng nhập bằng Facebook")]];
    } else {
        isLogin = YES;
    }
    
//    [self.datasource addObject:@"     Nạp điểm"];
    if(isLogin) {
        
        [self.datasource addObject:@"acc-info.text"];
        [self.datasourceDict setValue:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-info.text", @"Tài khoản")] forKey:@"acc-info.text"];
        
//        [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-info.text", @"Tài khoản")]];
    }
    
    
    [self.datasource addObject:@"acc-chat-room.text"];
    [self.datasource addObject:@"acc-lang-stt.text"];
    
    
    [self.datasourceDict setValue:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-chat-room.text", @"Chat room")] forKey:@"acc-chat-room.text"];
    
    [self.datasourceDict setValue:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-lang-stt.text", @"Ngôn ngữ")] forKey:@"acc-lang-stt.text"];
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-chat-room.text", @"Chat room")]];
    
    

    
    [self.tableView reloadData];
}


-(IBAction)onCancelClick:(id)sender
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"HOME_CLICKED" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MoreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MoreTableViewCell"];
    NSString* funcStr = [self.datasource objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [self.datasourceDict valueForKey:funcStr];
    
    if([funcStr rangeOfString:@"Nạp điểm"].location != NSNotFound) {
        cell.moreImg.image = [UIImage imageNamed:@"ic_menu_4.png"];
    } else if([funcStr rangeOfString:@"acc-chat-room.text"].location != NSNotFound) {
        cell.moreImg.image = [UIImage imageNamed:@"ic_menu_5.png"];
    } else if([funcStr isEqualToString:@"acc-lang-stt.text"]) {
        cell.moreImg.image = [UIImage imageNamed:@"ic_menu_6.png"];

//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.nameLabel.text = @"";
//        cell.en_vi_Switched.hidden = Y;
//        [cell.en_vi_Switched addTarget:self action:@selector(onLanguageChanged:) forControlEvents:UIControlEventValueChanged];

        /*[cell.langSwitchUI addTarget:self action:@selector(onLanguageChanged:) forControlEvents:UIControlEventValueChanged];
        
        [cell.langSwitchUI setOnImage:[UIImage imageNamed:@"ball.png"]];
        [cell.langSwitchUI setOffImage:[UIImage imageNamed:@"ball-P.png"]];*/
        
        
        
    } else {
        cell.moreImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_menu_%lu.png", (indexPath.row+1)]];
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* funcStr = [self.datasource objectAtIndex:indexPath.row];
    
    if([funcStr isEqualToString:@"acc-info.text"]) {
        PersonalInfoViewController *info = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
        [self.navigationController pushViewController:info animated:YES];
    } else if([funcStr isEqualToString:@"acc-fb-sign-in.text"]) {
        [self doFBLogin];
    }  else if([funcStr isEqualToString:@"acc-lang-stt.text"]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tiếng Việt", @"English", nil];
        [sheet showInView:self.view];
    }else if([funcStr isEqualToString:@"acc-chat-room.text"]) {
        
        
        NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
        if(keyReg == nil) {
            NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-chat-room.text", @"Hãy đăng nhập để tham gia thảo luận và bình chọn!")];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
            
            return;
        }
        

        
        ChatViewController *chat = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        
        [self.navigationController pushViewController:chat animated:YES];
//        
//        
//        
//        UIViewController *navController = [[UINavigationController alloc]
//                                           initWithRootViewController:chat];
//        
//        [self presentViewController:navController animated:YES completion:nil];
    } else if([funcStr isEqualToString:@"acc-sign-in.text"]) {
        LoginViewController* loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        
//        ChangePasswordViewController* loginVC = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
        
        [self.navigationController pushViewController:loginVC animated:YES];
    }else if([funcStr rangeOfString:@"Nạp điểm"].location != NSNotFound) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Chức năng đang được phát triển." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert show];
    } else if(indexPath.row == 0) {
        NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
        if(keyReg == nil) {
            RegistrationViewController* regis = [[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
            
            [self.navigationController pushViewController:regis animated:YES];
        } else {
            // already registerd, so don't use anymore
        }
        
    }
    
    
}



-(IBAction)doFBLogin
{
    [FBSession.activeSession close];
    [FBSession.activeSession  closeAndClearTokenInformation];
    FBSession.activeSession=nil;
    
    FBLoginView *loginView = [[FBLoginView alloc] init];

    loginView.delegate = self;
    loginView.readPermissions = @[@"public_profile", @"email"];
    loginView.center = self.view.center;
    loginView.hidden = YES;
    
    [self.view addSubview:loginView];
    
    for (id obj in loginView.subviews) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton * loginButton =  obj;
            
            [loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
    
    
    
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    ZLog(@"you're logged in");
    
    
    
    [self viewWillAppear:NO];
    
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    ZLog(@"fetch user info from FB after login");
    NSString *userId = user.id;
    
//    NSString *urlStr   = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userId];
//    NSURL    *url      = [NSURL URLWithString:urlStr];
//    NSData   *data     = [NSData dataWithContentsOfURL:url];
//    UIImage *image     = [UIImage imageWithData:data];
    
    NSString* name = user.name;
    NSString* fb_email = @"";
    id email = [user objectForKey:@"email"];
    if(email == nil) {
        fb_email = @"";
    } else if([email isKindOfClass:[NSNull class]]) {
        fb_email = @"";
    } else {
        fb_email = email;
    }
    
    NSString* birthday = [user objectForKey:@"birthday"];
    NSString* last_name = [user objectForKey:@"last_name"];
    NSString* first_name = [user objectForKey:@"first_name"];
    NSString* gender = [user objectForKey:@"gender"];
    
    
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_ID];
    if (obj == nil) {
//        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:REGISTRATION_DEVICE_TOKEN_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:REGISTRATION_ACOUNT_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:FB_ACOUNT_KEY_ID];
        
        [[NSUserDefaults standardUserDefaults] setObject:birthday forKey:FB_ACOUNT_KEY_BIRTHDAY];
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:FB_ACOUNT_KEY_EMAIL];
        [[NSUserDefaults standardUserDefaults] setObject:gender forKey:FB_ACOUNT_KEY_GENDER];
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:FB_ACOUNT_KEY_NAME];
        [[NSUserDefaults standardUserDefaults] setObject:first_name forKey:FB_ACOUNT_KEY_FNAME];
        [[NSUserDefaults standardUserDefaults] setObject:last_name forKey:FB_ACOUNT_KEY_LNAME];
        
        
        
        dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.sms", NULL);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
            SOAPHandler* soapHandler = [SOAPHandler new];
            soapHandler.delegate = self;
            [soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getFBRegistrationSoapMessage:userId fbName:name fbEmail:fb_email] soapAction:[PresetSOAPMessage getFBRegistrationSoapAction]];
            
        });
        
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
   
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    ZLog(@"FB logoouttttt");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REGISTRATION_ACOUNT_KEY];
    //
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACOUNT_KEY_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACOUNT_KEY_BIRTHDAY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACOUNT_KEY_EMAIL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACOUNT_KEY_GENDER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACOUNT_KEY_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACOUNT_KEY_FNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACOUNT_KEY_LNAME];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    ZLog(@"%@", [error localizedDescription]);
}



-(void) addNotification
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAppGotFBLoginCallback) name:kAppGotFBLoginCallback object:nil];
    
    
}

-(void) removeNotification
{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAppGotFBLoginCallback
                                                  object:nil];
}

-(void)onNotifyAppGotFBLoginCallback
{
//    [self viewWillAppear:NO];
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
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_Register_FaceResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_Register_FaceResult>"] objectAtIndex:0];
        
        if (jsonStr.length > 5) {
            // login ok
            [[NSUserDefaults standardUserDefaults] setObject:@"FB_LOGIN" forKey:REGISTRATION_DEVICE_TOKEN_KEY];

            [[NSUserDefaults standardUserDefaults] setObject:jsonStr forKey:REGISTRATION_DEVICE_TOKEN_KEY];
            
            [[NSUserDefaults standardUserDefaults] setObject:jsonStr forKey:FB_ACOUNT_KEY_ID_SUBMITTED];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            [[AccInfo sharedInstance] getAccInfo];

            
            // onLoginSucceeded
            [self performSelectorOnMainThread:@selector(onLoginSucceeded:) withObject:nil waitUntilDone:NO];
            
            

        } else {
            [self performSelectorOnMainThread:@selector(onLoginFailed:) withObject:nil waitUntilDone:NO];
        }
        
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}


-(void)onLoginSucceeded:(id)sender
{

//    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:@"Đăng nhập thành công!" delegate:self cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil, nil];
//    [view show];
    
    [self viewWillAppear:NO];
    
}

-(void)onLoginFailed:(id)sender
{
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:@"Lỗi đăng nhập. Vui lòng thử lại!" delegate:nil cancelButtonTitle:@"Thử lại" otherButtonTitles:nil, nil];
    [view show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    [self.navigationController popViewControllerAnimated:YES];
    
    if ([alertView isKindOfClass:[UILangagueAlertView class]]) {
        UILangagueAlertView* langAlert = (UILangagueAlertView*)alertView;
        if (buttonIndex != alertView.cancelButtonIndex) {
            if ([langAlert.sLang isEqualToString:@"vi"]) {
                // viet
                [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"vi", nil] forKey:@"AppleLanguages"];
                [[NSUserDefaults standardUserDefaults] synchronize]; //to make the change immediate
            } else if([langAlert.sLang isEqualToString:@"en"]) {
                // english
                [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
                [[NSUserDefaults standardUserDefaults] synchronize]; //to make the change immediate
                
            }
            
            [NSThread sleepForTimeInterval:0.5f];
            exit(0);
        }
    } else {
    [self viewWillAppear:NO];
    }
    

}

-(void)onLanguageChanged:(UISegmentedControl*)sender {

    NSString* msg = @"";
    if(sender.selectedSegmentIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"vi", nil] forKey:@"AppleLanguages"];
        msg = @"Hệ thống sẽ chuyển sang giao diện tiếng Việt trong lần chạy tiếp theo.";
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
        msg = @"System will change to English interface for next run.";
     
    }
    
    
    UILangagueAlertView* alert = [[UILangagueAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Shutdown", nil];

    [alert show];

    
    [[NSUserDefaults standardUserDefaults] synchronize]; //to make the change immediate
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* msg = @"";
    BOOL isVI = NO;
    BOOL isEN = NO;
    NSArray* lang = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if(lang.count > 0) {
        if ([[lang objectAtIndex:0] isEqualToString:@"vi"]) {
            isVI = YES;
            isEN = NO;
        } else {
            isVI = NO;
            isEN = YES;
        }
    }
    
    
    if(buttonIndex == 0 && isVI == NO) {
        
        
        
        msg = @"Hệ thống cần khởi động lại để chuyển sang giao diện tiếng Việt.";
        
        UILangagueAlertView* alert = [[UILangagueAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Khởi động lại", nil];
        alert.sLang = @"vi";
        
        [alert show];
    } else if(buttonIndex == 1 && isEN == NO) {
        
        msg = @"System need restart to change to English.";
        
        UILangagueAlertView* alert = [[UILangagueAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Restart", nil];
        alert.sLang = @"en";
        [alert show];
        
    }
}


@end
