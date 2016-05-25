//
//  CarrierViewController.m
//  BDLive
//
//  Created by Khanh Le on 8/31/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "CarrierViewController.h"
#import "AppStoreTableViewCell.h"
#import "IAPItem.h"
#import "xs_common_inc.h"
#import "../../SOAPHandler/SOAPHandler.h"
#import "../../SOAPHandler/PresetSOAPMessage.h"
#import "../../Utils/NSString+MD5.h"
#import "../../Models/AccInfo.h"

#import "inc_iap_nap_sao.h"

#define STAR_UNIT 1000000

static const int NUM_OF_THE_CAO = 3;
// Telco code
static const NSString* TELCO_MOBI = @"VMS";
static const NSString* TELCO_VIETTEL = @"VTEL";
static const NSString* TELCO_VINA = @"GPC";
static const NSString* TELCO_SFONE = @"SFONE";
static const NSString* TELCO_VNMobile = @"VNM";





@interface CarrierViewController () <UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate, UIAlertViewDelegate>

@property(nonatomic, weak) IBOutlet UIView* holderView;
@property(nonatomic, weak) IBOutlet UILabel* carrierTitle;

@property(nonatomic, weak) IBOutlet UITableView* tableView;
@property(nonatomic, strong) NSMutableArray* listProducts;

@property(nonatomic) BOOL isPurchasing;

@end

@implementation CarrierViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.isPurchasing = NO;
        [self setupProductData];
        
        [self fetchListIAPItems];
        
    }
    
    return self;
}

-(void)setupProductData {
    self.listProducts = @[].mutableCopy;
    
#if 0
    IAPItem* i1 = [IAPItem new];
    i1.realPrice = 20.f;
    i1.convertedPrice = 2*STAR_UNIT;
    i1.bundleId = @"com.ls365.item.099";
    
    
    IAPItem* i2 = [IAPItem new];
    i2.realPrice = 50.f;
    i2.convertedPrice = 4*STAR_UNIT;
    i2.bundleId = @"com.ls365.item.199";
    
    IAPItem* i3 = [IAPItem new];
    i3.realPrice = 100.f;
    i3.convertedPrice = 6*STAR_UNIT;
    i3.bundleId = @"com.ls365.item.199";
    
    IAPItem* i4 = [IAPItem new];
    i4.realPrice = 200.f;
    i4.convertedPrice = 8*STAR_UNIT;
    i4.bundleId = @"com.ls365.item.199";
    
    IAPItem* i5 = [IAPItem new];
    i5.realPrice = 500.f;
    i5.convertedPrice = 10*STAR_UNIT;
    i5.bundleId = @"com.ls365.item.199";
    
    [self.listProducts addObjectsFromArray:@[i1,i2,i3,i4,i5]];
#endif

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.holderView.layer.borderWidth = 0.5f;
    [self.holderView.layer setCornerRadius:5.0f];
    

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *cell = [UINib nibWithNibName:@"AppStoreTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"AppStoreTableViewCell"];
    
    if (self.carrierId == _CARRIER_MOBI_FONE_ID_) {
        self.carrierTitle.text = @"Mobifone";
        self.telcoCode = [NSString stringWithFormat:@"%@", TELCO_MOBI];
    } else if(self.carrierId == _CARRIER_VINA_FONE_ID_) {
        self.carrierTitle.text = @"Vinaphone";
        self.telcoCode = [NSString stringWithFormat:@"%@", TELCO_VINA];
    } else {
        self.carrierTitle.text = @"Viettel";
        self.telcoCode = [NSString stringWithFormat:@"%@", TELCO_VIETTEL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)onCloseButtonClicked:(id)sender {

    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma table

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.listProducts.count > 0) {
        return NUM_OF_THE_CAO;
    }
    
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createAppStoreCell:tableView cellForRowAtIndexPath:indexPath];
}

-(AppStoreTableViewCell*) createAppStoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppStoreTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AppStoreTableViewCell"];
    
    
    cell.rightButton.hidden = NO;
    cell.rightPrice.hidden = NO;
    cell.rightPriceStar.hidden = NO;
    
    
    NSString* leftIap = @"ic_iap_1.png";
    NSString* rightIap = @"ic_iap_2.png";
    NSString *priceTxt1, *priceTxt2, *star1, *star2;
    IAPItem *iap1 = nil, *iap2 = nil;
    
    
    if (indexPath.row == 0) {
        iap1 = self.listProducts[0];
        iap2 = self.listProducts[1];
        
        leftIap = @"ic_iap_1.png";
        rightIap = @"ic_iap_2.png";
        
        priceTxt1 = [NSString stringWithFormat:@"%0.0fK", iap1.realPrice];
        priceTxt2 = [NSString stringWithFormat:@"%0.0fK", iap2.realPrice];
        star1 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap1.convertedPrice]];;//
        star2 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap2.convertedPrice]];;//
        cell.leftButton.buttonIndex = 0;
        cell.rightButton.buttonIndex = 1;
        
    } else if(indexPath.row == 1) {
        iap1 = self.listProducts[2];
        iap2 = self.listProducts[3];
        
        leftIap = @"ic_iap_3.png";
        rightIap = @"ic_iap_4.png";
        
        priceTxt1 = [NSString stringWithFormat:@"%0.0fK", iap1.realPrice];
        priceTxt2 = [NSString stringWithFormat:@"%0.0fK", iap2.realPrice];
        star1 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap1.convertedPrice]];;//
        star2 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap2.convertedPrice]];;//
        
        cell.leftButton.buttonIndex = 2;
        cell.rightButton.buttonIndex = 3;
    } else if(indexPath.row == 2) {
        iap1 = self.listProducts[4];
        iap2 = self.listProducts[4];
        
        leftIap = @"ic_iap_5.png";
        rightIap = @"ic_iap_6.png";
        
        priceTxt1 = [NSString stringWithFormat:@"%0.0fK", iap1.realPrice];
        priceTxt2 = [NSString stringWithFormat:@"%0.0fK", iap2.realPrice];
        star1 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap1.convertedPrice]];;//
        star2 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap2.convertedPrice]];;//
        
        cell.leftButton.buttonIndex = 4;
        cell.rightButton.buttonIndex = 5;
        
        cell.rightButton.hidden = YES;
        cell.rightPrice.hidden = YES;
        cell.rightPriceStar.hidden = YES;
    }
    
    
    [cell.leftButton setBackgroundImage:[UIImage imageNamed:leftIap] forState:UIControlStateNormal];
    [cell.rightButton setBackgroundImage:[UIImage imageNamed:rightIap] forState:UIControlStateNormal];
    
    cell.leftPrice.text = priceTxt1;
    cell.rightPrice.text = priceTxt2;
    cell.leftPriceStar.text = star1;
    cell.rightPriceStar.text = star2;
    
    [cell.leftButton addTarget:self action:@selector(onPurchaseClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.rightButton addTarget:self action:@selector(onPurchaseClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    return cell;
}


-(IBAction)onPurchaseClicked:(IAPButton*)sender {
    
    if (self.isPurchasing) {
        return;
    }
    
    self.isPurchasing = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nạp sao" message:@"Bạn hãy nhập vào số seri của thẻ và mã thẻ dưới lớp bạc để thực hiện thanh toán" delegate:self cancelButtonTitle:@"Huỷ" otherButtonTitles:@"Gửi", nil];
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *textField1 = [alert textFieldAtIndex:0];
    UITextField *textField2 = [alert textFieldAtIndex:1];
    textField1.secureTextEntry = NO;
    textField2.secureTextEntry = NO;
    textField1.keyboardType = UIKeyboardTypeNumberPad;
    textField2.keyboardType = UIKeyboardTypeNumberPad;
    textField1.placeholder = @"Mã thẻ";
    textField2.placeholder = @"Số serial";
    
    
    [alert show];
}


-(void)napSao:(NSString*)TelcoCode CardCode:(NSString*)CardCode CardID:(NSString*)CardID {
    SOAPHandler *soapHandler = [SOAPHandler new];
    soapHandler.delegate = self;
    
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iap", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), myQueue, ^{
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        [soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_NapSao_SoapMessage:TelcoCode CardCode:CardCode UserName:account CardID:CardID] soapAction:[PresetSOAPMessage get_wsFootBall_NapSao_SoapAction]];
        
    });
}


-(void)fetchListIAPItems {
    SOAPHandler *soapHandler = [SOAPHandler new];
    soapHandler.delegate = self;
    
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iap", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), myQueue, ^{
        
        
        [soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Get_GoiMuaSao_SoapMessage:4  bLoaiTheCao:1] soapAction:[PresetSOAPMessage get_wsFootBall_Get_GoiMuaSao_SoapAction]];
        
    });
}


#pragma SOAP
-(void)onSoapError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
    });
    self.isPurchasing = NO;
    
}
-(void)onSoapDidFinishLoading:(NSData *)data {
    NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    if ([xmlData rangeOfString:@"<wsFootBall_Get_GoiMuaSaoResult>"].location != NSNotFound) {
        // user info
        [self handle_wsFootBall_Get_GoiMuaSaoResult:xmlData];
        return;
    } else if ([xmlData rangeOfString:@"<wsFootBall_NapSaoResult>"].location != NSNotFound) {
        
        [self handle_wsFootBall_NapSaoResult:xmlData];
        return;
    }
}

-(void)handle_wsFootBall_NapSaoResult:(NSString*)xmlData {
    
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_NapSaoResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_NapSaoResult>"] objectAtIndex:0];

        int statusCode = [jsonStr intValue];
        NSString* msg = @"Lỗi hệ thống";
        
        if (statusCode > 0) {
            // thanh cong
            msg = @"Nạp sao thành công";
        } else if(statusCode == _IAP_CODE_NAP_SAO_1) {
            msg = _IAP_MSG_NAP_SAO_1;
        }else if(statusCode == _IAP_CODE_NAP_SAO_2) {
            msg = _IAP_MSG_NAP_SAO_2;
        }else if(statusCode == _IAP_CODE_NAP_SAO_3) {
            msg = _IAP_MSG_NAP_SAO_3;
        }else if(statusCode == _IAP_CODE_NAP_SAO_4) {
            msg = _IAP_MSG_NAP_SAO_4;
        }else if(statusCode == _IAP_CODE_NAP_SAO_5) {
            msg = _IAP_MSG_NAP_SAO_5;
        }else if(statusCode == _IAP_CODE_NAP_SAO_6) {
            msg = _IAP_MSG_NAP_SAO_6;
        }else if(statusCode == _IAP_CODE_NAP_SAO_8) {
            msg = _IAP_MSG_NAP_SAO_8;
        }else if(statusCode == _IAP_CODE_NAP_SAO_9) {
            msg = _IAP_MSG_NAP_SAO_9;
        }else if(statusCode == _IAP_CODE_NAP_SAO_10) {
            msg = _IAP_MSG_NAP_SAO_10;
        }else if(statusCode == _IAP_CODE_NAP_SAO_11) {
            msg = _IAP_MSG_NAP_SAO_11;
        }else if(statusCode == _IAP_CODE_NAP_SAO_12) {
            msg = _IAP_MSG_NAP_SAO_12;
        }else if(statusCode == _IAP_CODE_NAP_SAO_13) {
            msg = _IAP_MSG_NAP_SAO_13;
        }else if(statusCode == _IAP_CODE_NAP_SAO_14) {
            msg = _IAP_MSG_NAP_SAO_14;
        }else if(statusCode == _IAP_CODE_NAP_SAO_15) {
            msg = _IAP_MSG_NAP_SAO_15;
        }else if(statusCode == _IAP_CODE_NAP_SAO_16) {
            msg = _IAP_MSG_NAP_SAO_16;
        }else if(statusCode == _IAP_CODE_NAP_SAO_90) {
            msg = _IAP_MSG_NAP_SAO_90;
        }else if(statusCode == _IAP_CODE_NAP_SAO_98 ||
                 statusCode == _IAP_CODE_NAP_SAO_99) {
            msg = _IAP_MSG_NAP_SAO_98_99;
        }else if(statusCode == _IAP_CODE_NAP_SAO_100) {
            msg = _IAP_MSG_NAP_SAO_100;
        }else if(statusCode == _IAP_CODE_NAP_SAO_999) {
            msg = _IAP_MSG_NAP_SAO_999;
        } else {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
        });
        
        
    }@catch (NSException *exception) {
        
    }
    
    self.isPurchasing = NO;
}



-(void)handle_wsFootBall_Get_GoiMuaSaoResult:(NSString*)xmlData {
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Get_GoiMuaSaoResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Get_GoiMuaSaoResult>"] objectAtIndex:0];
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            [self.listProducts removeAllObjects];
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                IAPItem* item = [IAPItem new];
                NSString* bundle_id = [dict objectForKey:@"bundle_id"];
                int iID_MaGoi = [(NSNumber*)[dict objectForKey:@"iID_MaGoi"] intValue];
                float real_price = [(NSNumber*)[dict objectForKey:@"real_price"] floatValue];
                NSUInteger so_sao = [(NSNumber*)[dict objectForKey:@"so_sao"] integerValue];
                
                
                item.bundleId = bundle_id;
                item.iID_MaGoi = iID_MaGoi;
                item.realPrice = real_price/1000.f;
                item.convertedPrice = so_sao;
                

                [self.listProducts addObject:item];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            

        }
        
    }
    @catch (NSException *exception) {
        
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField *textField1 = [alertView textFieldAtIndex:0];
        UITextField *textField2 = [alertView textFieldAtIndex:1];
        
        [self napSao:self.telcoCode CardCode:textField1.text CardID:textField2.text];
    } else {
        self.isPurchasing = NO;
    }
    
    
}
@end
