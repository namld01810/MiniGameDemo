//
//  MoreViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "MoreViewController.h"
#import "RDVTabBarController.h"
#import "xs_common_inc.h"
#import "MoreTableViewCell.h"
#import "GamePredictorViewController.h"
#import "SettingsViewController.h"
#import "NhanDinhChuyenGiaController.h"
#import "MaytinhDuDoanController.h"
#import "ChatZone/ChatViewController.h"
#import "TransferAlertView.h"

#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"

#import "IAP/IAPViewController.h"

#define NUMBER_FUNC 8



static const int _TRANSFER_CODE_ERROR_NOT_EXIST_ = -4; // ID receiver not existed
static const int _TRANSFER_CODE_ERROR_BALANCE_ = -5; // tai khoan ko du
static const int _TRANSFER_CODE_ERROR_MONEY_ = -6; // so tien chuyen > 0


@interface UILangagueAlertView2 : UIAlertView

@property(nonatomic, strong) NSString* sLang;

@end

@implementation UILangagueAlertView2


@end


@interface MoreViewController () <UITableViewDataSource, UITableViewDelegate, RDVTabBarControllerDelegate, UIActionSheetDelegate, SOAPHandlerDelegate>


@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSMutableArray* datasource;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    [self setupDatasouce];
    // setup nib files
    UINib *cell = [UINib nibWithNibName:@"MoreTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"MoreTableViewCell"];

    
    self.soapHandler = [SOAPHandler new];
    self.soapHandler.delegate = self;
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupDatasouce
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.datasource = [NSMutableArray new];
    
    
//    
//    "menu-livescore.text" = "Live Score";
//    "menu-league.text" = "Chọn giải đấu";
//    "menu-favorite.text" = "Các trận quan tâm";
//    "menu-ranking.text" = "Bảng xếp hạng";
//    "menu-bet.text" = "Game dự đoán";
//    "menu-expert-review.text" = "Nhận định chuyên gia";
//    "menu-sys-review.text" = "Máy tính dự đoán";
    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"menu-livescore.text", @"Live Score")]];
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"menu-league.text", @"Chọn giải đấu")]];
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"menu-favorite.text", @"Các trận quan tâm")]];
    
    
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"menu-ranking.text", @"Bảng xếp hạng")]];
    
    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"menu-bet.text", @"Game dự đoán")]];
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"menu-expert-review.text", @"Nhận định của chuyên gia")]];
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"menu-sys-review.text", @"Máy tính dự đoán")]];
    
    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-info.text", @"Tai Khoan")]];
    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-chat-room.text", @"Chat room")]];
    
    
    
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-reward-stt.text", @"ChuyenKhoan")]];
    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-transfer-stt.text", @"Fanpage")]];
    [self.datasource addObject:[NSString stringWithFormat:@"     %@", NSLocalizedString(@"acc-lang-stt.text", @"NgonNgu")]];
    
    
//    [self.datasource addObject:[NSString stringWithFormat:@"     %@", @"IAP"]];
}



- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

-(IBAction)onSettingsClick:(id)sender
{
    ZLog(@"[more] click on settings");
    SettingsViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    UIViewController *navController = [[UINavigationController alloc]
                                       initWithRootViewController:set];
    
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma tableview



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
    
    cell.nameLabel.text = [self.datasource objectAtIndex:indexPath.row];
    
    cell.moreImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_list_%lu.png", (indexPath.row+1)]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0) {
        [self.rdv_tabBarController setSelectedIndex:indexPath.row];
    } else if(indexPath.row == 1) {
        // game du doan
        GamePredictorViewController *game = [[GamePredictorViewController alloc] initWithNibName:@"GamePredictorViewController" bundle:nil];
        [self.navigationController pushViewController:game animated:YES];
    }
    else if(indexPath.row == 2) {
        // tai khoan
        SettingsViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        UIViewController *navController = [[UINavigationController alloc]
                                           initWithRootViewController:set];
        
        [self presentViewController:navController animated:YES completion:nil];
    }else if(indexPath.row == 3) {
        // chat room
        
        
        
        
        ChatViewController *chat = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        
        [self.navigationController pushViewController:chat animated:YES];
    }else if(indexPath.row == 4) {
        // Fanpage
        NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/633059720128880"];
        if([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
            [[UIApplication sharedApplication] openURL:facebookURL];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/007Livescore"]];
        }
        
    }
    
    else if(indexPath.row == 5) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tiếng Việt", @"English", nil];
        [sheet showInView:self.view];
    } else {
        
    }
    
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
        
        UILangagueAlertView2* alert = [[UILangagueAlertView2 alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Khởi động lại", nil];
        alert.sLang = @"vi";
        
        [alert show];
    } else if(buttonIndex == 1 && isEN == NO) {
        
        msg = @"System need restart to change to English.";
        
        UILangagueAlertView2* alert = [[UILangagueAlertView2 alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Restart", nil];
        alert.sLang = @"en";
        [alert show];
        
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    
    if ([alertView isKindOfClass:[UILangagueAlertView2 class]]) {
        UILangagueAlertView2* langAlert = (UILangagueAlertView2*)alertView;
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
    }
    
    
}






@end
