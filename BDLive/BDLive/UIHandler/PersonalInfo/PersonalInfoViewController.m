//
//  PersonalInfoViewController.m
//  BDLive
//
//  Created by Khanh Le on 3/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "xs_common_inc.h"
#import "PInfoTableViewCell.h"
#import "LSDuDoanTableViewCell.h"
#import "TopCaoThuTableViewCell.h"
#import "TopDaiGiaTableViewCell.h"
#import "LsDuDoanModel.h"
#import "../../Models/UserModel.h"
#import "PaddingLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "../ChangePasswordViewController.h"
#import "../../SOAPHandler/SOAPHandler.h"
#import "../../SOAPHandler/PresetSOAPMessage.h"
#import <FacebookSDK/FacebookSDK.h>
#import "../../Models/AccInfo.h"
#import "../../Utils/XSUtils.h"
#import "LSDetailBox.h"
#import "ChatViewController.h"
#import "../IAP/IAPViewController.h"

#import "../../AdNetwork/AdmobInterstitialHelper.h"


#define NIB_PINFO_CELL @"NIB_PINFO_CELL"
#define NIB_PLS_CELL @"NIB_PLS_CELL"
#define NIB_PTOP_CAOTHU_CELL @"NIB_PTOP_CAOTHU_CELL"
#define NIB_PTOP_DAIGIA_CELL @"NIB_PTOP_DAIGIA_CELL"


#define SEGMENTED_WIDTH 37
#define PERSONAL_INFO_HEIGHT 700





@interface PersonalInfoViewController () <UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate, FBLoginViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property(nonatomic, weak) IBOutlet UIView* lsDetailView;
@property(nonatomic, weak) IBOutlet UIView* infoView;
@property(nonatomic, weak) IBOutlet UIView* coverView;
@property(nonatomic, weak) IBOutlet UIImageView* backImg;

@property(nonatomic, weak) IBOutlet UIImageView* avatarImgView;
@property(nonatomic, weak) IBOutlet UILabel* accountNameLabel;
@property(nonatomic, weak) IBOutlet UILabel* numStarLabel;
@property(nonatomic, weak) IBOutlet UITableView* tableView;


@property(nonatomic, weak) IBOutlet UILabel* changePassLabel;

@property(nonatomic, weak) IBOutlet UIButton* changePassBtn;
@property(nonatomic, weak) IBOutlet UIButton* changeDispNameBtn;


@property(nonatomic, weak) IBOutlet UILabel* hdrAccountLabel_Localize;
@property(nonatomic, weak) IBOutlet UILabel* accountNameLabel_Localize;
@property(nonatomic, weak) IBOutlet UILabel* creditLabel_Localize;


@property(nonatomic, strong) NSString *dispNameOk;


// list
@property(nonatomic, strong) NSMutableArray *lsDuDoan;
@property(nonatomic, strong) NSMutableArray *topCaoThu;
@property(nonatomic, strong) NSMutableArray *topDaiGia;

@property(nonatomic, strong) AdmobInterstitialHelper* admobHelper;


@property(nonatomic, strong) SOAPHandler *soapHandler;

//model
@property(nonatomic, strong) UserModel *myInfo;

@property(nonatomic) BOOL fbLoggedIn;

@property(nonatomic) BOOL giftcodeClicked;

@end

@implementation PersonalInfoViewController



-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.segmentIndex = 0;
        self.lsDuDoan = [NSMutableArray new];
        self.topCaoThu = [NSMutableArray new];
        self.topDaiGia = [NSMutableArray new];
        
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.giftcodeClicked = NO;
        
        [self prepareDummyData];
        self.fbLoggedIn = NO;
        
        NSString* fbID = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_ID];
        if (fbID == nil) {
            // not login with Facebook, fetch info from server
//            [self fetchAccountInfo];
        } else {
            self.fbLoggedIn = YES;
        }
        
        [self fetchAccountInfo];
        
        self.admobHelper = [[AdmobInterstitialHelper alloc] init];
        
        
    }
    
    return self;
}

-(void) prepareDummyData
{
//    for(int i=0;i<10;i++) {
//        LsDuDoanModel *model = [LsDuDoanModel new];
//        model.ls_Date = @"12-3-15";
//        model.ls_Match = @"Liverpool vs MU";
//        model.ls_WinLost = @"Thắng";
//        [self.lsDuDoan addObject:model];
//    }
//    
//    for(int i=0;i<4;i++) {
//        LsDuDoanModel *model = [LsDuDoanModel new];
//        model.ls_Date = @"12-3-15";
//        model.ls_Match = @"Liverpool vs MU";
//        model.ls_WinLost = @"Thắng";
//        [self.topCaoThu addObject:model];
//    }
//    
//    for(int i=0;i<5;i++) {
//        LsDuDoanModel *model = [LsDuDoanModel new];
//        model.ls_Date = @"12-3-15";
//        model.ls_Match = @"Liverpool vs MU";
//        model.ls_WinLost = @"Thắng";
//        [self.topDaiGia addObject:model];
//    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;
    
    [self setupEventHandler];
    
    [self setupSegmentedView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    

    [self.infoView bringSubviewToFront:self.coverView];
    [self.infoView bringSubviewToFront:self.tableView];
    [self setupTableNibFiles];
    
    NSString* changePasswd = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-passwd-change.txt", @"Đổi mật khẩu")];
    NSString* changeName = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-name-change.txt", @"Đổi tên hiển thị")];
    
    [self.changePassBtn setTitle:changePasswd forState:UIControlStateNormal];
    [self.changeDispNameBtn setTitle:changeName forState:UIControlStateNormal];
    
    
    
    if (self.fbLoggedIn) {
        // logged in with Facebook, fetch info from server
        // fill data now
        self.accountNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_NAME];
        
        NSString* userId = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_ID];
        NSString *urlStr   = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userId];
        
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:urlStr]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 
                 
                 [XSUtils adjustUIImageView:self.avatarImgView image:image];
                 
                 [self.avatarImgView setImage:image];
                 

                 
             }
         }];
    }
    
    
//    [self inviteUserViaFacebook];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
    
    self.myInfo = [AccInfo sharedInstance].accModel;
    
    if(!self.fbLoggedIn) {
        self.accountNameLabel.text = self.myInfo.sHoTen;
    }
    
    self.numStarLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:self.myInfo.iBalance]];
    
    
    
    
    // get singleton value if there is any
    if([AccInfo sharedInstance].lsDuDoan) {
        self.lsDuDoan = [AccInfo sharedInstance].lsDuDoan;
    }
    
    
    if([AccInfo sharedInstance].topCaoThu) {
        self.topCaoThu = [AccInfo sharedInstance].topCaoThu;
    }
    
    if([AccInfo sharedInstance].topDaiGia) {
        self.topDaiGia = [AccInfo sharedInstance].topDaiGia;
    }
    
    // localize strings
    
    
    self.hdrAccountLabel_Localize.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-info.text", @"Tài khoản")];;
    self.accountNameLabel_Localize.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-name.text", @"Tên tài khoản")];
    self.creditLabel_Localize.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"acc-star.text", @"Số sao")];
}


-(void) inviteUserViaFacebook
{
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:NSLocalizedString(@"FBinviteMessage", @"LiveScore365")
     title:@"LiveScore365"
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Case A: Error launching the dialog or sending request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // Case B: User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 NSLog(@"Request Sent.");
             }
         }
     }
     ];
    
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setupEventHandler
{
    
    // back button event
    UITapGestureRecognizer *bcktap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    bcktap.numberOfTapsRequired = 1;
    self.backImg.userInteractionEnabled = YES;
    
    [self.backImg addGestureRecognizer:bcktap];
    
    
    
    if(!self.fbLoggedIn) {
        UITapGestureRecognizer* passTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChangePasswordClick:)];
        passTab.numberOfTapsRequired = 1;
        self.changePassLabel.userInteractionEnabled = YES;
        [self.changePassLabel addGestureRecognizer:passTab];
    } else {
        self.changePassLabel.hidden = YES;
        self.changeDispNameBtn.hidden = YES;
        self.changePassBtn.hidden = YES;
        
    }
    
    
}


-(void) setupSegmentedView
{
    
    NSString* tt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-i-info.text", @"Thông tin")];
    NSString* lsdd = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-history.text", @"Lịch sử dự đoán")];
    NSString* topdd = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-top-predictor.text", @"Top dự đoán")];
    
    PPiFlatSegmentItem* item1 = [[PPiFlatSegmentItem alloc] initWithTitle:tt andIcon:nil];
    PPiFlatSegmentItem* item2 = [[PPiFlatSegmentItem alloc] initWithTitle:lsdd andIcon:nil];
    PPiFlatSegmentItem* item3 = [[PPiFlatSegmentItem alloc] initWithTitle:topdd andIcon:nil];
    
    
    ZLog(@"view widthhh: %f", self.view.frame.size.width);
    
    
    PPiFlatSegmentedControl *segmented = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SEGMENTED_WIDTH) items:@[item1, item2, item3] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        ZLog(@"segment Index: %lu", segmentIndex);

        self.segmentIndex = segmentIndex;
        
        [self.tableView reloadData];
        
    } iconSeparation:0.0f];
    
    [segmented setSelected:YES segmentAtIndex:self.segmentIndex];
    
    UIColor* mycolor = [UIColor colorWithRed:222.0f/255.0 green:83.0f/255.0 blue:0.0f/255.0 alpha:1];;
    segmented.color = mycolor;
    segmented.borderWidth=0.5f;
    segmented.borderColor=mycolor;
    segmented.selectedColor=[UIColor colorWithRed:255.0f/255.0 green:255.0f/255.0 blue:255.0f/255.0 alpha:1];
    segmented.textAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:9],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    segmented.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:9],
                                       NSForegroundColorAttributeName:mycolor};
    
    
    
    
    [self.infoView addSubview:segmented];
}


-(void)setupTableNibFiles
{
    UINib *pinfoCell = [UINib nibWithNibName:@"PInfoTableViewCell" bundle:nil];
    [self.tableView registerNib:pinfoCell forCellReuseIdentifier:NIB_PINFO_CELL];
    
    
    UINib *pLSCell = [UINib nibWithNibName:@"LSDuDoanTableViewCell" bundle:nil];
    [self.tableView registerNib:pLSCell forCellReuseIdentifier:NIB_PLS_CELL];
    
    UINib *pTopCTCell = [UINib nibWithNibName:@"TopCaoThuTableViewCell" bundle:nil];
    [self.tableView registerNib:pTopCTCell forCellReuseIdentifier:NIB_PTOP_CAOTHU_CELL];
    
    UINib *pTopDGCell = [UINib nibWithNibName:@"TopDaiGiaTableViewCell" bundle:nil];
    [self.tableView registerNib:pTopDGCell forCellReuseIdentifier:NIB_PTOP_DAIGIA_CELL];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.destructiveButtonIndex) {
        // clear cached data
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
        
        NSString* fbID = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_ID];
        if (fbID != nil) {
            // user logged in with FB
            
            [self doFBLogout];
            
        } else {
            NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
            
            if(keyReg!=nil) {
                // login with sms option
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self clearUserPreference]; // khanh add to clear everything relating to fb session if there is any info existed
            }
            
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


-(IBAction)onLogoutClick:(id)sender
{
    if(!self.fbLoggedIn) {
        UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Logout" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil, nil];
        [action showInView:self.view];
    } else {
        [self doFBLogout];
    }
      
    
}

-(IBAction)doFBLogout
{
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

-(void) onBackClick:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma Table view for personal info view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentIndex == 1 || self.segmentIndex == 2) {
        
        return 44.f;
    }
    return PERSONAL_INFO_HEIGHT;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.segmentIndex == 2) {
        return 2;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.segmentIndex != 2) {
        // only use header for segmentIndex = 2
        return nil;
    }
    
//    "acc-top-ct" = "Top cao thủ";
//    "acc-top-money" = "Top đại gia";
//
//    
    if(section == 0) {
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-top-ct", @"Top cao thủ")];
        return localizedTxt;
    } else if(section == 1) {
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-top-money", @"Top đại gia")];
        return localizedTxt;
    } else  {
        return @"titleForHeaderInSection";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentIndex == 1) {
        return self.lsDuDoan.count + 1;
    } else if(self.segmentIndex == 2) {
        if(section == 0) {
            return self.topCaoThu.count;
        } else {
            return self.topDaiGia.count;
        }
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    PInfoTableViewCell* cell = [[PInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL_INFO"];
    UITableViewCell *cell = nil;
    if(self.segmentIndex == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PINFO_CELL];
        [self fillDataForMyInfo:(PInfoTableViewCell*)cell cellForRowAtIndexPath:indexPath];
    } else if(self.segmentIndex == 1) {
        
        if(indexPath.row > 0) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PLS_CELL];
        } else {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LSDuDoanTableViewCell" owner:nil options:nil] objectAtIndex:0];
        }
        
        if(indexPath.row % 2 == 0) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:(224/255.f) green:(224/255.f) blue:(224/255.f) alpha:0.9f];
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        
        [self fillDataForLSDuDoan:(LSDuDoanTableViewCell*)cell cellForRowAtIndexPath:indexPath];
        
    } else if(self.segmentIndex == 2) {
        if(indexPath.section == 0) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PTOP_CAOTHU_CELL];
            [self fillDataForTopCaoThu:(TopCaoThuTableViewCell*)cell cellForRowAtIndexPath:indexPath];
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PTOP_DAIGIA_CELL];
            [self fillDataForTopDaiGia:(TopDaiGiaTableViewCell*)cell cellForRowAtIndexPath:indexPath];
        }
        
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL_INFO"];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.segmentIndex == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if(self.lsDuDoan.count >= 1 && indexPath.row > 0) {
            [self showLSDetailBox:indexPath];
        }
        
        
    }
}

-(void) showLSDetailBox:(NSIndexPath *)indexPath
{
    LsDuDoanModel *model = [self.lsDuDoan objectAtIndex:(indexPath.row-1)];
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    coverView.backgroundColor = [UIColor colorWithRed:207/255 green:207/255 blue:207/255 alpha:0.5f];
    
    LSDetailBox *box = [[[NSBundle mainBundle] loadNibNamed:@"LSDetailBox" owner:nil options:nil] objectAtIndex:0];
    box.layer.cornerRadius = 5;
    box.layer.masksToBounds = YES;
    
    box.layer.borderWidth = 1.0f;
    box.layer.borderColor = [UIColor blackColor].CGColor;
    
    
    box.center = coverView.center;
    
    
    NSString* retKeo = @"";
    if(model.iKeo > 0) {
        retKeo = [NSString stringWithFormat:@"+%.2f", model.iKeo];
    } else {
        retKeo = [NSString stringWithFormat:@"%.2f", model.iKeo];
    }
    
    
    // fill data now
    box.ls_DateLabel.text = model.ls_Date;
    box.ls_MatchLabel.text = model.ls_Match;
    
    
    if (model.iLoaiBet == 0) {
        box.ls_keoLabel.text = model.ls_Keo;
        box.ls_selectedTeam.text = [NSString stringWithFormat:@"%@ %@ %@", model.ls_Selection, @"@", retKeo];
        
    } else if(model.iLoaiBet == 1) {
        // chau Au
        box.ls_keoLabel.text = @"1 X 2";
        if(model.iBetSelect == 1) {
            box.ls_selectedTeam.text = @"1";
        } else if(model.iBetSelect == 0) {
            box.ls_selectedTeam.text = @"X";
        } else if(model.iBetSelect == 2) {
            box.ls_selectedTeam.text = @"2";
        }
    } else if(model.iLoaiBet == 2) {
        // tai xiu
        NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-UO", @"Under - Over")];
        box.ls_keoLabel.text = abbrWin;
        if(model.iBetSelect == 1) {
            NSString* abbrUnder = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-xiu-txt", @"Under - Under")];
            
            box.ls_selectedTeam.text = [NSString stringWithFormat:@"%@ %.2f", abbrUnder, model.iKeo];;
        } else if(model.iBetSelect == 2) {
            NSString* abbrOver = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-tai-txt", @"Under - Over")];
            box.ls_selectedTeam.text = [NSString stringWithFormat:@"%@ %.2f", abbrOver, model.iKeo];
        }
    }
    
    
    box.ls_keoLabel.text = [NSString stringWithFormat:@"%@ %@[%d - %d]", box.ls_keoLabel.text,@"@", model.iTySoDoiNha_Bet, model.iTySoDoiKhach_Bet];
    
    
    
    NSString* saoDat = [NSString stringWithFormat:@"%@ ☆ %@%.2f", [XSUtils format_iBalance:model.ls_SoSaoDat], @"@",model.iTyLeTien];
    NSString* saoNhan = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
    
    box.ls_iBetLabel.text = saoDat;
    
    
    box.dateMatchLabel_Val.text = model.ls_Date_KickOff;
    
    
    
    if (model.ls_SoSaoNhan > 0) {
        box.ls_iRecvLabel.text = [NSString stringWithFormat:@"+%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
    } else {
        box.ls_iRecvLabel.text = saoNhan;
    }
    
    box.ls_kqLabel.text = model.ls_WinLost;
    
    if (model.iTySoDoiNha != -1 && model.iTySoDoiKhach != -1) {
        box.ls_tysoLabel.text = [NSString stringWithFormat:@"%d - %d", model.iTySoDoiNha, model.iTySoDoiKhach];
    } else {
        box.ls_tysoLabel.text = @"? - ?";
    }
    
    
    if ([model.ls_WinLost isEqualToString:@"T"]) {
        
        NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-win", @"Thắng")];
        box.ls_kqLabel.text = abbrWin;
        
        
        
        box.ls_kqLabel.textColor = [UIColor colorWithRed:19.0f/255.0 green:147.0f/255.0 blue:2.0f/255.0 alpha:1];;

    } else if ([model.ls_WinLost isEqualToString:@"B"]) {
        NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-lost", @"Thua")];
        box.ls_kqLabel.text = abbrWin;
        box.ls_kqLabel.textColor = [UIColor redColor];
    } else if ([model.ls_WinLost isEqualToString:@"C"]) {
        NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-pending", @"Chờ")];
        box.ls_kqLabel.text = abbrWin;
    }else if ([model.ls_WinLost isEqualToString:@"HUY"]) {
        NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-huy", @"Huỷ")];
        box.ls_kqLabel.text = abbrWin;

    }
    else {
        NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-draw", @"Hoà")];
        box.ls_kqLabel.text = abbrWin;
    }
    [box.okButton addTarget:self action:@selector(onOKClick_LSDetailBox:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // render box localize labels
    
    
    
    
    
    [coverView addSubview:box];
    [self.view addSubview:coverView];
    
    
    self.lsDetailView = coverView;
    
    [UIView beginAnimations:nil context:nil]; // begin animation
    [UIView setAnimationDuration:0.6];
    
    
    [UIView commitAnimations]; // commit animation
}

-(void)onOKClick_LSDetailBox:(id)sender{
    [self.lsDetailView removeFromSuperview];
}


-(void)fillDataForMyInfo:(PInfoTableViewCell*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.myInfo != nil) {
        cell.iSoLanDuDoan.text = self.myInfo.iSoLanDuDoan;
        cell.iSoLanDuDoanChoKQ.text = self.myInfo.iSoDuDoanChoKetQua;
        cell.iSoLanDuDoanThang.text = self.myInfo.iSoLanDuDoanThang;
        cell.iSoLanDuDoanThua.text = self.myInfo.iSoLanDuDoanThua;
        cell.iXuThang.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:[self.myInfo.iXuThang intValue]]];
        
        
        cell.iXuThua.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:[self.myInfo.iXuThua intValue]]];
        cell.iXuThuong.text = self.myInfo.iXuDuocThuong;
        cell.iXuTraLai.text = self.myInfo.iXuDuocTraLai;
        

//        cell.iSoLanDuDoanChoKQ.text = self.myInfo.iSoDuDoanChoKetQua;
        
        
        if (self.fbLoggedIn) {
            
            cell.playerName.text = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_NAME];
            cell.dNgaySinh.text = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_BIRTHDAY];
            cell.sEmail.text = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_EMAIL];
//            cell.sMobile.text = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_GENDER];
            cell.dGioiTinh.text = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_GENDER];
        } else {
            id obj = [[NSUserDefaults standardUserDefaults] objectForKey:ACOUNT_DISPLAY_NAME];
            cell.playerName.text = self.myInfo.username;
            if (obj) {
                cell.playerName.text = [AccInfo sharedInstance].accModel.username;
            }
            
            
            
            
            cell.dNgaySinh.text = self.myInfo.dNgaySinh;
            cell.sEmail.text = self.myInfo.sEmail;
            cell.sMobile.text = self.myInfo.sMobile;
            cell.dGioiTinh.text = !self.myInfo.bGioiTinh ? @"Nam" : @"Nữ";
        }
        
    }
}

-(void)fillDataForLSDuDoan:(LSDuDoanTableViewCell*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row > 0) {
        LsDuDoanModel *model = [self.lsDuDoan objectAtIndex:(indexPath.row-1)];
        cell.sttLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
        cell.dateLabel.text = model.ls_Date;
        cell.matchLabel.text = model.ls_Match;
        cell.keoLabel.text = @"";
        cell.selectionLabel.text = @"";
        cell.winlostLabel.text = model.ls_WinLost;
        
        
        if ([model.ls_WinLost isEqualToString:@"C"]) {
            NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-pending", @"Chờ")];
            
            cell.winlostLabel.text = abbrWin;
            cell.winlostLabel.textColor = [UIColor blackColor];
        }else if ([model.ls_WinLost isEqualToString:@"HUY"]) {
            cell.winlostLabel.textColor = [UIColor blackColor];
            NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-huy", @"Huỷ")];
            cell.winlostLabel.text = abbrWin;
        }else if ([model.ls_WinLost isEqualToString:@"B"]) {
            cell.winlostLabel.textColor = [UIColor redColor];
//            cell.winlostLabel.text = @"Thua";
            if (model.ls_SoSaoNhan > 0) {
                cell.winlostLabel.text = [NSString stringWithFormat:@"+%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
            } else {
                cell.winlostLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
            }
            

            
            
        } else if ([model.ls_WinLost isEqualToString:@"H"]) {
            cell.winlostLabel.textColor = [UIColor blackColor];
            cell.winlostLabel.text = @"Hoà";
            
            if (model.ls_SoSaoNhan > 0) {
                cell.winlostLabel.text = [NSString stringWithFormat:@"+%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
            } else {
                cell.winlostLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
            }
        } else {
            cell.winlostLabel.textColor = [UIColor colorWithRed:19.0f/255.0 green:147.0f/255.0 blue:2.0f/255.0 alpha:1];;
            cell.winlostLabel.text = @"Thắng";
            
            if (model.ls_SoSaoNhan > 0) {
                cell.winlostLabel.text = [NSString stringWithFormat:@"+%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
            } else {
                cell.winlostLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:model.ls_SoSaoNhan]];
            }
        }
        
        
        
    } else {
        ZLog(@"indexPath = 0");
        
    }
    
}
-(void)fillDataForTopCaoThu:(TopCaoThuTableViewCell*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 != 0) {
        cell.bodyView.backgroundColor = [UIColor colorWithRed:(224/255.f) green:(224/255.f) blue:(224/255.f) alpha:0.9f];
    } else {
        cell.bodyView.backgroundColor = [UIColor whiteColor];
    }
    
    
    NSString* abbrWin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-win", @"Thắng")];
    NSString* abbrLost = [NSString stringWithFormat:@"%@", NSLocalizedString(@"acc-ls-detail-box-abbr-lost", @"Thua")];
    
    
    __weak TopCaoThuTableViewCell *tmpCell = cell;
    UserModel* model = [self.topCaoThu objectAtIndex:indexPath.row];
    
    cell.playerNameLabel.text = model.displayName;
    cell.winLabel.text = [NSString stringWithFormat:@"%@: %@", abbrWin, model.iSoLanDuDoanThang];
    cell.lostLabel.text = [NSString stringWithFormat:@"%@: %@", abbrLost, model.iSoLanDuDoanThua];
    
    UILabel *userRank = [[UILabel alloc] initWithFrame:cell.cupImageView.frame];
    [cell.bodyView addSubview:userRank];
    [cell.bodyView sendSubviewToBack:userRank];
    if(indexPath.row == 0) {
        cell.cupImageView.alpha = 1.0f;
        cell.cupImageView.image = [UIImage imageNamed:@"ic_gold_cup.png"];
        
    }
    else if (indexPath.row == 1) {
        cell.cupImageView.alpha = 1.0f;
        cell.cupImageView.image = [UIImage imageNamed:@"ic_sliver_cup.png"];
    }
    else if (indexPath.row == 2) {
        cell.cupImageView.alpha = 1.0f;
        cell.cupImageView.image = [UIImage imageNamed:@"ic_dong_cup.png"];
        
    }
    else {
        cell.cupImageView.alpha = 0.0f;
        userRank.backgroundColor = [UIColor grayColor];
        userRank.textColor= [UIColor whiteColor];
        userRank.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
        userRank.font = [UIFont fontWithName:@"UTMNeoSansIntelBold" size:25.f];
        userRank.textAlignment = NSTextAlignmentCenter;
        
    }
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:model.sAvatas]
                                               options:0
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             
             tmpCell.avatarImageView.image = image;
             
         }
     }];
    
}
-(void)fillDataForTopDaiGia:(TopDaiGiaTableViewCell*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 != 0) {
        cell.bodyView.backgroundColor = [UIColor colorWithRed:(224/255.f) green:(224/255.f) blue:(224/255.f) alpha:0.9f];
    }
    else {
        cell.bodyView.backgroundColor = [UIColor whiteColor];
    }
    
    UserModel* model = [self.topDaiGia objectAtIndex:indexPath.row];
    

    
    __weak TopDaiGiaTableViewCell *tmpCell = cell;
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:model.sAvatas]
                                               options:0
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             
             tmpCell.avatarImageView.image = image;
             
         }
     }];
    cell.playerNameLabel.text = model.displayName;
    cell.starLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:model.iBalance]];
    UILabel *userRank = [[UILabel alloc] initWithFrame:cell.cupImageView.frame];
    [cell.bodyView addSubview:userRank];
    [cell.bodyView sendSubviewToBack:userRank];
    if(indexPath.row == 0) {
        cell.cupImageView.alpha = 1.0f;
        cell.cupImageView.image = [UIImage imageNamed:@"ic_gold_cup.png"];
        
    }
    else if (indexPath.row == 1) {
        cell.cupImageView.alpha = 1.0f;
        cell.cupImageView.image = [UIImage imageNamed:@"ic_sliver_cup.png"];
    }
    else if (indexPath.row == 2) {
        cell.cupImageView.alpha = 1.0f;
        cell.cupImageView.image = [UIImage imageNamed:@"ic_dong_cup.png"];
    }
    else {
        cell.cupImageView.alpha = 0.0f;
        userRank.backgroundColor = [UIColor grayColor];
        userRank.textColor= [UIColor whiteColor];
        userRank.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
        userRank.font = [UIFont fontWithName:@"UTMNeoSansIntelBold" size:25.f];
        userRank.textAlignment = NSTextAlignmentCenter;
        
    }
    
}


-(void) changeDisplayName:(NSString*)dispName
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.changeTitle", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        if (account!=nil && dispName.length > 1) {
            [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage get_wsUsers_Change_Title_Message:account dispName:dispName] soapAction:[PresetSOAPMessage get_wsUsers_Change_Title_SoapAction]];   
        }
    });
}


-(void)fetchAccountInfo
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.chuyengia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        if (account!=nil) {
            [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getAccountInfoMessage:account] soapAction:[PresetSOAPMessage getAccountInfoSoapAction]];
            
            [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_ThongTinDuDoan_Message:account] soapAction:[PresetSOAPMessage get_wsFootBall_ThongTinDuDoan_SoapAction]];
            
            
            
            // lich su du doan
            [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_List_LichSu_DuDoan_Message:account] soapAction:[PresetSOAPMessage get_wsFootBall_List_LichSu_DuDoan_SoapAction]];
            
            // top cao thu du doan
            [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_List_TopCaoThu_DuDoan_Message] soapAction:[PresetSOAPMessage get_wsFootBall_List_TopCaoThu_DuDoan_SoapAction]];
            
            // top dai gia
            [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage getTopCaoThuMessage] soapAction:[PresetSOAPMessage getTopCaoThuSoapAction]];
            
        }
        
       
        
    });
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
                userModel.sHoTen = (sHoTen!=nil && ![sHoTen isEqualToString:@""]) ? sHoTen : userModel.username;
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
            
            self.myInfo = userModel;
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [AccInfo sharedInstance].iBalance = userModel.iBalance;
                [AccInfo sharedInstance].accModel = userModel;
                [AccInfo sharedInstance].dispName = userModel.sHoTen;
                [[NSUserDefaults standardUserDefaults] setObject:userModel.sHoTen forKey:ACOUNT_DISPLAY_NAME];
                
                [self.tableView reloadData];
                
                if(!self.fbLoggedIn) {
                    self.accountNameLabel.text = userModel.sHoTen;
                }
                
                
                self.numStarLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:userModel.iBalance]];
                
                
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
}



-(void) handle_wsUsers_Top_XuResult:(NSString*)xmlData
{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_Top_XuResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_Top_XuResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);//NhanDinhChuyenGiaController
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            

            
            [self.topDaiGia removeAllObjects];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                NSString* displayName = [dict objectForKey:@"UserName"];
                NSString* dispNameTmp = [dict objectForKey:@"sHoTen"];
                NSUInteger iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] integerValue];
                NSUInteger iBalance_Snap = [(NSNumber*)[dict objectForKey:@"iBalance_Snap"] integerValue];
                NSUInteger iBalance_Hao = [(NSNumber*)[dict objectForKey:@"iBalance_Hao"] integerValue];
                id sAvatas = [dict objectForKey:@"sAvatas"];
                NSUInteger UserId = [(NSNumber*)[dict objectForKey:@"UserId"] integerValue];
                NSString* Provider = [dict objectForKey:@"Provider"];
                
                
                UserModel* model = [UserModel new];
                model.UserId = UserId;
                model.username = displayName;
                
                
                
                
                if ([dispNameTmp isKindOfClass:[NSNull class]] || dispNameTmp == nil) {
                    model.displayName = displayName;
                } else {
                    model.displayName = dispNameTmp;
                }
                
                
                if ([sAvatas isKindOfClass:[NSNull class]] || sAvatas == nil) {
                    model.sAvatas = @"";
                } else {
                    model.sAvatas = sAvatas;
                }
                
                
                
                if ([Provider isKindOfClass:[NSNull class]] || Provider == nil) {
                } else if([Provider isEqualToString:@"facebook"]) {
                    model.isFb =  YES;
                    NSString *urlStr   = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", displayName];
                    
                    model.sAvatas = urlStr;
                }
                
                model.iBalance = iBalance;
                model.iBalance_Hao = iBalance_Hao;
                model.iBalance_Snap = iBalance_Snap;
                
                
                [self.topDaiGia addObject:model];
                
                
                
            }
            [AccInfo sharedInstance].topDaiGia = self.topDaiGia;

            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
                
                
                
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
}

-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        
        if ([xmlData rangeOfString:@"<wsUsers_ThongTinResult>"].location != NSNotFound) {
            // user info
            [self handle_wsUsers_ThongTinResult:xmlData];
        } else if([xmlData rangeOfString:@"<wsUsers_Top_XuResult>"].location != NSNotFound) {
            // top dai gia
            [self handle_wsUsers_Top_XuResult:xmlData];
        } else if([xmlData rangeOfString:@"<wsFootBall_List_LichSu_DuDoanResult>"].location != NSNotFound) {
            // lich su du doan
            [self handle_wsFootBall_List_LichSu_DuDoanResult:xmlData];
        }else if([xmlData rangeOfString:@"<wsFootBall_List_TopCaoThu_DuDoanResult>"].location != NSNotFound)
        {
            // top cao thu du doan
            [self handle_wsFootBall_List_TopCaoThu_DuDoanResult:xmlData];
        } else if([xmlData rangeOfString:@"<wsUsers_Change_TitleResult>"].location != NSNotFound) {
            [self handle_wsUsers_Change_TitleResult:xmlData];
        } else if([xmlData rangeOfString:@"<wsUsers_TangSaoResult>"].location != NSNotFound) {
            [self handle_wsUsers_TangSaoResult:xmlData];
        } else if([xmlData rangeOfString:@"<wsFootBall_ThongTinDuDoanResult>"].location != NSNotFound) {

            [self handle_wsFootBall_ThongTinDuDoanResult:xmlData];
        }
        else {
            ZLog(@"unhandle responseee: %@", xmlData);
        }
        
        
        
        
        
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
}


-(void)clearUserPreference
{
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


- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    ZLog(@"FB logoouttttt");
    
    [self clearUserPreference];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onChangePasswordClick:(id)sender
{
    ChangePasswordViewController* vc = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)onChangeDisplayNameClick:(id)sender
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"change_display_name_dialog_title", @"Đổi tên hiển thị")
                                                          message:NSLocalizedString(@"change_display_name_dialog_msg", @"Xin mời nhập tên hiển thị mới:") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [myAlertView textFieldAtIndex:0];
    
    textField.textAlignment = NSTextAlignmentCenter;
//    [textField becomeFirstResponder];
    


    [myAlertView show];
   
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    @try {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if(textField && textField.text.length > 0 && buttonIndex == 1) {
            // submit new display name to server now
            NSString* dispName = textField.text;
            ZLog(@"textfield: %@", dispName);
            self.dispNameOk = dispName;
            [self changeDisplayName:dispName];
        } else if(textField == nil) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                [self fetchGiftcodeSubmitted];
            }
        }
    }
    @catch (NSException *exception) {
        // error
        ZLog(@"exception: %@", exception);
        
        
    }
    
    
}


-(void) handle_wsFootBall_List_LichSu_DuDoanResult:(NSString*)xmlData {
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_List_LichSu_DuDoanResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_List_LichSu_DuDoanResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);//NhanDinhChuyenGiaController
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            
            [self.lsDuDoan removeAllObjects];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                NSUInteger iSoSao = [(NSNumber*)[dict objectForKey:@"iSoSao"] integerValue];
                int iSoSaoNhan = [(NSNumber*)[dict objectForKey:@"iSoSaoNhan"] intValue];
                NSString* sTenDoi = [dict objectForKey:@"sTenDoi"];
                NSString* sTenTran = [dict objectForKey:@"sTenTran"];
                
                NSUInteger iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] integerValue];
                NSUInteger iID_MaSetBet = [(NSNumber*)[dict objectForKey:@"iID_MaSetBet"] integerValue];
                NSUInteger iLoaiSet = [(NSNumber*)[dict objectForKey:@"iLoaiSet"] intValue];
                NSString* sThangThua = [dict objectForKey:@"sThangThua"];
                NSUInteger iID_MaDoi = [(NSNumber*)[dict objectForKey:@"iID_MaDoi"] integerValue];
                NSString* sUserName = [dict objectForKey:@"sUserName"];
                NSString* sNgayDat = [dict objectForKey:@"sNgayDat"];
                NSString* sKeo = [dict objectForKey:@"sKeo"];
                
                int iTySoDoiNha = [(NSNumber*)[dict objectForKey:@"iTySoDoiNha"] intValue];
                int iTySoDoiKhach = [(NSNumber*)[dict objectForKey:@"iTySoDoiKhach"] intValue];
                
                
                int iTySoDoiNha_Bet = [(NSNumber*)[dict objectForKey:@"iTySoDoiNha_Bet"] intValue];
                int iTySoDoiKhach_Bet = [(NSNumber*)[dict objectForKey:@"iTySoDoiKhach_Bet"] intValue];
                
                
                float iKeo = [(NSNumber*)[dict objectForKey:@"iKeo"] floatValue];
                
                
                float iTyLeTien = [(NSNumber*)[dict objectForKey:@"iTyLeTien"] floatValue];
                int iBetSelect = [(NSNumber*)[dict objectForKey:@"iBetSelect"] intValue];
                int iLoaiBet = [(NSNumber*)[dict objectForKey:@"iLoaiBet"] intValue];
                
                
                long IC0 = [(NSNumber*)[dict objectForKey:@"iC0"] longValue];
                NSDate *IC0_date = [NSDate dateWithTimeIntervalSince1970:IC0];

                
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"HH:mm, dd-MM"];
                
                
                
                
                LsDuDoanModel* model = [LsDuDoanModel new];
                model.ls_Date = sNgayDat;
                model.ls_Match = sTenTran;
                model.ls_WinLost = sThangThua;
                model.ls_SoSaoDat = iSoSao;
                model.ls_Selection = sTenDoi;
                model.ls_SoSaoNhan = iSoSaoNhan;
                model.iTySoDoiKhach = iTySoDoiKhach;
                model.iTySoDoiNha = iTySoDoiNha;
                model.iKeo = iKeo;
                model.ls_Date_KickOff = [dateFormatter stringFromDate:IC0_date];
                
                model.iTySoDoiNha_Bet = iTySoDoiNha_Bet;
                model.iTySoDoiKhach_Bet = iTySoDoiKhach_Bet;
                
                
                model.iBetSelect = iBetSelect;
                model.iLoaiBet = iLoaiBet;
                model.iTyLeTien = iTyLeTien;
                
                if ([sKeo isKindOfClass:[NSNull class]]) {
                    //
                    model.ls_Keo = @"";
                } else {
                    model.ls_Keo = sKeo;
                }
                
                [self.lsDuDoan addObject:model];
                
            }
            
            
            [AccInfo sharedInstance].lsDuDoan = self.lsDuDoan;
            
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
}
-(void) handle_wsFootBall_List_TopCaoThu_DuDoanResult:(NSString*)xmlData
{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_List_TopCaoThu_DuDoanResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_List_TopCaoThu_DuDoanResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);//NhanDinhChuyenGiaController
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            [self.topCaoThu removeAllObjects];
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                NSString* displayName = [dict objectForKey:@"sUserName"];
                NSString* dispNameTmp = [dict objectForKey:@"sHoTen"];
                NSUInteger iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] integerValue];
                NSUInteger iBalance_Snap = [(NSNumber*)[dict objectForKey:@"iBalance_Snap"] integerValue];
                NSUInteger iBalance_Hao = [(NSNumber*)[dict objectForKey:@"iBalance_Hao"] integerValue];
                id sAvatas = [dict objectForKey:@"sAvata"];
                NSUInteger UserId = [(NSNumber*)[dict objectForKey:@"UserId"] integerValue];
                
                NSString* iSoLanDuDoanThang = [dict objectForKey:@"iTranThang"];
                NSString* iSoLanDuDoanThua = [dict objectForKey:@"iTranThua"];
                if ([iSoLanDuDoanThua isKindOfClass:[NSNull class]]) {
                    iSoLanDuDoanThua = @"0";
                }
                if ([iSoLanDuDoanThang isKindOfClass:[NSNull class]]) {
                    iSoLanDuDoanThang = @"0";
                }
                NSString* Provider = [dict objectForKey:@"Provider"];
                
                
                
                UserModel* model = [UserModel new];
                model.UserId = UserId;
                model.username = displayName;
                
                if ([dispNameTmp isKindOfClass:[NSNull class]] || dispNameTmp == nil) {
                    model.displayName = displayName;
                } else {
                    model.displayName = dispNameTmp;
                }
                
                if ([sAvatas isKindOfClass:[NSNull class]] || sAvatas == nil) {
                    model.sAvatas = @"";
                } else {
                    model.sAvatas = sAvatas;
                }
                
                
                if ([Provider isKindOfClass:[NSNull class]] || Provider == nil) {
                } else if([Provider isEqualToString:@"facebook"]) {
                    model.isFb =  YES;
                    NSString *urlStr   = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", displayName];
                    
                    model.sAvatas = urlStr;
                }
                
                model.iSoLanDuDoanThang = iSoLanDuDoanThang;
                model.iSoLanDuDoanThua = iSoLanDuDoanThua;
                
//                model.iBalance = iBalance;
//                model.iBalance_Hao = iBalance_Hao;
//                model.iBalance_Snap = iBalance_Snap;
                
                
                [self.topCaoThu addObject:model];
                
            }
            
            [AccInfo sharedInstance].topCaoThu = self.topCaoThu;
            
            
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
}

-(void)handle_wsUsers_TangSaoResult:(NSString*)xmlData{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_TangSaoResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_TangSaoResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);//NhanDinhChuyenGiaController
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        NSString* message = @"";
        int iSao = 0;
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            [self.topCaoThu removeAllObjects];
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                message = [dict objectForKey:@"mess"];
                iSao = [(NSNumber*)[dict objectForKey:@"iSao"] intValue];
            }
        }
        
        

        [AccInfo sharedInstance].iBalance += iSao;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.myInfo) {
                self.myInfo.iBalance = [AccInfo sharedInstance].iBalance;
            }
            
            self.numStarLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:[AccInfo sharedInstance].iBalance]];
        });
        
        [self showDialogAlert:nil message:message];
        
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
}

-(void)handle_wsFootBall_ThongTinDuDoanResult:(NSString*)xmlData{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_ThongTinDuDoanResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_ThongTinDuDoanResult>"] objectAtIndex:0];
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            UserModel* userModel = [UserModel new];
            if(self.myInfo) {
                userModel= self.myInfo;
            }
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                NSString* username = [dict objectForKey:@"UserName"];
                NSString* sHoTen = [dict objectForKey:@"sHoTen"];
                NSUInteger iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] integerValue];
//                NSUInteger iBalance_Snap = [(NSNumber*)[dict objectForKey:@"iBalance_Snap"] integerValue];
                NSUInteger iBalance_Hao = [(NSNumber*)[dict objectForKey:@"iBalance_Hao"] integerValue];
//                NSString* dNgaySinh = [dict objectForKey:@"dNgaySinh"];;
//                NSString* bGioiTinh = [dict objectForKey:@"bGioiTinh"];;
//                NSString* sEmail = [dict objectForKey:@"sEmail"];
//                NSString* sMobile = [dict objectForKey:@"sMobile"];
                
                int iSoLanDuDoan = [(NSNumber*)[dict objectForKey:@"iSoLanDuDoan"] intValue];
                int iSoLanDuDoanThang = [(NSNumber*)[dict objectForKey:@"iSoLanDuDoanThang"] intValue];
                int iSoLanDuDoanThua = [(NSNumber*)[dict objectForKey:@"iSoLanDuDoanThua"] intValue];
                int iSoDuDoanChoKetQua = [(NSNumber*)[dict objectForKey:@"iSoDuDoanChoKetQua"] intValue];
                int iXuThang = [(NSNumber*)[dict objectForKey:@"iXuThang"] intValue];
                int iXuThua = [(NSNumber*)[dict objectForKey:@"iXuThua"] intValue];
                int iXuDuocThuong = [(NSNumber*)[dict objectForKey:@"iXuDuocThuong"] intValue];
                int iXuDuocTraLai = [(NSNumber*)[dict objectForKey:@"iXuDuocTraLai"] intValue];
                
                
                
                userModel.username = (username!=nil) ? username : @"";
                userModel.sHoTen = (sHoTen!=nil) ? sHoTen : @"";
                userModel.iBalance = iBalance;
                userModel.iBalance_Hao = iBalance_Hao;

                /*
                userModel.dNgaySinh = (![dNgaySinh isKindOfClass:[NSNull class]]) ? dNgaySinh : @"";
                userModel.bGioiTinh = [bGioiTinh boolValue];
                userModel.sEmail = (![sEmail isKindOfClass:[NSNull class]]) ? sEmail : @"";
                userModel.sMobile = (![sMobile isKindOfClass:[NSNull class]]) ? sMobile : @"";;
                 */
                
                userModel.iSoLanDuDoan = [NSString stringWithFormat:@"%d", iSoLanDuDoan];
                userModel.iSoLanDuDoanThang =[NSString stringWithFormat:@"%d", iSoLanDuDoanThang];
                userModel.iSoLanDuDoanThua =[NSString stringWithFormat:@"%d", iSoLanDuDoanThua];
                userModel.iXuThang =[NSString stringWithFormat:@"%d", iXuThang];
                userModel.iXuThua =[NSString stringWithFormat:@"%d", iXuThua];
                userModel.iXuDuocThuong =[NSString stringWithFormat:@"%d", iXuDuocThuong];
                userModel.iXuDuocTraLai =[NSString stringWithFormat:@"%d", iXuDuocTraLai];
                userModel.iSoDuDoanChoKetQua =[NSString stringWithFormat:@"%d", iSoDuDoanChoKetQua];
                
                
                
            }
            
            self.myInfo = userModel;
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [AccInfo sharedInstance].iBalance = userModel.iBalance;
                [AccInfo sharedInstance].accModel = userModel;
                [AccInfo sharedInstance].dispName = userModel.sHoTen;
                [[NSUserDefaults standardUserDefaults] setObject:userModel.sHoTen forKey:ACOUNT_DISPLAY_NAME];
                
                [self.tableView reloadData];
                
                self.numStarLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:userModel.iBalance]];
                
                
            });
            
            
            
        }
        
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
}



-(void)handle_wsUsers_Change_TitleResult:(NSString*)xmlData
{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsUsers_Change_TitleResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsUsers_Change_TitleResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);//NhanDinhChuyenGiaController
        
        
        if ([jsonStr isEqualToString:@"1"]) {
            
            NSString* okMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"change_display_name_alert_ok", @"Chúc mừng bạn đã đổi tên thành công!")];
            
            
            [self showDialogAlert:nil message:okMsg];
            [AccInfo sharedInstance].dispName = self.dispNameOk;
            [[NSUserDefaults standardUserDefaults] setObject:self.dispNameOk forKey:ACOUNT_DISPLAY_NAME];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } else {
            
            NSString* fMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"change_display_name_alert_failed", @"Đổi tên không thành công. Vui long thử lại!")];
            NSString* tMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"change_display_name_alert_title_failed", @"Lỗi xảy ra")];
            
            
            [self showDialogAlert:tMsg message:fMsg];
        }
        
        
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
}

-(void)showDialogAlert:(NSString*)title message:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    });
}


-(void)showVideoAdsHint {
    
    //video_ads_watch_now
    NSString* vTitle = [NSString stringWithFormat:@"%@", NSLocalizedString(@"video_ads_title", @"Video ads title")];
    NSString* vHint = [NSString stringWithFormat:@"%@", NSLocalizedString(@"video_ads_hint", @"Video ads hint")];
    NSString* watchNow = [NSString stringWithFormat:@"%@", NSLocalizedString(@"video_ads_watch_now", @"Video ads hint")];
    NSString* cancelBtn = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Video ads hint")];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:vTitle message:vHint delegate:self cancelButtonTitle:cancelBtn otherButtonTitles:watchNow, nil];
    [alert show];
}

-(void)fetchGiftcodeSubmitted {
    
    [self.admobHelper show:self];
    
    if (!self.giftcodeClicked) {
        self.giftcodeClicked = YES;
    } else {
        return;
    }
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.chuyengia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        if (account!=nil) {
            // top dai gia
            NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            if (list.count > 0) {
                [self.soapHandler sendSOAPRequestRegistration:[PresetSOAPMessage get_wsUsers_TangSao_Message:account sLang:[list objectAtIndex:0]] soapAction:[PresetSOAPMessage get_wsUsers_TangSao_SoapAction]];
            }
            
            
        }
        
        
        
    });
}


-(IBAction)onGiftcodeClick:(id)sender {
    
    
    [self showVideoAdsHint];
    
    
}


// event handler
-(IBAction)onHomeClick:(id)sender
{
    // go to live score now
//    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HOME_CLICKED" object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)onChatRoomClick:(id)sender {
    // open chat room
    ChatViewController *chat = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    [self.navigationController pushViewController:chat animated:YES];
}

-(IBAction)onInviteFBFriendsClick:(id)sender {

    [self inviteUserViaFacebook];
}

-(IBAction)onPurchaseItemClicked:(id)sender {
    IAPViewController *iapController = [[IAPViewController alloc] initWithNibName:@"IAPViewController" bundle:nil];
    
    [self.navigationController pushViewController:iapController animated:YES];
//    [self presentViewController:iapController animated:YES completion:nil];
}


@end
