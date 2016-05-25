//
//  NhanDinhChuyenGiaController.m
//  BDLive
//
//  Created by Khanh Le on 1/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "NhanDinhChuyenGiaController.h"
#import "xs_common_inc.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BDLiveGestureRecognizer.h"
#import "LiveScoreHeaderSection.h"
#import "LiveScoreTableViewCell.h"
#import "DetailMatchController.h"
#import "StatsViewController.h"
#import "../Models/LivescoreModel.h"
#import "Perform/PViewController.h"
#import "ExpertReview.h"
#import "GamePredictorViewController.h"
#import "LiveScoreViewController.h"


static NSString* nib_LivescoreCell = @"nib_LivescoreCell";



@interface NhanDinhChuyenGiaController ()<SOAPHandlerDelegate, UITableViewDataSource, UITableViewDelegate>


@property(nonatomic, strong) NSMutableArray* datasource;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) IBOutlet UIImageView *backImg;
@property(nonatomic, strong) IBOutlet UIImageView *loadingImg;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic) NSUInteger currPage;
@property(nonatomic) NSUInteger totalPage;

@end

@implementation NhanDinhChuyenGiaController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.datasource = [NSMutableArray new];
        self.currPage = 0;
        self.totalPage = 1;
        
        [self fetchListNhanDinhChuyenGia];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // setup nib files
    UINib *livescoreCell = [UINib nibWithNibName:@"LiveScoreTableViewCell" bundle:nil];
    [self.tableView registerNib:livescoreCell forCellReuseIdentifier:nib_LivescoreCell];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveScoreHeaderSection" bundle:nil] forHeaderFooterViewReuseIdentifier:@"LiveScoreHeaderSection"];
    // end setup nib files
    
    
    
    
    self.loadingImg.hidden = YES;
    self.backImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    tap.numberOfTapsRequired = 1;
    
    [self.backImg addGestureRecognizer:tap];
    
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReloadClick:)];
    tap.numberOfTapsRequired = 1;
    self.loadingImg.userInteractionEnabled = YES;
    [self.loadingImg addGestureRecognizer:tap2];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}

-(void)onReloadClick:(id)sender
{
    self.loadingImg.hidden = YES;
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
    
    self.currPage = 0;
    self.totalPage = 1;
    
    [self fetchListNhanDinhChuyenGia];
    
}

-(void)onBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if(self.datasource.count > 0) {
        return 1;
    }
    
    return 0;
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.datasource.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    LiveScoreHeaderSection *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LiveScoreHeaderSection"];
    
    
    
    
    LivescoreModel *model = [self.datasource objectAtIndex:0];
    
    
    view.aliasLabel.text = model.sTenGiai;
    
    
    
    
    
    BDLiveGestureRecognizer* tap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onBxhTap:)];
    tap.sTenGiai = view.aliasLabel.text;
    tap.iID_MaTran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
    tap.numberOfTapsRequired = 1;
    tap.logoGiaiUrl = model.sLogoGiai;
    view.bxhView.userInteractionEnabled = YES;
    [view.bxhView addGestureRecognizer:tap];
    
    if(model!= nil) {
        
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:model.sLogoGiai]
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiveScoreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:nib_LivescoreCell];
    [cell resetViewState];

    LivescoreModel *model = [self.datasource objectAtIndex:indexPath.row];
    cell.matchModel = model;
    BDSwipeGestureRecognizer *swipeGesture = [[BDSwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onCellSwipeGestureFired:)];
    swipeGesture.indexPath = indexPath;
    [cell addGestureRecognizer:swipeGesture];
    
    
    // add event
    [cell.performanceInfo addTarget:self action:@selector(onPerformClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.performanceInfo.model = model;
    
    [cell.compPredictor addTarget:self action:@selector(onComputerClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.compPredictor.model = model;
    
    [cell.expertPredictor addTarget:self action:@selector(onExpertClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.expertPredictor.model = model;
    
    
    [cell.favouriteBtn addTarget:self action:@selector(onFavouriteClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.favouriteBtn.model = model;

    
    
    // game du doan
    [cell.setbetButton addTarget:self action:@selector(onMoneyBagClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.setbetButton.model = model;
    if (model.bGameDuDoan) {
        cell.setbetButton.hidden = NO;
    }

    
    // render data now
    [self renderLivescoreDataForCell:cell model:model];
    
    return cell;
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
    
    
    // get device token
    NSString* deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY];
    if(deviceToken!=nil) {
        [self submitFavouriteMatch:deviceToken matran:matran type:favo];
    }
    
}

-(void)onCellSwipeGestureFired:(BDSwipeGestureRecognizer *)gesture
{
    LiveScoreTableViewCell* cell = (LiveScoreTableViewCell*)[self.tableView cellForRowAtIndexPath:gesture.indexPath];
    
    
    LivescoreModel* model = ((LivescoreModel*)cell.matchModel);
    NSString* matran = [NSString stringWithFormat:@"%lu", ((LivescoreModel*)cell.matchModel).iID_MaTran];
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        // mark as favourite
        int favo = model.isFavourite ? 0 : 1;
        
        
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithInt:favo] forKey:matran];
        
        
        
        
        if(favo != 1) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:matran];
        }
        
        // get device token
        NSString* deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY];
        if(deviceToken!=nil) {
            [self submitFavouriteMatch:deviceToken matran:matran type:favo];
        }
        
        ((LivescoreModel*)cell.matchModel).isFavourite = (favo==1 ? YES : NO);
        
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFromLeft;
        animation.duration = 0.7;
        [cell.favouriteBtn.layer addAnimation:animation forKey:nil];
        
        
        cell.favouriteBtn.hidden = (favo==1 ? NO : YES);
        if (!cell.favouriteBtn.hidden) {
            [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_fill.png"] forState:UIControlStateNormal];
        } else {
            cell.favouriteBtn.hidden = NO;
            [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_hidden.png"] forState:UIControlStateNormal];
        }
    }
    
    
}

-(void)submitFavouriteMatch:(NSString*)deviceToken matran:(NSString*)matran type:(int)type
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.BDLive.Submit", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        SOAPHandler* handler = [SOAPHandler new];
        [handler sendAutoSOAPRequest:[PresetSOAPMessage getDeviceLikeSoapMessage:deviceToken matran:matran
                                                                            type:type] soapAction:[PresetSOAPMessage getDeviceLikeSoapAction]];
    });
    
}

-(void)onCellSwipeGestureFired333:(BDSwipeGestureRecognizer *)gesture
{
    LiveScoreTableViewCell* cell = (LiveScoreTableViewCell*)[self.tableView cellForRowAtIndexPath:gesture.indexPath];
    
    
    LivescoreModel* model = ((LivescoreModel*)cell.matchModel);
    NSString* matran = [NSString stringWithFormat:@"%lu", ((LivescoreModel*)cell.matchModel).iID_MaTran];
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        // mark as favourite
        int favo = model.isFavourite ? 0 : 1;
        
        
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithInt:favo] forKey:matran];
        
        ((LivescoreModel*)cell.matchModel).isFavourite = (favo==1 ? YES : NO);
        
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFromLeft;
        animation.duration = 0.7;
        [cell.favouriteBtn.layer addAnimation:animation forKey:nil];
        
        
        cell.favouriteBtn.hidden = (favo==1 ? NO : YES);
        if (!cell.favouriteBtn.hidden) {
            [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_fill.png"] forState:UIControlStateNormal];
        } else {
            cell.favouriteBtn.hidden = NO;
            [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_hidden.png"] forState:UIControlStateNormal];
        }
    }
    
    
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


-(void)onMoneyBagClick:(BDButton*)sender
{
    LivescoreModel *model = sender.model;
    GamePredictorViewController *game = [[GamePredictorViewController alloc] initWithNibName:@"GamePredictorViewController" bundle:nil];
    game.selectedModel = model;
    [self.navigationController pushViewController:game animated:YES];
    
}

-(void)onExpertClick:(BDButton*)sender
{
    LivescoreModel *model = sender.model;
    ExpertReview* exp = [[ExpertReview alloc] initWithNibName:@"ExpertReview" bundle:nil];
    exp.model = model;
    [self.navigationController pushViewController:exp animated:YES]; //sMaTran, sMaNhanDinh
    
    
}

-(void)renderLivescoreDataForCell:(LiveScoreTableViewCell*)cell model:(LivescoreModel*)model
{
    [LiveScoreViewController updateLiveScoreTableViewCell:cell model:model];
    
    
    cell.iID_MaTran = model.iID_MaTran;
    
    cell.matchTimeLabel.text = [XSUtils toDayOfWeek:model.dThoiGianThiDau];
    
    
    cell.keoLabel.text = [model get_sTyLe_ChapBong:model.sTyLe_ChapBong];
    cell.xLabel.text = model.sTyLe_ChauAu_Live;
    cell.uoLabel.text = model.sTyLe_TaiSuu_Live;
    
    //Trạng thái trận đấu: <=1:Chưa đá; 2,4: Đang đá; 3: HT; 5,8,9,15: FT; 6: Bù giờ; 7,14: Pens; 11: Hoãn;  12: CXĐ; 13: Dừng; 16: W.O
    if(model.iTrangThai == 2 || model.iTrangThai == 4 || model.iTrangThai == 3)  {
        // live
        [cell animateFlashLive];
        cell.liveLabel.hidden = NO;
        if(model.iTrangThai == 3) {
            cell.liveLabel.text = @"Live";
            cell.fullTimeLabel.text = @"HT";
            
        } else {
            cell.fullTimeLabel.text = [NSString stringWithFormat:@"%lu'",model.iCN_Phut];
        }
        
        //FT
        NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_FT, (unsigned long)model.iCN_BanThang_DoiKhach_FT];
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_HT, (unsigned long)model.iCN_BanThang_DoiKhach_HT];
        
        cell.finishRetLabel.text = resultFT;
        cell.halfTimeLabel.text = resultHT;
    } else if(model.iTrangThai <= 1) {
        // chua da
        cell.clockImg.hidden = NO;
        cell.fullTimeLabel.text = model.sThoiGian;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
    } else if(model.iTrangThai == 5 || model.iTrangThai == 8 ||
              model.iTrangThai == 9 || model.iTrangThai == 15){
        //FT
        NSString* resultFT = @"";
        if (model.iTrangThai == 8 || model.iTrangThai == 9) {
            resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_ET, model.iCN_BanThang_DoiKhach_ET];
            cell.fullTimeLabel.text = @"AET";
        } else {
            resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_FT, model.iCN_BanThang_DoiKhach_FT];
        }
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_HT, (unsigned long)model.iCN_BanThang_DoiKhach_HT];
        
        cell.finishRetLabel.text = resultFT;
        cell.halfTimeLabel.text = resultHT;
    } else if(model.iTrangThai == 6) {
        // extra time
        cell.fullTimeLabel.text = [NSString stringWithFormat:@"90' + %lu'",model.iPhutThem];
    }else if(model.iTrangThai == 7 || model.iTrangThai == 14) {
        // extra time
        cell.fullTimeLabel.text = @"Pens";
    } else if(model.iTrangThai == 11) {
        // extra time
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"livescore-post-txt", @"Hoãn")];
        

        cell.fullTimeLabel.text = localizedTxt;
        //khanh add
        cell.clockImg.hidden = NO;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
    } else if(model.iTrangThai == 12 || model.iTrangThai == 99) {
        // extra time
        cell.fullTimeLabel.text = @"CXĐ";
        //khanh add
        cell.clockImg.hidden = NO;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
    } else if(model.iTrangThai == 13) {
        // extra time
        cell.fullTimeLabel.text = @"Dừng";
        //khanh add
        cell.clockImg.hidden = NO;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
    }else if(model.iTrangThai == 16) {
        // extra time
        cell.fullTimeLabel.text = @"W.O";
        //khanh add
        cell.clockImg.hidden = NO;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
    }
    
    if(model.bNhanDinhChuyenGia) {
        cell.expertPredictor.hidden = NO;
    }
    if(model.bMayTinhDuDoan) {
        cell.compPredictor.hidden = NO;
    }
    
    if(model.isFavourite) {
        cell.favouriteBtn.hidden = NO;
        [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_fill.png"] forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //iID_MaTran
    
    LiveScoreTableViewCell *cell = (LiveScoreTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    LivescoreModel* model = cell.matchModel;
    
    
    DetailMatchController *detail = [[DetailMatchController alloc] initWithNibName:@"DetailMatchController" bundle:nil];
    detail.iID_MaTran = model.iID_MaTran;
    detail.matchModel = model;
    [detail fetchMatchDetailById];
    
    [self.navigationController pushViewController:detail animated:YES];
}

-(void)onBxhTap:(BDLiveGestureRecognizer*) sender
{
    
    NSString* sTenGiai = sender.sTenGiai;
    NSString* iID_MaTran = sender.iID_MaTran;
    NSString* logoGiaiUrl = sender.logoGiaiUrl;
    
    ZLog(@"retreiving data for bxh: %@", sTenGiai);
    
    LivescoreModel* model = [self.datasource objectAtIndex:0];
    if(model != nil) {
        NSString* iID_MaGiai = [NSString stringWithFormat:@"%lu", model.iID_MaGiai];
        [self fetchBxhByID:iID_MaGiai sTenGiai:sTenGiai logoGiaiUrl:logoGiaiUrl];
    }
    
    
}

-(void) fetchBxhByID:(NSString*)iID_MaGiai sTenGiai:(NSString*)sTenGiai logoGiaiUrl:(NSString*)logoGiaiUrl
{
    ZLog(@"iID_MaGiai: %@", iID_MaGiai);
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StatsViewController* bxh = [storyboard instantiateViewControllerWithIdentifier:@"StatsViewController"];
    bxh.iID_MaGiai = iID_MaGiai;
    bxh.nameBxh = sTenGiai;
    bxh.logoBxh = logoGiaiUrl;
    
    [bxh fetchBxhListById];
    [self.navigationController pushViewController:bxh animated:YES];
}



-(void) fetchListLeageLiveByCountry:(NSString*)iID_MaGiai
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iID_MaQuocGia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getListLivescoreByLeagueSoapMessage:iID_MaGiai] soapAction:[PresetSOAPMessage getListLivescoreByLeagueSoapAction]];
        
    });
    
}


-(void)fetchListNhanDinhChuyenGia
{
    NSString* page = @"";
    

    self.currPage++;
    if(self.currPage > self.totalPage) {
        return;
    }
    
    page = [NSString stringWithFormat:@"%lu", self.currPage];
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.chuyengia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getNhanDinhChuyenGiaMessage:page] soapAction:[PresetSOAPMessage getNhanDinhChuyenGiaSoapAction]];
        
    });
    
}


-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingImg.hidden = NO;
        self.loadingIndicator.hidden = YES;
        [self.loadingIndicator stopAnimating];
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
        
    });
}
-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Lives_Co_NhanDinhChuyenGiaResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Lives_Co_NhanDinhChuyenGiaResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);//NhanDinhChuyenGiaController
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            [self.datasource removeAllObjects]; // remove all objects
            NSString* rootUrlImg = [[NSUserDefaults standardUserDefaults] objectForKey:@"ROOT_URL_IMAGE"];
            
            long currentTime = [[NSDate date] timeIntervalSince1970];
            
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                LivescoreModel *model = [LivescoreModel new];
                
                
                NSString* matchTime = [dict objectForKey:@"dThoiGianThiDau"];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@")/" withString:@""];
                NSUInteger dateLong =[matchTime integerValue]/1000;
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
                model.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] intValue];
                
                //iID_MaDoiNha, iID_MaDoiKhach
                model.iID_MaDoiNha = [(NSNumber*)[dict objectForKey:@"iID_MaDoiNha"] integerValue];
                model.iID_MaDoiKhach = [(NSNumber*)[dict objectForKey:@"iID_MaDoiKhach"] integerValue];
                
                
                model.sDoiNha_BXH = [dict objectForKey:@"sDoiNha_BXH"];
                model.sDoiKhach_BXH = [dict objectForKey:@"sDoiKhach_BXH"];
                
                
//                // new logo way
//                model.sLogoDoiNha = [NSString stringWithFormat:@"%@/Uploads/App/fc-%d.png", rootUrlImg,model.iID_MaDoiNha];
//                model.sLogoDoiKhach = [NSString stringWithFormat:@"%@/Uploads/App/fc-%d.png", rootUrlImg,model.iID_MaDoiKhach];
//                model.sLogoGiai = [NSString stringWithFormat:@"%@/Uploads/App/l-%d.png", rootUrlImg,model.iID_MaGiai];
                
                //sTip
                model.sTip = [dict objectForKey:@"sTip"];
                @try {
                    self.totalPage = [[dict objectForKey:@"totalpage"] intValue];
                }@catch(NSException *ex){
                    self.totalPage = 1;
                }
                
                
                // may tinh du doan va nhan dinh chuyen gia
                model.bMayTinhDuDoan = NO;
                model.bNhanDinhChuyenGia = NO;
                model.bNhanDinhChuyenGia = [[dict objectForKey:@"bNhanDinhChuyenGia"] boolValue];
                model.bMayTinhDuDoan = [[dict objectForKey:@"bMayTinhDuDoan"] boolValue];
                
                model.bGameDuDoan = [[dict objectForKey:@"bGameDuDoan"] boolValue];
                
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
                
                
                model.iCN_Phut = [(NSNumber*)[dict objectForKey:@"iCN_Phut"] integerValue];
                model.iPhutThem = [(NSNumber*)[dict objectForKey:@"iPhutThem"] integerValue];
                
                
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
                
                [model adjustImageURLForReview];
                [LiveScoreViewController update_iCN_Phut_By_LivescoreModel:model c0:currentTime]; // update iCN_Phut by local time
                
                [self.datasource addObject:model];
                
            }
            
            
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.loadingImg.hidden = NO;
                self.loadingIndicator.hidden = YES;
                [self.loadingIndicator stopAnimating];
                [self.tableView reloadData];
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
}


@end
