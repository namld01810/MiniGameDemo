//
//  ExpertReview.m
//  BDLive
//
//  Created by Khanh Le on 3/13/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "ExpertReview.h"
#import "xs_common_inc.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../Models/LivescoreModel.h"

@interface ExpertReview () <SOAPHandlerDelegate>

@property(nonatomic, weak) IBOutlet UIImageView *backImg;
@property(nonatomic, weak) IBOutlet UIImageView *reloadImg;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *reloadIndicatorView;

@property(nonatomic, weak) IBOutlet UIWebView *webView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@end

@implementation ExpertReview

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        
        
        [self fetchNhanDinhChuyenGia_Detail];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupEventHandler];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
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
    
    
    
    // reload button event
    UITapGestureRecognizer *reload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReloadClick:)];
    reload.numberOfTapsRequired = 1;
    self.reloadImg.userInteractionEnabled = YES;
    
    [self.reloadImg addGestureRecognizer:reload];
}



-(void)onBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)onReloadClick:(id)sender
{
    self.reloadImg.hidden = YES;
//    self.reloadIndicatorView.hidden = YES;
    [self.reloadIndicatorView startAnimating];
    [self fetchNhanDinhChuyenGia_Detail];
}

-(void)fetchNhanDinhChuyenGia_Detail
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.chuyengia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
//        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getNhanDinhChuyenGiaChiTiestMessage:self.model.sMaTran sMaNhanDinh:self.model.sMaNhanDinh] soapAction:[PresetSOAPMessage getNhanDinhChuyenGiaChiTietSoapAction]];
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getNhanDinhChuyenGiaTheoTranMessage:[NSString stringWithFormat:@"%lu", self.model.iID_MaTran]] soapAction:[PresetSOAPMessage getNhanDinhChuyenGiaTheoTranSoapAction]];
        
    });
}


-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.reloadImg.hidden = NO;
        self.reloadIndicatorView.hidden = YES;
        [self.reloadIndicatorView stopAnimating];
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
        
    });
    
    
}
-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Nhan_Dinh_Chuyen_Gia_Theo_TranResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Nhan_Dinh_Chuyen_Gia_Theo_TranResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);//NhanDinhChuyenGiaController
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            //sTieuDe, sKey, sAnh, sNoiDung
            NSString *sTieuDe = @"";
            NSString *sKey = @"";
            NSString *sNoiDung = @"";
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                sNoiDung = [dict objectForKey:@"sNoiDung"];
                sTieuDe = [dict objectForKey:@"sTieuDe"];
                sKey = [dict objectForKey:@"sKey"];
            }
            
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.reloadImg.hidden = NO;
                self.reloadIndicatorView.hidden = YES;
                [self.reloadIndicatorView stopAnimating];
                
                self.titleLabel.text = sTieuDe;
                [self.webView loadHTMLString:sNoiDung baseURL:nil];
                
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
}


@end
