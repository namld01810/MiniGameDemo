//
//  LeagueDetailViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/16/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "LeagueDetailViewController.h"
#import "xs_common_inc.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../Models/LeagueModel.h"
#import "../Models/AccInfo.h"
#import "LeagueDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LiveScoreViewController.h"
#import "LiveBDController.h"
#import "StatsViewController.h"
#import "../AdNetwork/AdNetwork.h"







@interface LeagueDetailViewController () <UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate, GADBannerViewDelegate>

@property(nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic, strong) IBOutlet UIImageView* flagImg;
@property(nonatomic, strong) IBOutlet UIImageView* backImg;
@property(nonatomic, strong) IBOutlet UILabel* countryName;

@property(nonatomic, strong) IBOutlet UILabel* leagueTitleLabel;

@property(nonatomic, weak) IBOutlet UIImageView* logoImgView;


@property(nonatomic, strong) NSMutableArray* datasource;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@end

@implementation LeagueDetailViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.datasource = [NSMutableArray new];
        self.leagueTitle = nil;
        self.isBxh = NO;
    }
    
    return self;
}



- (void)viewDidLoad {
    NSLog(@"League Here");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.countryName.text = self.countryNameStr;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if(self.leagueTitle != nil) {
        self.leagueTitleLabel.text = self.leagueTitle;
        self.logoImgView.image = [UIImage imageNamed:@"ic_bxh.png"];
    } else {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"hdr-nation.text", @"QUỐC GIA")];

        self.leagueTitleLabel.text = localizeMsg;
    }
    
    
    if([AccInfo sharedInstance].isReview) {
        self.countryFlagStr = [NSString stringWithFormat:@"%@-isreview", self.countryFlagStr];
    }
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.countryFlagStr]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             // do something with image

             [XSUtils adjustUIImageView:self.flagImg image:image];
             [self.flagImg setImage:image];
             
         }
     }];
    
    self.backImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    tap.numberOfTapsRequired = 1;
    [self.backImg addGestureRecognizer:tap];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
    
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHomeSiteClick:)];
    [XSUtils setTableFooter:self.tableView tap:tapGesture];
    
    
    [[AdNetwork sharedInstance] createAdMobBannerView:self admobDelegate:self tableView:self.tableView];
    
}

-(void)onHomeSiteClick:(id)sender {
    NSString *livescoreLink = @"http://livescore007.com/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:livescoreLink]];
}

-(void)onBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeagueDetailTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeagueDetailTableViewCell" owner:nil options:nil] objectAtIndex:0];
    LeagueModel *model = [self.datasource objectAtIndex:indexPath.row];
    cell.model = model;
    cell.leagueName.text = model.sTenGiai;
    
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LeagueDetailTableViewCell *cell = (LeagueDetailTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    LeagueModel *model = cell.model;
    
    if(self.isBxh) {
        // show bxh
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StatsViewController* bxh = [storyboard instantiateViewControllerWithIdentifier:@"StatsViewController"];
        bxh.iID_MaGiai = [NSString stringWithFormat:@"%lu", model.iID_MaGiai];
        bxh.nameBxh = [NSString stringWithFormat:@"%@", model.sTenGiai];
        bxh.logoBxh = [NSString stringWithFormat:@"%@", model.sLogo];
        
        [bxh fetchBxhListById];
        [self.navigationController pushViewController:bxh animated:YES];
    } else {
        // show livescore
        LiveBDController *bd = [[LiveBDController alloc] initWithNibName:@"LiveBDController" bundle:nil];
        bd.iID_MaGiai = model.iID_MaGiai;
        bd.bGiaiCup = model.bGiaiCup;
        bd.selectedDateIndex = 2;
        bd.sTenGiai = model.sTenGiai;
        // khanh add this
        if (bd.bGiaiCup) {
            [bd fetch_wsFootBall_VongDau];
            [bd fetch_wsFootBall_BangXepHang];
            [bd fetch_wsFootBall_SVD];
        } else {
            [bd fetchListLeageLiveByCountry:[NSString stringWithFormat:@"%lu", model.iID_MaGiai]];
        }
        [self.navigationController pushViewController:bd animated:YES];
    }
    
    
}


-(void) fetchListLeageLiveByCountry:(NSString*)iID_MaQuocGia
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iID_MaQuocGia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        NSString* sLang = @"";
        NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (list.count > 0) {
            sLang = [list objectAtIndex:0];
            [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getListLeagueLiveByCountrySoapMessage:iID_MaQuocGia sLang:sLang] soapAction:[PresetSOAPMessage getListLeagueLiveByCountrySoapAction]];
        }
        
        
    });
    
}

-(void) fetchListLeageByCountry:(NSString*)iID_MaQuocGia
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iID_MaQuocGia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (list.count > 0) {
            NSString* sLang = [list objectAtIndex:0];
            [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getListLeagueByCountrySoapMessage:iID_MaQuocGia sLang:sLang] soapAction:[PresetSOAPMessage getListLeagueByCountrySoapAction]];
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
-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString* jsonStr = nil;
        if(self.isBxh) {
            jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Giai_Theo_QuocGiaResult>"] objectAtIndex:1];
            jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Giai_Theo_QuocGiaResult>"] objectAtIndex:0];
        } else {
            jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Giai_Theo_QuocGia_LiveResult>"] objectAtIndex:1];
            jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Giai_Theo_QuocGia_LiveResult>"] objectAtIndex:0];
        }
        
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            [self.datasource removeAllObjects]; // remove all objects
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                LeagueModel *model = [LeagueModel new];
                
                
                model.bGiaiCup = [[dict objectForKey:@"bGiaiCup"] boolValue];
                
                model.sTenGiai = [dict objectForKey:@"sTenGiai"];
                model.sLogo = [dict objectForKey:@"sLogo"];
                model.sMaGiai = [dict objectForKey:@"sMaGiai"];
                
                
                
                
                model.iID_MaQuocGia = [(NSNumber*)[dict objectForKey:@"iID_MaQuocGia"] integerValue];
                model.iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] integerValue];

                if([AccInfo sharedInstance].isReview) {
                    model.sLogo = [NSString stringWithFormat:@"%@-isreview", model.sLogo];
                }
                
                if(model.iID_MaGiai == 28) {
                    // fix C3 for temp
                    model.bGiaiCup = YES;
                }
                
                [self.datasource addObject:model];
            }
            
            
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [self.tableView reloadData];
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
}


#pragma  Admob
- (void)adViewDidReceiveAd:(GADBannerView *)view {

    self.tableView.tableHeaderView = view;
    
}
@end
