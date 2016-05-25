//
//  GamePredictorViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "GamePredictorViewController.h"
#import "StatsViewController.h"
#import "../Common/xs_common_inc.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../Models/CountryModel.h"
#import "../Models/LivescoreModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "../Models/LivescoreGroupModel.h"
#import "BDLiveGestureRecognizer.h"
#import "LiveScoreHeaderSection.h"
#import "GameTableViewCell.h"
#import "UIGamePredictorRecognizer.h"
#import "Perform/PViewController.h"
#import "ExpertReview.h"
#import "SettingsViewController.h"
#import "../Models/AccInfo.h"
#import "LiveScoreViewController.h"
#import "GameAlertView.h"
#import "../AdNetwork/AdNetwork.h"


#define MAX_LENGTH_SAO_INPUT 10



static const int MATCH_ALL = 1;
static const int MATCH_NEXT = 2;
static const int MATCH_LIVE = 3;
static const int MATCH_FT = 4;


static const int _BET_CODE_SUCCESS_ = 1; // ok
static const int _BET_CODE_ERROR_EBANK_ = -2; // ebank ko cho them dữ liệu
static const int _BET_CODE_ERROR_BALANCE_ = -3; // balance not enough
static const int _BET_CODE_ERROR_GENERIC_ = -1; // general error
static const int _BET_CODE_ERROR_AUTHEN_ = -4; // not login yet
static const int _BET_CODE_ERROR_REQUIRE_MIN_100_ = -5; // not login yet

static NSString* nib_GameCell = @"nib_GameCell";






@interface GamePredictorViewController () <UITextFieldDelegate, UIAlertViewDelegate,UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate, UIActionSheetDelegate, GADBannerViewDelegate>

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) NSMutableDictionary* listLivescore;
@property(nonatomic, strong) NSMutableArray* listLivescoreKeys;


@property(nonatomic, strong) NSMutableDictionary* listLivescore_Filter;
@property(nonatomic, strong) NSMutableArray* listLivescoreKeys_Filter;

@property(atomic, strong) SDWebImageManager *manager;
@property(nonatomic) NSUInteger pageNum;
@property(nonatomic) NSUInteger totalPage;

@property(nonatomic) BOOL isEnglish;


@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) IBOutlet UIImageView *backImg;
@property(nonatomic, strong) IBOutlet UIImageView *loadingImg;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, strong) IBOutlet UILabel* hdrGameLabel;

@property(nonatomic) int filterType;

@end

@implementation GamePredictorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.listLivescore = [NSMutableDictionary new];
        self.listLivescoreKeys = [NSMutableArray new];
        
        
        // filter
        self.listLivescore_Filter = [NSMutableDictionary new];
        self.listLivescoreKeys_Filter = [NSMutableArray new];
        
        
        self.pageNum = 0;
        self.isEnglish = YES;
        self.totalPage = 1;
        _manager = [SDWebImageManager sharedManager];
        
        
        self.filterType = MATCH_ALL;
        
        [self getListGamePredictor];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupEventHandler];
    
    
    // setup nib files
    UINib *gameCell = [UINib nibWithNibName:@"GameTableViewCell" bundle:nil];
    [self.tableView registerNib:gameCell forCellReuseIdentifier:nib_GameCell];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveScoreHeaderSection" bundle:nil] forHeaderFooterViewReuseIdentifier:@"LiveScoreHeaderSection"];
    // end setup nib files
    
    NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"hdr-game.txt", @"GAME DỰ ĐOÁN")];
    self.hdrGameLabel.text = localizeMsg;
    
    
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        NSString* lang = [list objectAtIndex:0];
        if ([lang isEqualToString:@"vi"]) {
            self.isEnglish = NO;
        } else {
            self.isEnglish = YES;
        }
    }
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
    
    [[AdNetwork sharedInstance] createAdMobBannerView:self admobDelegate:self tableView:self.tableView];
    
    

}

-(void)viewWillDisappear:(BOOL)animated
{
    
    self.selectedModel.highlightedGame = NO;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupEventHandler
{
    self.backImg.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    tap2.numberOfTapsRequired = 1;
    [self.backImg addGestureRecognizer:tap2];
    
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReloadClick:)];
    tap.numberOfTapsRequired = 1;
    self.loadingImg.userInteractionEnabled = YES;
    [self.loadingImg addGestureRecognizer:tap];
}

-(void)onBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onReloadClick:(id)sender
{
    self.loadingImg.hidden = YES;
    [self.loadingIndicator startAnimating];
    self.pageNum = 0;
    self.filterType = MATCH_ALL;
    self.totalPage = 1;
    
    [self getListGamePredictor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return self.listLivescore.count;
    
    if(self.filterType == MATCH_NEXT ||
       self.filterType == MATCH_LIVE ||
       self.filterType == MATCH_FT) {
        return self.listLivescoreKeys_Filter.count;
        
    } else {
        
    
        return self.listLivescoreKeys.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 210.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if(self.filterType == MATCH_NEXT ||
       self.filterType == MATCH_LIVE ||
       self.filterType == MATCH_FT) {
        NSString *sortedKey = [self.listLivescoreKeys_Filter objectAtIndex:section];
        NSArray *liveList = [self.listLivescore_Filter objectForKey:sortedKey];
        
        return liveList.count;
        
    } else {
        NSString *sortedKey = [self.listLivescoreKeys objectAtIndex:section];
        NSArray *liveList = [self.listLivescore objectForKey:sortedKey];
        
        return liveList.count;
    }
    
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    LiveScoreHeaderSection *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LiveScoreHeaderSection"];
    
    NSString *sortedKey = nil;
    NSArray *liveList = nil;
    
    LivescoreModel *model = nil;
    
    
    
    if(self.filterType == MATCH_NEXT ||
       self.filterType == MATCH_LIVE ||
       self.filterType == MATCH_FT) {
        sortedKey = [self.listLivescoreKeys_Filter objectAtIndex:section];
        liveList = [self.listLivescore_Filter objectForKey:sortedKey];
        model = [liveList objectAtIndex:0];
        
    } else {
        sortedKey = [self.listLivescoreKeys objectAtIndex:section];
        liveList = [self.listLivescore objectForKey:sortedKey];
        model = [liveList objectAtIndex:0];
    }
    
    
    
    view.aliasLabel.text = model.sTenGiai;
    
    
    
    
    
    BDLiveGestureRecognizer* tap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onBxhTap:)];
    tap.sTenGiai = view.aliasLabel.text;
    tap.iID_MaTran = sortedKey;
    tap.numberOfTapsRequired = 1;
    tap.logoGiaiUrl = model.sLogoGiai;
    view.bxhView.userInteractionEnabled = YES;
    [view.bxhView addGestureRecognizer:tap];
    
    if(model!= nil) {
        
        [self.manager downloadWithURL:[NSURL URLWithString:model.sLogoGiai]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 [XSUtils adjustUIImageView:view.countryFlag image:image];
                 
                 [view.countryFlag setImage:image];
                 
             }
         }];
    }
    
    
    return view;
    
    
}


-(void) setupEventHandlerForCell:(GameTableViewCell*) cell model:(LivescoreModel*)model {
    
    if(YES) {
        // bet cho chau A
        cell.g_asiaBtn_Nha.cell = cell;
        cell.g_asiaBtn_Nha.bet_type = 0;
        cell.g_asiaBtn_Nha.picked = 1;
        [cell.g_asiaBtn_Nha addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.g_asiaBtn_Khach.cell = cell;
        cell.g_asiaBtn_Khach.bet_type = 0;
        cell.g_asiaBtn_Khach.picked = 2;
        [cell.g_asiaBtn_Khach addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    
    if(YES) {
        // bet cho chau Au
        cell.g_1x2Btn_Nha.cell = cell;
        cell.g_1x2Btn_Nha.bet_type = 1;
        cell.g_1x2Btn_Nha.picked = 1;
        [cell.g_1x2Btn_Nha addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];

        
        
        cell.g_1x2Btn_Khach.cell = cell;
        cell.g_1x2Btn_Khach.bet_type = 1;
        cell.g_1x2Btn_Khach.picked = 2;
        [cell.g_1x2Btn_Khach addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        cell.g_xButton.cell = cell;
        cell.g_xButton.bet_type = 1;
        cell.g_xButton.picked = 0;
        [cell.g_xButton addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    
    
    if(YES) {
        // bet tai suu
        cell.g_underBtn.cell = cell;
        cell.g_underBtn.bet_type = 2;
        cell.g_underBtn.picked = 1;
        [cell.g_underBtn addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        cell.g_overBtn.cell = cell;
        cell.g_overBtn.bet_type = 2;
        cell.g_overBtn.picked = 2;
        [cell.g_overBtn addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}


-(void) fillData_TyLe_CaCuoc:(GameTableViewCell*) cell model:(LivescoreModel*)model {
    //    @"sTyLe_TaiSuu" : @"1.00*2 1/2*0.90"
    @try {
        NSArray* list = [model.sTyLe_TaiSuu componentsSeparatedByString:@"*"];
        cell.g_overTyle.text = [list objectAtIndex:0];
        cell.g_tyleTaiXiu.text = [list objectAtIndex:1];
        cell.g_underTyle.text = [list objectAtIndex:2];
    }
    @catch (NSException *exception) {
        //
    }
    
    
    //@"sTyLe_ChauAu" : @"1.87*3.45*4.65"
    @try {
        NSArray* list = [model.sTyLe_ChauAu componentsSeparatedByString:@"*"];
        cell.g_1x2Tyle_1.text = [list objectAtIndex:0];
        cell.g_1x2Tyle_x.text = [list objectAtIndex:1];
        cell.g_1x2Tyle_2.text = [list objectAtIndex:2];
    }
    @catch (NSException *exception) {
        //
    }
    
    
    //@"sTyLe_ChapBong" : @"0.87*0 : 1/2*-0.93"
    @try {
        NSArray* list = [model.sTyLe_ChapBong componentsSeparatedByString:@"*"];
        cell.g_asiaTyle_Nha.text = [list objectAtIndex:0];

        cell.g_asiaTyleKhach.text = [list objectAtIndex:2];
    }
    @catch (NSException *exception) {
        //
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:nib_GameCell];
    
    
    NSString *sortedKey = nil;
    NSArray *liveList = nil;
    
    LivescoreModel *model = nil;
    
    
    
    
    if(self.filterType == MATCH_NEXT ||
       self.filterType == MATCH_LIVE ||
       self.filterType == MATCH_FT) {
        sortedKey = [self.listLivescoreKeys_Filter objectAtIndex:indexPath.section];
        liveList = [self.listLivescore_Filter objectForKey:sortedKey];
        model = [liveList objectAtIndex:indexPath.row];
        
    } else {
        // all
        sortedKey = [self.listLivescoreKeys objectAtIndex:indexPath.section];
        liveList = [self.listLivescore objectForKey:sortedKey];
        model = [liveList objectAtIndex:indexPath.row];
    }
    
    
    
    if (self.isEnglish) {
//        [cell.g_underBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_u.png"] forState:UIControlStateNormal];
//        [cell.g_overBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_o.png"] forState:UIControlStateNormal];
    } else {
        [cell.g_underBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_u_vn.png"] forState:UIControlStateNormal];
        [cell.g_overBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_o_vn.png"] forState:UIControlStateNormal];
    }
    
    
    

    [GamePredictorViewController updateLiveScoreTableViewCell:cell model:model];
    
    
    cell.iTrangThai = model.iTrangThai;
    cell.originalKeo.hidden = YES;
    
    if (model.iTrangThai == 2 || model.iTrangThai == 4 ||
        model.iTrangThai == 3 || model.iTrangThai == 5 ||
        model.iTrangThai == 8 || model.iTrangThai == 9 || model.iTrangThai == 15) {
        // Fulltime match
        if(model.iTrangThai == 5 || model.iTrangThai == 8 ||
           model.iTrangThai == 9 || model.iTrangThai == 15) {
            cell.tyleCuoc.text = @"FT";
            if (model.iTrangThai == 8 || model.iTrangThai == 9) {
                cell.tyleCuoc.text = @"AET";
            }
        } else if(model.iTrangThai == 3) {
            cell.tyleCuoc.text = @"HT";
        } else {
            cell.tyleCuoc.text = [NSString stringWithFormat:@"%d'", model.iCN_Phut];
        }
        
        [cell setNSBorder:[UIColor grayColor]];
        cell.originalKeo.hidden = NO;
        cell.originalKeo.text = [model get_sTyLe_ChapBong:model.sTyLe_ChapBong];
    } else {
        cell.tyleCuoc.text = [model get_sTyLe_ChapBong:model.sTyLe_ChapBong];
        [cell setNSBorder:nil];
    }
    
    cell.dateLabel.text = [XSUtils toDayOfWeek:model.dThoiGianThiDau];
    
//    NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_FT, (unsigned long)model.iCN_BanThang_DoiKhach_FT];
    
    NSString* resultFT = @"";
    if (model.iTrangThai == 8) {
        resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_ET, model.iCN_BanThang_DoiKhach_ET];
    } else {
        resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_FT, model.iCN_BanThang_DoiKhach_FT];
    }
    cell.finalPredict.text = [NSString stringWithFormat:@"[%@]", resultFT];
    
    if(model.iTrangThai == 2 || model.iTrangThai == 4 || model.iTrangThai == 3 || model.iTrangThai == 5 ||
       model.iTrangThai == 8 || model.iTrangThai == 9 || model.iTrangThai == 15)  {
        // live match
    } else {
        cell.finalPredict.text = @"[ ? - ? ]";
    }
    
    cell.hostNS.userInteractionEnabled = NO;
    UIGamePredictorRecognizer *tap = [[UIGamePredictorRecognizer alloc] initWithTarget:self action:@selector(onHostNSClick:)];
    tap.numberOfTapsRequired = 1;
    tap.cell = cell;
    [cell.hostNS addGestureRecognizer:tap];
    
    cell.oppositeNS.userInteractionEnabled = NO;
    UIGamePredictorRecognizer *tap2 = [[UIGamePredictorRecognizer alloc] initWithTarget:self action:@selector(onOppositeNSClick:)];
    tap2.numberOfTapsRequired = 1;
    tap2.cell = cell;
    [cell.oppositeNS addGestureRecognizer:tap2];
    
    NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
    
    cell.hostDD.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SoSaoDatDoiNha]];
    cell.oppositeDD.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SoSaoDatDoiKhach]];
    
    if(model.SoSaoDatDoiKhach > 0.f) {
        model.isHighlightKhach = YES;
    }
    
    if (model.SoSaoDatDoiNha > 0.f) {
        model.isHighlightNha = YES;
    }
    
    // fill data chau au, tai xiu
    cell.g_DD_1x2_Nha.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDat1]];
    cell.g_DD_1x2_Khach.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDat2]];
    cell.g_xLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:model.SaoDatX]];
    
    cell.g_DD_uo_Nha.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDatU]];
    
    cell.g_DD_uo_Khach.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDatO]];
    
    
    
    if (model.SaoDat1 > 0.f) {
        model.isHighlight_1x2_1 = YES;
    }
    if (model.SaoDatX > 0.f) {
        model.isHighlight_1x2_x = YES;
    }
    if (model.SaoDat2 > 0.f) {
        model.isHighlight_1x2_2 = YES;
    }
    
    if (model.SaoDatU > 0.f) {
        model.isHighlight_uo_u = YES;
    }
    if (model.SaoDatO > 0.f) {
        model.isHighlight_uo_o = YES;
    }


    
    
    UIColor *mColor = [[UIColor alloc] initWithRed:230.0/255.f green:0.f blue:0.f alpha:1.f];
    
    if (model.isHighlightNha) {
        cell.hostDD.textColor = mColor;
    } else {
        cell.hostDD.textColor = [UIColor blackColor];
    }
    
    
    
    if (model.isHighlightKhach) {
        cell.oppositeDD.textColor = mColor;
    } else {
        cell.oppositeDD.textColor = [UIColor blackColor];
    }
    
    
    // highlight now
    if (model.isHighlight_1x2_1) {
        cell.g_DD_1x2_Nha.textColor = mColor;
    } else {
        cell.g_DD_1x2_Nha.textColor = [UIColor blackColor];
    }
    if (model.isHighlight_1x2_x) {
        cell.g_xLabel.textColor = mColor;
    } else {
        cell.g_xLabel.textColor = [UIColor blackColor];
    }
    if (model.isHighlight_1x2_2) {
        cell.g_DD_1x2_Khach.textColor = mColor;
    } else {
        cell.g_DD_1x2_Khach.textColor = [UIColor blackColor];
    }
    
    if (model.isHighlight_uo_u) {
        cell.g_DD_uo_Nha.textColor = mColor;
    } else {
        cell.g_DD_uo_Nha.textColor = [UIColor blackColor];
    }
    
    if (model.isHighlight_uo_o) {
        cell.g_DD_uo_Khach.textColor = mColor;
    } else {
        cell.g_DD_uo_Khach.textColor = [UIColor blackColor];
    }
    
    
    
    
    // fill data for ty le

    [self fillData_TyLe_CaCuoc:cell model:model];
    [self setupEventHandlerForCell:cell model:model];
    // end
    
    
    
    
    cell.htButton.userInteractionEnabled = YES;
    UIGamePredictorRecognizer *tap3 = [[UIGamePredictorRecognizer alloc] initWithTarget:self action:@selector(onHtClick:)];
    tap3.numberOfTapsRequired = 1;
    tap3.cell = cell;
    [cell.htButton addGestureRecognizer:tap3];
    
    [cell.hostSlider addTarget:self action:@selector(onHostSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.hostSlider.cell = cell;
    
    [cell.oppositeSlider addTarget:self action:@selector(onOppositeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.oppositeSlider.cell = cell;
    
    
    
    // add event
    [cell.pdoBtn addTarget:self action:@selector(onPerformClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.pdoBtn.model = model;
    
    [cell.compBtn addTarget:self action:@selector(onComputerClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.compBtn.model = model;
    
    [cell.expertBtn addTarget:self action:@selector(onExpertClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.expertBtn.model = model;

    
    if(model.bNhanDinhChuyenGia) {
        cell.expertBtn.hidden = NO;
    }
    if(model.bMayTinhDuDoan) {
        cell.compBtn.hidden = NO;
    }
    
    
    __weak GameTableViewCell* _tmpCell = cell;
    if(self.selectedModel && self.selectedModel.iID_MaTran == model.iID_MaTran && self.selectedModel.highlightedGame == NO) {
        // highligh row now
        [UIView animateWithDuration:5.0f  delay:0 options: UIViewAnimationOptionAllowUserInteraction
                         animations:^  {
                             
                             _tmpCell.contentView.backgroundColor = [UIColor colorWithRed:(254/255.f) green:(184/255.f) blue:(147/255.f) alpha:1.f];
                         }
                         completion:^ (BOOL finished) {
                             _tmpCell.contentView.backgroundColor = [UIColor whiteColor];
                             self.selectedModel.highlightedGame = YES;
                         }];
        
    }

    

    return cell;
}




-(void)onPerformClick:(BDButton*)sender
{
    LivescoreModel *model = sender.model;
    PViewController *p = [[PViewController alloc] initWithNibName:@"PViewController" bundle:nil];
    p.p_type = 0; // phong do
    p.model = model;
//    [self presentViewController:p animated:YES completion:nil];
    [self.navigationController pushViewController:p animated:YES];
    
}
-(void)onComputerClick:(BDButton*)sender
{
    LivescoreModel *model = sender.model;
    PViewController *p = [[PViewController alloc] initWithNibName:@"PViewController" bundle:nil];
    p.p_type = 1; // may tinh du doan
    p.model = model;
//    [self presentViewController:p animated:YES completion:nil];
    [self.navigationController pushViewController:p animated:YES];
    
}

-(void)onExpertClick:(BDButton*)sender
{
    
    LivescoreModel *model = sender.model;
    ExpertReview* exp = [[ExpertReview alloc] initWithNibName:@"ExpertReview" bundle:nil];
    exp.model = model;
    [self.navigationController pushViewController:exp animated:YES];
    
}


-(void)onFavouriteClick:(BDButton*)sender {
    LivescoreModel *model = sender.model;
    model.isFavourite = !model.isFavourite;
    int favo = 0;
    NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
    
    if (model.isFavourite) {
        [sender setBackgroundImage:[UIImage imageNamed:@"heart_fill.png"] forState:UIControlStateNormal];
        favo = 1;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:matran];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"heart_hidden.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:matran];
    }
    
    
//    // get device token
//    NSString* deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY];
//    if(deviceToken!=nil) {
//        [self submitFavouriteMatch:deviceToken matran:matran type:favo];
//    }
    
}


-(void)onHostSliderValueChanged:(GameSlider*)sender
{
    ZLog(@"onHostSliderValueChanged");
    GameTableViewCell *cell = sender.cell;
    
    NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
    cell.hostDD.text = [NSString stringWithFormat:@"%@: %d",localizeDD, (int)round(sender.value)];
}

-(void)onOppositeSliderValueChanged:(GameSlider*)sender
{
    ZLog(@"onOppositeSliderValueChanged");
    GameTableViewCell *cell = sender.cell;
    NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
    cell.oppositeDD.text = [NSString stringWithFormat:@"%@: %d",localizeDD, (int)round(sender.value)];
    
}

-(void)_onSubmitSetbet:(GameTableViewCell*)cell bet_type:(NSUInteger)bet_type pick:(NSUInteger)picked iTyLeTien:(float)iTyLeTien
{
    
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        [alert show];
        return;
    }
    
    cell.hostSlider.hidden = YES;
    cell.oppositeSlider.hidden = YES;
    cell.hostNS.hidden = YES;
    cell.oppositeNS.hidden = YES;
    
    LivescoreModel *model = cell.compBtn.model;
    
    NSString* keoTyle = model.sTyLe_ChapBong;
    
    
    float hostVal = cell.hostDDVal;
    float oppositeVal = cell.oppositeDDVal;
    NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
    
    
    if (hostVal > 0.f || oppositeVal > 0.f) {
        // send bet request now
        dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.setbet", NULL);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
            
            NSString *tmpkeoTyle = [model get_sTyLe_ChapBong:keoTyle];
            
            
            
            if (hostVal > 0.f) {
                float retKeo = 0.f;
                if (bet_type == 0) {
                    retKeo = [XSUtils get_tyleChapBong_SetBet:tmpkeoTyle isHost:YES];
                } else if(bet_type == 2) {
                    retKeo = [XSUtils convertFloatFromString_SetBet:cell.g_tyleTaiXiu.text];
                }
                
                [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_Message:[NSString stringWithFormat:@"%d", model.iID_MaTran] iID_MaDoi:[NSString stringWithFormat:@"%d", model.iID_MaDoiNha] sSoDienThoai:account iBet:hostVal iKeo:retKeo sKeo:tmpkeoTyle iBetSelect:picked iTyLeTien:iTyLeTien iLoaiBet:bet_type] soapAction:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_SoapAction]];
            }
            
            if(oppositeVal > 0.f) {
                float retKeo = 0.f;
                if (bet_type == 0) {
                    retKeo = [XSUtils get_tyleChapBong_SetBet:tmpkeoTyle isHost:NO];
                } else if(bet_type == 2) {
                    retKeo = [XSUtils convertFloatFromString_SetBet:cell.g_tyleTaiXiu.text];
                }
                
                
                [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_Message:[NSString stringWithFormat:@"%d", model.iID_MaTran] iID_MaDoi:[NSString stringWithFormat:@"%d", model.iID_MaDoiKhach] sSoDienThoai:account iBet:oppositeVal iKeo:retKeo sKeo:tmpkeoTyle iBetSelect:picked iTyLeTien:iTyLeTien iLoaiBet:bet_type] soapAction:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_SoapAction]];
            }
            
            cell.hostDDVal = 0.f;
            cell.oppositeDDVal = 0.f;
            
        });
    } else {
        ZLog(@"nothing to submit for setbettt");
    }
}



-(void) onHtClick:(UIGamePredictorRecognizer*) sender
{
    
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        
        [alert show];
        return;
    }
    
    GameTableViewCell *cell = sender.cell;
    
//    [self _onSubmitSetbet:cell];
    
    
}

-(void)onBetGameClick:(BetGameButton*) sender {
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        [alert show];
        return;
    }
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
        if (sender.bet_type == 0) {
            // bet theo chau a
            if (sender.picked == 1) {
                [self showNSDiaglog:YES cell:cell];
            } else {
                [self showNSDiaglog:NO cell:cell];
            }
            
        } else if(sender.bet_type == 1 || sender.bet_type == 2) {
            // bet theo chau au
            [self showHandicapDiaglog:sender.bet_type cell:cell pick:sender.picked];
        }
        
        
    } else {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-match-ft.txt", @"tran dau ket thuc")];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) onHostNSClick:(UIGamePredictorRecognizer*) sender
{
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        [alert show];
        return;
    }
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
    
        [self showNSDiaglog:YES cell:cell];
    } else {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-match-ft.txt", @"tran dau ket thuc")];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }

    
//    cell.hostNS.hidden = YES;
//    cell.hostSlider.hidden = NO;

}



-(void) onXButtonNSClick:(UIGamePredictorRecognizer*) sender
{
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        
        [alert show];
        return;
    }
    
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
        
        [self showNSDiaglog:NO cell:cell];
    }
    
    
    //    cell.oppositeNS.hidden = YES;
    //    cell.oppositeSlider.hidden = NO;
}

-(void) onOppositeNSClick:(UIGamePredictorRecognizer*) sender
{
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        
        [alert show];
        return;
    }
    
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
        
        [self showNSDiaglog:NO cell:cell];
    } else {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-match-ft.txt", @"tran dau ket thuc")];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
//    cell.oppositeNS.hidden = YES;
//    cell.oppositeSlider.hidden = NO;
}





-(void)textFieldDidChange:(UITextField *)theTextField
{
    ZLog(@"text changed: %@", theTextField.text);
    
//    NSString *textFieldText = [theTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
//    
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithInt:[textFieldText integerValue]]];
//    textField.text = [XSUtils format_iBalance:[textField.text ]];
    if (theTextField.text && theTextField.text.length > 2) {
        theTextField.text = [theTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        theTextField.text = [theTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        theTextField.text = [XSUtils format_iBalance:[theTextField.text integerValue]];
    }

    
}

-(void)showHandicapDiaglog:(NSUInteger)bet_type cell:(GameTableViewCell*)cell pick:(NSUInteger)picked {
    NSString* selectedTeam = @"";
    NSString* retKeo = @"";
    NSString* tyleTien = @"";
    
    if (bet_type == 1) {
        if (picked == 1) {
            // pick chu nha
            tyleTien = cell.g_1x2Tyle_1.text;
            selectedTeam = @"1";
        } else if(picked == 2) {
            // pick khach
            tyleTien = cell.g_1x2Tyle_2.text;
            selectedTeam = @"2";
        } else if(picked == 0) {
            // chon X: Hoa
            tyleTien = cell.g_1x2Tyle_x.text;
            selectedTeam = @"X";
        }
    } else if(bet_type == 2) {
        if (picked == 1) {
            // pick under (xiu)
            NSString* localizeX = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-xiu-txt", @"Xiu")];
            tyleTien = cell.g_underTyle.text;
            selectedTeam = [NSString stringWithFormat:@"%@ %@", localizeX, cell.g_tyleTaiXiu.text];
        } else if(picked == 2) {
            // pick over (tai)
            NSString* localizeX = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-tai-txt", @"Tai")];
            tyleTien = cell.g_overTyle.text;
            selectedTeam = [NSString stringWithFormat:@"%@ %@", localizeX, cell.g_tyleTaiXiu.text];
            
        }
    }
    

    if([tyleTien isEqualToString:@""]) {
        return;
    }
    
    
    NSString* tysoHt = cell.finalPredict.text;
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"?" withString:@"0"];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"[ " withString:@"["];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@" ]" withString:@"]"];
    
    

    
    tyleTien = [NSString stringWithFormat:@"%@ %@%@", tyleTien, @"@", tysoHt];
    
    
    NSString* localizeD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-proceed.txt", @"Đặt")];
    NSString* localizeH = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
    NSString* localizeB = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-balance.txt", @"Số dư")];
    NSString* localizeSelect = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-select.txt", @"Đặt")];
    
    
    NSString* iBalance = [NSString stringWithFormat:@"%@: %@ ☆", localizeB, [XSUtils format_iBalance:[AccInfo sharedInstance].iBalance]];
    
    
    
    GameAlertView *myAlertView = [[GameAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", cell.hostTeam.text, cell.tyleCuoc.text, cell.oppositeTeam.text]
                                                              message:[NSString stringWithFormat:@"%@\n%@ %@ %@ %@%@",iBalance, localizeSelect, selectedTeam, retKeo, @"@", tyleTien] delegate:self cancelButtonTitle:localizeH otherButtonTitles:localizeD, nil];
    myAlertView.isHost = YES;
    myAlertView.cellObj = cell;
    myAlertView.picked = picked;
    myAlertView.bet_type = bet_type;
    myAlertView.iTyLeTien = [tyleTien floatValue];
    
    
    
    
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [myAlertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    
    [myAlertView show];
}

-(void)showNSDiaglog:(BOOL)isHost cell:(GameTableViewCell*)cell
{
//    NSLocalizedString(@"Xin mời nhập số sao muốn đặt:", @"NS_dialog_msg")
    NSString* selectedTeam = cell.oppositeTeam.text;
    NSString* retKeo = @"";
    NSString* tyleTien = cell.g_asiaTyle_Nha.text;

    if (isHost) {
        selectedTeam = cell.hostTeam.text;
        tyleTien = cell.g_asiaTyle_Nha.text;
    } else {
        tyleTien = cell.g_asiaTyleKhach.text;
    }
    
    if([tyleTien isEqualToString:@""]) {
        return;
    }
    
    
    NSString* tysoHt = cell.finalPredict.text;
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"?" withString:@"0"];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"[ " withString:@"["];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@" ]" withString:@"]"];
    
    
    
    
    tyleTien = [NSString stringWithFormat:@"%@ %@%@", tyleTien, @"@", tysoHt];
    
    
    float tmpRetKeo = [XSUtils get_tyleChapBong_SetBet:cell.tyleCuoc.text isHost:isHost];
    if(tmpRetKeo > 0) {
        retKeo = [NSString stringWithFormat:@"+%.2f", tmpRetKeo];
    } else {
        retKeo = [NSString stringWithFormat:@"%.2f", tmpRetKeo];
    }
    
    NSString* localizeD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-proceed.txt", @"Đặt")];
    NSString* localizeH = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
    NSString* localizeB = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-balance.txt", @"Số dư")];
    NSString* localizeSelect = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-select.txt", @"Đặt")];
    

    NSString* iBalance = [NSString stringWithFormat:@"%@: %@ ☆", localizeB, [XSUtils format_iBalance:[AccInfo sharedInstance].iBalance]];
    
    
    
    GameAlertView *myAlertView = [[GameAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", cell.hostTeam.text, cell.tyleCuoc.text, cell.oppositeTeam.text]
                                                          message:[NSString stringWithFormat:@"%@\n%@ %@ %@ %@%@",iBalance, localizeSelect, selectedTeam, retKeo, @"@", tyleTien] delegate:self cancelButtonTitle:localizeH otherButtonTitles:localizeD, nil];
    myAlertView.isHost = isHost;
    myAlertView.cellObj = cell;
    myAlertView.bet_type = 0;
    myAlertView.picked = isHost ? 1 : 2;
    myAlertView.iTyLeTien = [tyleTien floatValue];

    
    
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [myAlertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    
    [myAlertView show];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= MAX_LENGTH_SAO_INPUT && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else {
        return YES;
    }
}

-(void) getListGamePredictor
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.sms", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        if(self.pageNum >= self.totalPage) {
            return;
        }
        self.pageNum++;
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getGamePredictorSoapMessage:self.pageNum username:account] soapAction:[PresetSOAPMessage getGamePredictorSoapAction]];
        
    });
}


-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingImg.hidden = NO;
        [self.loadingIndicator stopAnimating];
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
    });
}



-(void)handle_wsFootBall_Lives_Co_GameDuDoanResult:(NSString*) xmlData
{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Lives_Co_GameDuDoanResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Lives_Co_GameDuDoanResult>"] objectAtIndex:0];
        
        
        
        
        //
        //        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            long currentTime = [[NSDate date] timeIntervalSince1970];
            
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                LivescoreModel *model = [LivescoreModel new];
                
                
                NSString* matchTime = [dict objectForKey:@"dThoiGianThiDau"];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@")/" withString:@""];
                long dateLong =[matchTime integerValue]/1000;
                
                
                
                
                dateLong = [(NSNumber*)[dict objectForKey:@"iC0"] longValue];
                model.iC0 = dateLong;
                model.iC1 = [(NSNumber*)[dict objectForKey:@"iC1"] longValue];
                model.iC2 = [(NSNumber*)[dict objectForKey:@"iC2"] longValue];
                model.iSoPhut1Hiep = [(NSNumber*)[dict objectForKey:@"iSoPhut1Hiep"] longValue];
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateLong];
                model.dThoiGianThiDau = date;
                
                
                
                
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"HH:mm"];
                
                
                //pens
                model.iCN_BanThang_DoiNha_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_Pen"] integerValue];
                model.iCN_BanThang_DoiKhach_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_Pen"] integerValue];

                
                
                model.sThoiGian = [dict objectForKey:@"sThoiGian"];
                model.sThoiGian = [dateFormatter stringFromDate:date];
                
                
                model.sTenDoiNha = [dict objectForKey:@"sTenDoiNha"];
                model.sTenDoiKhach = [dict objectForKey:@"sTenDoiKhach"];
                model.sTenGiai = [dict objectForKey:@"sTenGiai"];
                model.sLogoQuocGia = [dict objectForKey:@"sLogoQuocGia"];
                model.sLogoDoiNha = [dict objectForKey:@"sLogoDoiNha"];
                model.sLogoDoiKhach = [dict objectForKey:@"sLogoDoiKhach"];
                model.sLogoGiai = [dict objectForKey:@"sLogoGiai"];
                model.iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] integerValue];
                model.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] integerValue];
                
                @try {
                    model.SoSaoDatDoiNha += [(NSNumber*)[dict objectForKey:@"SaoDatDoiNha"] integerValue];
                    model.SoSaoDatDoiKhach += [(NSNumber*)[dict objectForKey:@"SaoDatDoiKhach"] integerValue];
                    model.SaoDat1 += [(NSNumber*)[dict objectForKey:@"SaoDat1"] integerValue];
                    model.SaoDat2 += [(NSNumber*)[dict objectForKey:@"SaoDat2"] integerValue];
                    model.SaoDatX += [(NSNumber*)[dict objectForKey:@"SaoDatX"] integerValue];
                    model.SaoDatU += [(NSNumber*)[dict objectForKey:@"SaoDatU"] integerValue];
                    model.SaoDatO += [(NSNumber*)[dict objectForKey:@"SaoDatO"] integerValue];
                    
                }
                @catch (NSException *exception) {
                    model.SoSaoDatDoiKhach = 0;
                    model.SoSaoDatDoiNha = 0;
                    
                    model.SaoDat1 = 0;
                    model.SaoDat2 = 0;
                    model.SaoDatO = 0;
                    model.SaoDatU = 0;
                    model.SaoDatX = 0;
                }
                
                
                
                // keo game du doan
                model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong"];
                
                model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu"];
                model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu"];
                
                
                if (model.iTrangThai == 5 ||
                    model.iTrangThai == 8 ||
                    model.iTrangThai == 9 ||
                    model.iTrangThai == 15) {
                    
                    model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong_DauTran"];
                    model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu_DauTran"];
                    model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu_DauTran"];
                }
                
                model.sTyLe_ChauAu_Live = [model get_sTyLe_ChapBong_ChauAu_Live:model.sTyLe_ChauAu];
                model.sTyLe_TaiSuu_Live = [model get_sTyLe_ChapBong_TaiSuu_Live:model.sTyLe_TaiSuu];
                // end keo ty le
                

                
                // may tinh du doan va nhan dinh chuyen gia
                model.bMayTinhDuDoan = NO;
                model.bNhanDinhChuyenGia = NO;
                model.bNhanDinhChuyenGia = [[dict objectForKey:@"bNhanDinhChuyenGia"] boolValue];
                model.bMayTinhDuDoan = [[dict objectForKey:@"bMayTinhDuDoan"] boolValue];
                
                model.iCN_Phut = [(NSNumber*)[dict objectForKey:@"iCN_Phut"] integerValue];
                model.iPhutThem = [(NSNumber*)[dict objectForKey:@"iPhutThem"] integerValue];
                
                //iID_MaDoiNha, iID_MaDoiKhach
                model.iID_MaDoiNha = [(NSNumber*)[dict objectForKey:@"iID_MaDoiNha"] integerValue];
                model.iID_MaDoiKhach = [(NSNumber*)[dict objectForKey:@"iID_MaDoiKhach"] integerValue];
                
                
                model.sDoiNha_BXH = [dict objectForKey:@"sDoiNha_BXH"];
                model.sDoiKhach_BXH = [dict objectForKey:@"sDoiKhach_BXH"];
                
                
                model.iCN_BanThang_DoiKhach_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_HT"] integerValue];
                model.iCN_BanThang_DoiNha_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_HT"] integerValue];
                model.iCN_BanThang_DoiNha_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_FT"] integerValue];
                model.iCN_BanThang_DoiKhach_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_FT"] integerValue];
                model.iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] integerValue];
                
                
                model.iCN_BanThang_DoiNha_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_ET"] integerValue];
                model.iCN_BanThang_DoiKhach_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_ET"] integerValue];
                
                NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
                NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:matran];
                if(number != nil && [number intValue] == 1) {
                    model.isFavourite = YES;
                } else {
                    model.isFavourite = NO;
                }
                
                [LiveScoreViewController update_iCN_Phut_By_LivescoreModel:model c0:currentTime]; // update iCN_Phut by local time
                
                
                [model adjustImageURLForReview];
                
                
                ZLog(@"iID_MaGiai: %lu", (unsigned long)model.iID_MaGiai);
                
                
                //totalpage
//                self.totalPage = [[dict objectForKey:@"totalpage"] intValue];
                @try {
                    self.totalPage = [[dict objectForKey:@"totalpage"] intValue];
                }@catch(NSException *ex){
                    self.totalPage = 1;
                }
                
                NSString* iID_MaGiai_Str = [NSString stringWithFormat:@"%lu", (unsigned long)model.iID_MaGiai];
                NSString* iID_MaGiai_Pinned = [[NSUserDefaults standardUserDefaults] objectForKey:iID_MaGiai_Str];

                
                NSMutableArray* list = [self.listLivescore objectForKey:iID_MaGiai_Str];
                if(list == nil) {
                    list = [NSMutableArray new];
//                    [self.listLivescoreKeys addObject:iID_MaGiai_Str];
                    
                    
                    if(iID_MaGiai_Pinned) {
                        [self.listLivescoreKeys insertObject:iID_MaGiai_Str atIndex:0];
                    } else {
                        [self.listLivescoreKeys addObject:iID_MaGiai_Str];
                    }

                    
                } else {
                    // existed, update data then
                    LivescoreModel* oldModel = [self findModelByMaTran:list iID_MaTran:model.iID_MaTran];
                    if(oldModel != nil) {
                        // remove old data and then update it
                        ZLog(@"remove old model: %@", oldModel);
                        [list removeObject:oldModel];
                    } else {
                        // dont go anymore
                        //                        continue;
                    }
                    
                }
                [list addObject:model];
                
                [self.listLivescore setObject:list forKey:iID_MaGiai_Str];
                
            }
            
            NSIndexPath *_indexPath = nil;
            // scroll to selected model
            if(self.selectedModel) {
                NSString* iID_MaGiai_Str = [NSString stringWithFormat:@"%lu", (unsigned long)self.selectedModel.iID_MaGiai];
                NSUInteger _section = [self findSectionByGiven_iID_MaGiai:iID_MaGiai_Str];
                NSUInteger _rowInSection = [self findRowInSectionByGiven_iID_MaGiai:iID_MaGiai_Str iID_MaTran:self.selectedModel.iID_MaTran];
                
                if(_section != -1 && _rowInSection != -1) {
                    _indexPath = [NSIndexPath indexPathForRow:_rowInSection inSection:_section];
                }
                
            }
            
            
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.loadingImg.hidden = NO;
                [self.loadingIndicator stopAnimating];
                [self.tableView reloadData];
                
                if(self.selectedModel && _indexPath) {
                    @try {
                        [self.tableView scrollToRowAtIndexPath:_indexPath
                                              atScrollPosition:UITableViewScrollPositionTop
                                                      animated:NO];
                    }@catch(NSException *ex) {

                    }
                    
                }
            });
        }
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}


-(NSUInteger) findSectionByGiven_iID_MaGiai:(NSString*)iID_MaGiai_Str
{
 
    
    for(int i=0;i<self.listLivescoreKeys.count;i++) {
        NSString* tmp = [self.listLivescoreKeys objectAtIndex:i];
        if([tmp isEqualToString:iID_MaGiai_Str]) {
            return i;
        }
    }
    
    return -1;
    
}

-(NSUInteger) findRowInSectionByGiven_iID_MaGiai:(NSString*)iID_MaGiai_Str iID_MaTran:(NSUInteger)iID_MaTran
{
    
    NSMutableArray* list = [self.listLivescore objectForKey:iID_MaGiai_Str];
    for(int i=0;i<list.count;i++) {
        LivescoreModel* tmp = [list objectAtIndex:i];
        if(tmp.iID_MaTran == iID_MaTran) {
            return i;
        }
    }
    
    return -1;
    
}




-(void)handle_wsFootBall_Lives_Co_GameDuDoan_SetBetResult:(NSString*) xmlData
{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Lives_Co_GameDuDoan_SetBetResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Lives_Co_GameDuDoan_SetBetResult>"] objectAtIndex:0];
        
        
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            int iErrCode = -1;
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                iErrCode = [(NSNumber*)[dict objectForKey:@"iErrCode"] intValue];
                NSString* username = [dict objectForKey:@"sUsername"];
                int iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] intValue];
                NSString* sMaTran = [dict objectForKey:@"sMaTran"];
                
                
                int iSetBet = [(NSNumber*)[dict objectForKey:@"iSetBet"] intValue];
                int iMaGiai = [(NSNumber*)[dict objectForKey:@"iMaGiai"] intValue];
                
                // get bet_type and picked value
                int bet_type = [(NSNumber*)[dict objectForKey:@"iLoaiBet"] intValue];
                int picked = [(NSNumber*)[dict objectForKey:@"iBetSelect"] intValue];
                
                NSArray* list = [self.listLivescore objectForKey:[NSString stringWithFormat:@"%d", iMaGiai]];
                LivescoreModel *model = [self findModelByMaTran:list iID_MaTran:[sMaTran integerValue]];
                
                
                if (bet_type == 0) {
                    // bet chau A
                    BOOL bDoiNha = (picked == 1) ? YES : NO;
                    if(bDoiNha) {
                        model.SoSaoDatDoiNha += iSetBet;
                    } else {
                        model.SoSaoDatDoiKhach += iSetBet;
                    }
                    
                    if (iErrCode == _BET_CODE_SUCCESS_) {
                        if(bDoiNha) {
                            model.isHighlightNha = bDoiNha;
                        } else {
                            model.isHighlightKhach = !bDoiNha;
                        }
                        
                        
                    }
                } else if(bet_type == 1) {
                    // chau au
                    if (picked == 1) {
                        // pick 1
                        model.SaoDat1 += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_1x2_1 = YES;
                        }
                    } else if(picked == 0) {
                        // pick hoa: X
                        model.SaoDatX += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_1x2_x = YES;
                        }
                    }else if(picked == 2) {
                        // pick 2
                        model.SaoDat2 += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_1x2_2 = YES;
                        }
                    }
                }else if(bet_type == 2) {
                    // tai xiu
                    if (picked == 1) {
                        // xiu
                        model.SaoDatU += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_uo_u = YES;
                        }
                    } else if(picked == 2) {
                        // tai
                        model.SaoDatO += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_uo_o = YES;
                        }
                    }
                }
                
                
                [AccInfo sharedInstance].iBalance = iBalance;
                
                if (YES) {
                    break;
                }
            }
            
            
            
            [self setbet_showAlertByErrorCodeGiven:iErrCode];
            
        }
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}

-(void)setbet_showAlertByErrorCodeGiven:(int)iErrCode
{
    // update data on Main UI thread
    NSString* msg = @"";
//    
//    
//    "game-alert-success.txt" = "Chúc mừng bạn đặt cược thành công";
//    "game-alert-authen.txt" = "Bạn chưa đăng nhập, vui lòng đăng nhập để đặt cược";
//    "game-alert-balance.txt" = "Tài khoản không đủ để đặt cược, vui lòng nạp thẻ";
//    "game-alert-sys.txt" = "Hệ thống quá tải, xin vui lòng trở lại sau";
//    "game-alert-failed.txt" = "Đặt cược không thành công";
    
    if (iErrCode == _BET_CODE_SUCCESS_) {
        // setbet ok
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-success.txt", @"Chúc mừng bạn đặt cược thành công")];
        msg = localizeTxt;
    
    } else if (iErrCode == _BET_CODE_ERROR_AUTHEN_) {
       
        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-authen.txt", @"Bạn chưa đăng nhập, vui lòng đăng nhập để đặt cược")];
        msg = localizeTxt;
    } else if (iErrCode == _BET_CODE_ERROR_BALANCE_) {
        
        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-balance.txt", @"Tài khoản không đủ để đặt cược, vui lòng nạp thẻ")];
        msg = localizeTxt;
    } else if (iErrCode == _BET_CODE_ERROR_EBANK_) {

        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-sys.txt", @"Hệ thống quá tải, xin vui lòng trở lại sau")];
        msg = localizeTxt;
    } else if (iErrCode == _BET_CODE_ERROR_REQUIRE_MIN_100_) {
        // require at least 100 star
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-require-100.txt", @"Bạn phải đặt tối thiểu 100 sao trở lên.")];
        msg = localizeTxt;
    } else {
        // setbet failed
        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-failed.txt", @"Đặt cược không thành công")];
        msg = localizeTxt;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                         withRowAnimation:UITableViewRowAnimationNone];

        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    });
}



-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([xmlData rangeOfString:@"<wsFootBall_Lives_Co_GameDuDoanResult>"].location != NSNotFound) {
            // handle game du doan
            [self handle_wsFootBall_Lives_Co_GameDuDoanResult:xmlData];
            
        } else if([xmlData rangeOfString:@"<wsFootBall_Lives_Co_GameDuDoan_SetBetResult>"].location != NSNotFound) {
            // handle game du doan setbet
            ZLog(@"got setbet response: %@", xmlData);
            [self handle_wsFootBall_Lives_Co_GameDuDoan_SetBetResult:xmlData];
        } else {
            ZLog(@"unhandle this soap response: %@", xmlData);
        }
        
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}

-(LivescoreModel*) findModelByMaTran:(NSMutableArray*) list iID_MaTran:(NSUInteger)iID_MaTran
{
    for(NSUInteger i=0;i<list.count;i++) {
        LivescoreModel* model = [list objectAtIndex:i];
        if(model.iID_MaTran == iID_MaTran) {
            
            return model;
        }
    }
    
    return nil;
}


-(void)onBxhTap:(BDLiveGestureRecognizer*) sender
{
    
    NSString* sTenGiai = sender.sTenGiai;
    NSString* iID_MaTran = sender.iID_MaTran;
    NSString* logoGiaiUrl = sender.logoGiaiUrl;
    
    ZLog(@"retreiving data for bxh: %@", sTenGiai);
    NSArray* list = [self.listLivescore objectForKey:iID_MaTran];
    LivescoreModel* model = [list objectAtIndex:0];
    if(model != nil) {
        NSString* iID_MaGiai = [NSString stringWithFormat:@"%lu", model.iID_MaGiai];
        [self fetchBxhByID:iID_MaGiai sTenGiai:sTenGiai logoGiaiUrl:logoGiaiUrl];
    }
    
    
}


-(void) fetchBxhByID:(NSString*)iID_MaGiai sTenGiai:(NSString*)sTenGiai logoGiaiUrl:(NSString*)logoGiaiUrl
{
    ZLog(@"iID_MaGiai: %@", iID_MaGiai);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StatsViewController* bxh = [storyboard instantiateViewControllerWithIdentifier:@"StatsViewController"];
    bxh.iID_MaGiai = iID_MaGiai;
    bxh.nameBxh = sTenGiai;
    bxh.logoBxh = logoGiaiUrl;
    
    [bxh fetchBxhListById];
    [self.navigationController pushViewController:bxh animated:YES];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[GameAlertView class]] && buttonIndex != 0) {
        // game alert dialog for NS
        ZLog(@"game alert dialog for NS");
        GameAlertView* gameAlert = (GameAlertView*)alertView;
        GameTableViewCell* cell = gameAlert.cellObj;
        
        
        if (gameAlert.isConfirm) {
            UIColor *mColor = [[UIColor alloc] initWithRed:230.0/255.f green:0.f blue:0.f alpha:1.f];
            if (gameAlert.isHost) {
                
                
                
                NSString* iDD = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:(int)gameAlert.starValue]];

                
                NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
                
                cell.hostSlider.value = gameAlert.starValue;
                
                if (gameAlert.bet_type == 0) {
                    cell.hostDD.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                    cell.hostDD.textColor = mColor;
                } else if(gameAlert.bet_type == 1) {
                    if(gameAlert.picked == 1) {
                        // pick 1
                        cell.g_DD_1x2_Nha.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_1x2_Nha.textColor = mColor;
                    } else if(gameAlert.picked == 0) {
                        // pick X
                        cell.g_xLabel.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_xLabel.textColor = mColor;
                    } else if(gameAlert.picked == 2) {
                        // pick 2
                        cell.g_DD_1x2_Khach.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_1x2_Khach.textColor = mColor;
                    }
                } else if(gameAlert.bet_type == 2) {
                    if(gameAlert.picked == 1) {
                        // pick xiu
                        cell.g_DD_uo_Nha.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_uo_Nha.textColor = mColor;
                    } else if(gameAlert.picked == 2) {
                        // pick tai
                        cell.g_DD_uo_Khach.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_uo_Khach.textColor = mColor;
                    }
                }
                
                
                cell.hostDDVal = gameAlert.starValue;
            } else {
                
                
                NSString* iDD = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:(int)gameAlert.starValue]];
                
                NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
                cell.oppositeDD.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                cell.oppositeSlider.value = gameAlert.starValue;
                cell.oppositeDD.textColor = mColor;
                cell.oppositeDDVal = gameAlert.starValue;
            }
            
            // submit to server now
            [self _onSubmitSetbet:gameAlert.cellObj bet_type:gameAlert.bet_type pick:gameAlert.picked iTyLeTien:gameAlert.iTyLeTien];
        } else {
            // show confirm box
            UITextField *textField = [gameAlert textFieldAtIndex:0];
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            if ([textField.text floatValue] > 0) {
                NSString* starStr = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:[textField.text integerValue]]];
                
                
                NSString* localizeH = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
                NSString* localizeXN = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-confirm.txt", @"Xác nhận")];
                
                GameAlertView *confirmAlert = [[GameAlertView alloc] initWithTitle:gameAlert.title message:[NSString stringWithFormat:@"%@ = %@", gameAlert.message, starStr] delegate:self cancelButtonTitle:localizeH otherButtonTitles:localizeXN, nil];
                confirmAlert.isConfirm = YES;
                confirmAlert.isHost = gameAlert.isHost;
                confirmAlert.starValue = [textField.text floatValue];

                confirmAlert.iTyLeTien = gameAlert.iTyLeTien;
                confirmAlert.bet_type = gameAlert.bet_type;
                confirmAlert.picked = gameAlert.picked;
                
                
                confirmAlert.cellObj = gameAlert.cellObj;
                [confirmAlert show];
            }
        }
        
        
        
        

        
        
        
    } else {
        if (buttonIndex != 0) {
            // goto login now
            UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SettingsViewController *set = [story instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            UIViewController *navController = [[UINavigationController alloc]
                                               initWithRootViewController:set];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

- (IBAction) onAccountInfoClick:(id)sender {
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsViewController *set = [story instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    set.segmentIndex = 1;
    UIViewController *navController = [[UINavigationController alloc]
                                       initWithRootViewController:set];
    
    [self presentViewController:navController animated:YES completion:nil];
}


+(void)updateLiveScoreTableViewCell:(GameTableViewCell*)cell model:(LivescoreModel*)model
{
    if (![model.sDoiNha_BXH isKindOfClass:[NSNull class]] && (model.sDoiNha_BXH && ![model.sDoiNha_BXH isEqualToString:@""])) {
        
        NSString* htmlString = [NSString stringWithFormat:@"<p style=\"text-align:right; font-family:VNF-FUTURA\"><span style=\"color:#e60000;\">[%@]</span> %@</p>", model.sDoiNha_BXH, model.sTenDoiNha];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            cell.hostTeam.attributedText = attrStr;
        } else {
            cell.hostTeam.text = [NSString stringWithFormat:@"[%@] %@", model.sDoiNha_BXH, model.sTenDoiNha];
        }
        
        
        
    } else {
        cell.hostTeam.text = model.sTenDoiNha;
        
    }
    
    if (![model.sDoiKhach_BXH isKindOfClass:[NSNull class]] && model.sDoiKhach_BXH && ![model.sDoiKhach_BXH isEqualToString:@""]) {
        
        NSString* htmlString = [NSString stringWithFormat:@"<p style=\"text-align:left; font-family:VNF-FUTURA\">%@ <span style=\"color:#e60000;\">[%@]</span></p>", model.sTenDoiKhach, model.sDoiKhach_BXH];
        
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            NSAttributedString*attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            cell.oppositeTeam.attributedText = attrStr;
        } else {
            cell.oppositeTeam.text = [NSString stringWithFormat:@"%@ [%@]", model.sTenDoiKhach, model.sDoiKhach_BXH];
        }
        
        
    } else {
        cell.oppositeTeam.text = model.sTenDoiKhach;
    }
    
}


-(IBAction)onFilteredMatchesClick:(id)sender {
    
    NSString* allTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-filter-all-txt", @"All")];
    NSString* NextTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-filter-next-txt", @"Next")];
    NSString* LiveTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-filter-live-txt", @"Live")];
    NSString* FTTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-filter-ft-txt", @"FT")];
    
    NSString* FilterTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-filter-filter-txt", @"Filter")];
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:FilterTxt delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:allTxt,NextTxt,LiveTxt,FTTxt, nil];
    
    
    
    [sheet showInView:self.view];
//    
//
//  
//    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
//                                                                              message: nil
//                                                                       preferredStyle: UIAlertControllerStyleActionSheet];
//    [alertController addAction: [UIAlertAction actionWithTitle: @"Take Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        // Handle Take Photo here
//    }]];
//    [alertController addAction: [UIAlertAction actionWithTitle: @"Choose Existing Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        // Handle Choose Existing Photo here
//    }]];
//    
//    alertController.modalPresentationStyle = UIModalPresentationPopover;
//    
//    UIPopoverPresentationController * popover = alertController.popoverPresentationController;
//    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
//    popover.sourceView = sender;
//    popover.sourceRect = ((UIButton*)sender).bounds;
//    
//    [self presentViewController: alertController animated: YES completion: nil];
    
//    [sheet showInView:sender];
//    [sheet showFromRect: ((UIButton*)sender).frame inView: ((UIButton*)sender).superview animated: YES];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
 
    int _tmpfilterType = -1;

    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"All"] || buttonIndex == 0) {
        _tmpfilterType = MATCH_ALL;
    } else if  ([buttonTitle isEqualToString:@"Next"] || buttonIndex == 1) {
        _tmpfilterType = MATCH_NEXT;
    } else if  ([buttonTitle isEqualToString:@"Live"] || buttonIndex == 2) {
        _tmpfilterType = MATCH_LIVE;
    } else if  ([buttonTitle isEqualToString:@"FT"] || buttonIndex == 3) {
        
        _tmpfilterType = MATCH_FT;
    }
    
    if(_tmpfilterType != -1 && _tmpfilterType != self.filterType) {
        self.filterType = _tmpfilterType;
        
        if(self.filterType != MATCH_ALL) {
            [self filterMatchesByStatus];
        }
        
        
        
        [self.tableView reloadData];
    }
}


-(void) filterMatchesByStatus
{
    [self.listLivescore_Filter removeAllObjects];
    [self.listLivescoreKeys_Filter removeAllObjects];
    
    
    for (NSUInteger i =0; i<self.listLivescoreKeys.count; i++) {
        NSString* key = [self.listLivescoreKeys objectAtIndex:i];
        NSMutableArray* list = [self.listLivescore objectForKey:key];
        NSMutableArray* tmpList = [NSMutableArray new];
        
        BOOL hasModel = NO;
        for(NSUInteger j=0;j<list.count;j++) {
            LivescoreModel *model = [list objectAtIndex:j];
            
            if(self.filterType == MATCH_LIVE) {
                if(model.iTrangThai == 2 || model.iTrangThai == 3 || model.iTrangThai == 4) {
                    //Live=2,3,4
                    hasModel = YES;
                    
                    [tmpList addObject:model];
                }
            } else if(self.filterType == MATCH_FT) {
                if(model.iTrangThai == 5 || model.iTrangThai == 8 ||
                   model.iTrangThai == 9 || model.iTrangThai == 15) {// fulllllll
                    
                    hasModel = YES;
                    
                    [tmpList addObject:model];
                }
            } else if(self.filterType == MATCH_NEXT) {
                if(model.iTrangThai != 5 && model.iTrangThai != 8 &&
                   model.iTrangThai != 9 && model.iTrangThai != 15 &&
                   model.iTrangThai != 2 && model.iTrangThai != 3 &&
                   model.iTrangThai != 4 ) {
                    
                    hasModel = YES;
                    
                    [tmpList addObject:model];
                }
            }
            
            
        }
        
        if(hasModel) {
            [self.listLivescoreKeys_Filter addObject:key];
            [self.listLivescore_Filter setObject:tmpList forKey:key];
            
        }
    }
}

#pragma  Admob
- (void)adViewDidReceiveAd:(GADBannerView *)view {

    self.tableView.tableHeaderView = view;
    
}

@end
