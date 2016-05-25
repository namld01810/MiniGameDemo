//
//  StatsViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "StatsViewController.h"
#import "RDVTabBarController.h"
#import "xs_common_inc.h"
#import "BxhView.h"
#import "BxhTableViewCell.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../Models/BxhTeamModel.h"
#import "../Models/AccInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "../AdNetwork/AdNetwork.h"


#define NIB_BXH_CELL @"BxhTableViewCell"



@interface StatsViewController () <UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate, GADBannerViewDelegate>

@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) IBOutlet UIImageView *backImg;

@property(nonatomic, strong) NSMutableArray* datasource;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) IBOutlet UILabel *hdrBxhLabel;

@property(nonatomic) BOOL isCup;

@property(nonatomic, strong) NSMutableDictionary* cupDatasource;
@property(nonatomic, strong) NSMutableArray* cupKeys;


@property(nonatomic, weak) IBOutlet UILabel *leagueHdrTitle;
@property(nonatomic, weak) IBOutlet UIImageView *leagueHdrLogo;

@property(nonatomic, weak) IBOutlet UIView *leagueHdrView;

@property(nonatomic, strong) NSLayoutConstraint* tableConstraint;



@end

@implementation StatsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        
        self.isCup = NO;
        self.cupDatasource = [NSMutableDictionary new];
        self.cupKeys = [NSMutableArray new];
        
        self.tableConstraint = nil;
        
    }
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
    }
    self.leagueHdrView.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [self setupDatasource]; // setup datasource
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib *bxhCell = [UINib nibWithNibName:@"BxhTableViewCell" bundle:nil];
    [self.tableView registerNib:bxhCell forCellReuseIdentifier:NIB_BXH_CELL];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    tap.numberOfTapsRequired = 1;
    self.backImg.userInteractionEnabled = YES;
    
    [self.backImg addGestureRecognizer:tap];
    
    
    NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"hdr-bxh.text", @"BẢNG XẾP HẠNG")];
    self.hdrBxhLabel.text = localizeMsg;
    
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


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.tableView.contentOffset = CGPointMake(0, 0);
    }
    
}

-(void)onBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void) setupDatasource
{
 
    self.datasource = [[NSMutableArray alloc] initWithCapacity:3];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    ZLog(@"[stat] click on settings");
}


#pragma tableview

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.isCup) {
        
        
        return 61.0f;
    }
    return 61.0f;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.isCup) {
        return self.cupKeys.count;
    }
    
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    BxhView *view = [[[NSBundle mainBundle] loadNibNamed:@"BxhViewHeaderSection" owner:nil options:nil] objectAtIndex:0];
    
    if(self.isCup) {
        view.leagueLabel.hidden = YES;
        view.leagueLogo.hidden = YES;
        view.cupHeaderTitle.hidden = NO;
        view.backgroundColor = [UIColor colorWithRed:(24/255.f) green:(27/255.f) blue:(34/255.f) alpha:1.0f];
        
        NSString* key = [self.cupKeys objectAtIndex:section];
        NSString* cupTitle = @"Group";
        NSMutableArray* list = [self.cupDatasource objectForKey:key];
        if(list.count > 0) {
            BxhTeamModel* model = [list objectAtIndex:0];
            cupTitle = model.sTieuDeBXH;
        }
        
        
        view.cupHeaderTitle.text = cupTitle;
    }
    view.leagueLabel.text = self.nameBxh;
    
    
    if([AccInfo sharedInstance].isReview) {
        self.logoBxh = [NSString stringWithFormat:@"%@-isreview", self.logoBxh];
    }


    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.logoBxh]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             
//             image = [XSUtils imageWithImage:image scaledToSize:CGSizeMake(view.leagueLogo.image.size.width, view.leagueLogo.image.size.height)];
             
//             view.leagueLogo.contentMode = UIViewContentModeCenter;
             if (view.leagueLogo.bounds.size.width > image.size.width && view.leagueLogo.bounds.size.height > image.size.height) {
                 view.leagueLogo.contentMode = UIViewContentModeScaleAspectFit;
             } else {
                 view.leagueLogo.contentMode = UIViewContentModeScaleAspectFit;
             }
             
             
             [view.leagueLogo setImage:image];
             
         }
     }];

    
    
    return view;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isCup) {
        NSString* key = [self.cupKeys objectAtIndex:section];
        NSMutableArray* list = [self.cupDatasource objectForKey:key];
        return list.count;
    } else {
        return self.datasource.count;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//    BxhTableViewCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"BxhTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    BxhTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_BXH_CELL];
    
    BxhTeamModel *model = nil;
    if(self.isCup) {
        NSString* key = [self.cupKeys objectAtIndex:indexPath.section];
        NSMutableArray* list = [self.cupDatasource objectForKey:key];
        model = [list objectAtIndex:(indexPath.row - 0)];
    } else {
        model = [self.datasource objectAtIndex:(indexPath.row - 0)];
    }
    
    
    [cell passValue:@[model.sViTri, model.sTenDoi, model.sDiem, model.sSoTranDau, model.sSoTranThang, model.sSoTranHoa, model.sSoTranThua, model.sBanThang, model.sBanThua, model.sHeSo]];
    
    if(indexPath.row%2 == 1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(222/255.f) green:(233/255.f) blue:(251/255.f) alpha:1.0f];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}
-(void) fetchBxhListById
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getBxhSoapMessage:self.iID_MaGiai] soapAction:[PresetSOAPMessage getBxhSoapAction]];
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
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_BangXepHangResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_BangXepHangResult>"] objectAtIndex:0];
        
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
            [self.cupDatasource removeAllObjects];
            
            [self.cupKeys removeAllObjects];
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                BxhTeamModel *model = [BxhTeamModel new];
                model.sTenDoi = [dict objectForKey:@"sTenDoi"];
                model.sViTri = [dict objectForKey:@"sViTri"];
                model.sDiem = [dict objectForKey:@"sDiem"];
                model.sSoTranDau = [dict objectForKey:@"sSoTranDau"];
                model.sSoTranThang = [dict objectForKey:@"sSoTranThang"];
                model.sSoTranHoa = [dict objectForKey:@"sSoTranHoa"];
                model.sSoTranThua = [dict objectForKey:@"sSoTranThua"];
                model.sBanThang = [dict objectForKey:@"sBanThang"];//37
                model.sBanThua = [dict objectForKey:@"sBanThua"];//23
                model.sHeSo = [dict objectForKey:@"sHeSo"];//14
                model.sLast5Match = [dict objectForKey:@"sLast5Match"];
                
                
                model.sTieuDeBXH = [dict objectForKey:@"sTieuDeBXH"];
                model.iChiSoBXH = [(NSNumber*)[dict objectForKey:@"iChiSoBXH"] intValue];
                
                
                if([model.sTieuDeBXH isEqualToString:@""]) {
                    // ko phai dau cup
                    
                    
                } else {
                    // dau cup
                    NSString* cupKey = [NSString stringWithFormat:@"%d", model.iChiSoBXH];
                    NSMutableArray* list = [self.cupDatasource valueForKey:cupKey];
                    if(list == nil) {
                        list = [NSMutableArray new];
                        
                        [self.cupDatasource setObject:list forKey:cupKey];
                        [self.cupKeys addObject:cupKey];
                    }
                    [list addObject:model];
                    
                }
                
                
                
                [self.datasource addObject:model];
                
            }
            
            if(self.cupDatasource.count > 0) {
                self.isCup = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.leagueHdrTitle.text = self.nameBxh;
                [self.loadingIndicator stopAnimating];
                [self.tableView reloadData];
                if (self.isCup) {

                    
                    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.logoBxh]
                                                               options:0
                                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
                     {
                         // progression tracking code
                     }
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                     {
                         if (image)
                         {
                             
                             if (self.leagueHdrLogo.bounds.size.width > image.size.width && self.leagueHdrLogo.bounds.size.height > image.size.height) {
                                 self.leagueHdrLogo.contentMode = UIViewContentModeScaleAspectFit;
                             } else {
                                 self.leagueHdrLogo.contentMode = UIViewContentModeScaleAspectFit;
                             }
                             self.leagueHdrLogo.image = image;
                             
                         }
                     }];
                    
                    
                    self.leagueHdrView.hidden = NO;
                } else {
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:47.0]];
                }
                
                
                
                
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
