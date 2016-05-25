//
//  ChatViewController.m
//  BDLive
//
//  Created by Khanh Le on 3/17/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatItem.h"
#import "xs_common_inc.h"
#import "../../SOAPHandler/SOAPHandler.h"
#import "../../SOAPHandler/PresetSOAPMessage.h"
#import "../../Utils/NSString+MD5.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "../../Models/AccInfo.h"
#import "../CommentBoxView.h"
#import "../TransferAlertView.h"


#define MAX_LENGTH_SAO_INPUT 10

static const int _TRANSFER_CODE_ERROR_NOT_EXIST_ = -4; // ID receiver not existed
static const int _TRANSFER_CODE_ERROR_BALANCE_ = -5; // tai khoan ko du
static const int _TRANSFER_CODE_ERROR_MONEY_ = -6; // so tien chuyen > 0

static const int _TRANSFER_CODE_ERROR_MONEY_UNIT_ = -7; // //Bạn được chuyển tối đa 5,000,000
static const int _TRANSFER_CODE_ERROR_MONEY_BALANCE_OVER1_ = -8; // your balance > 1tr
static const int _TRANSFER_CODE_ERROR_MONEY_NO_PREDICTION_ = -9; // cuoc lon hon 50 tran


@interface TransferUITapGestureRecognizer : UITapGestureRecognizer
@property(nonatomic, strong) NSString* peerID;
@property(nonatomic, strong) NSString* receiverName;
@end



@implementation TransferUITapGestureRecognizer
@end


///////////

@interface ChatViewController () <SOAPHandlerDelegate, UITextFieldDelegate>

@property(nonatomic, strong)NSMutableDictionary *messages;
@property(nonatomic, strong)NSMutableArray *mKey;

@property(nonatomic, strong) IBOutlet UIView* bodyView;

@property(nonatomic, strong) IBOutlet UIImageView* backImgView;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) UIImage *myAvatar;

@property(nonatomic) BOOL isFirst;

@property(nonatomic) BOOL showAnnouncement;


@property(nonatomic, strong) UIView* commentBoxHolder;
@property(nonatomic, strong) CommentBoxView* commentBoxView;

@property(nonatomic, strong) NSString* sNoiDungThongBao;

@end

@implementation ChatViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.soapHandler = [SOAPHandler new];
        self.soapHandler.delegate = self;
        self.mKey = [NSMutableArray new];
        self.isFirst = NO;
        self.showAnnouncement = NO;
        
        [self fetchListMessage:0.1];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        self.soapHandler = [SOAPHandler new];
        self.soapHandler.delegate = self;
        
        [self fetchListMessage:0.1f];
    }
    
    return self;
}

- (void)viewDidLoad {
    self.delegate = self;
    self.dataSource = self;
    

    
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view from its nib.
    if(self.messages == nil) {
        self.messages = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    [self setupCommentBoxView];
    
    self.backImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    tap.numberOfTapsRequired = 1;
    [self.backImgView addGestureRecognizer:tap];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    
    self.messageInputView.textView.placeHolder = @"New Message";
    self.sender = @"Me";
//    [self.bodyView addSubview:self.tableView];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
    
    [self downloadAvatarIfFBAvailable];
}

-(void)downloadAvatarIfFBAvailable
{
    NSString* fbID = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_ID];
    if (fbID) {
        
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
                 
                 
                 self.myAvatar = image;
             }
         }];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma JSMessage

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-chat-room.text", @"Hãy đăng nhập để tham gia thảo luận và bình chọn!")];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    if (YES) {
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];

        NSString* sHash = [NSString stringWithFormat:@"%f-%@", [[NSDate date] timeIntervalSince1970], account];

        sHash = [sHash MD5String];
        
       
        
        [self doSendMessage:text sHash:sHash]; // submit to server now
        
        ChatItem *item = [[ChatItem alloc] init];
        item.body = text;

        item.isSent = YES;
        item.date = date;
        
        [self.mKey addObject:sHash];
        [self.messages setObject:item forKey:sHash];
        
        
        [JSMessageSoundEffect playMessageSentSound];
        
        [self finishSend];
        [self scrollToBottomAnimated:NO];
        
        
        
        
    }
    
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mKey.count;
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* key = [self.mKey objectAtIndex:indexPath.row];
    ChatItem *item = [self.messages objectForKey:key];
    
    if(item.isSent == YES) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString* key = [self.mKey objectAtIndex:indexPath.row];
    ChatItem *item = [self.messages objectForKey:key];
    
    if(item.isSent == YES) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleGreenColor]];
    }
    
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* key = [self.mKey objectAtIndex:indexPath.row];
    ChatItem *item = [self.messages objectForKey:key];

    if(item.isSent) {
        return [[JSMessage alloc] initWithText:item.body sender:@"Me" date:item.date];
    }
    
    return [[JSMessage alloc] initWithText:item.body sender:item.display_name date:item.date];
    

    
}
- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    if([sender isEqualToString:@"Me"]) {
        
        if (self.myAvatar) {
            return [[UIImageView alloc] initWithImage:[JSAvatarImageFactory avatarImage:self.myAvatar croppedToCircle:YES]];
        }
        
        return [[UIImageView alloc] initWithImage:[JSAvatarImageFactory avatarImage:[UIImage imageNamed:@"No_Image_Available.png"] croppedToCircle:YES]];
    }
    
    
    
    // peer avatar display
    NSString* key = [self.mKey objectAtIndex:indexPath.row];
    ChatItem *item = [self.messages objectForKey:key];
    
    __weak ChatItem *_tmpItem = item;
    
    if (item.avatar_url && item.avatar_url.length > 5) {
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:item.avatar_url]
                                                   options:0
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 _tmpItem.avatarImgObj = image;
                 
             }
         }];
    }
    
    
    UIImageView* peerImgView = nil;
    if(item.avatarImgObj) {
        ZLog(@"display peer image");
        peerImgView = [[UIImageView alloc] initWithImage:[JSAvatarImageFactory avatarImage:item.avatarImgObj croppedToCircle:YES]];
    } else {
        peerImgView = [[UIImageView alloc] initWithImage:[JSAvatarImageFactory avatarImage:[UIImage imageNamed:@"No_Image_Available.png"] croppedToCircle:YES]];
    }
    
    
    
    
    TransferUITapGestureRecognizer* tap = [[TransferUITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPeerImageViewTap:)];


    tap.receiverName = item.display_name;
    tap.peerID = item.s_username;
    tap.numberOfTapsRequired = 1;
    peerImgView.userInteractionEnabled = YES;
    
   
    [peerImgView addGestureRecognizer:tap];
    
    return peerImgView;
}

-(void)onPeerImageViewTap:(TransferUITapGestureRecognizer*)sender {

    NSString* peerId = sender.peerID;
    
    
    
    TransferAlertView* alert = [[TransferAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"%@ %@%@", NSLocalizedString(@"acc-reward-stt.text", @"ChuyenKhoan"), @"@", sender.receiverName]];
    [alert setDelegate:self];
    alert.receiverID = peerId;
    
    [alert addButtonWithTitle:@"Ok"];
    alert.cancelButtonIndex = [alert addButtonWithTitle:@"Cancel"];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    
    [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentCenter;
    [alert textFieldAtIndex:0].delegate = self;
    [[alert textFieldAtIndex:0] addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    
    [alert textFieldAtIndex:0].placeholder = NSLocalizedString(@"acc-reward-amount-stt.text", @"Amount"); //Will replace "Password"
    
    
    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(1.0, 0.0);
    [alert setTransform: moveUp];
    [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:cell.contentView andSubViews:YES];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)onBackClick:(id)sender
{
    self.soapHandler.delegate = nil; // cancel delegate
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}


#pragma send message

-(void)doSendMessage:(NSString*)msg sHash:(NSString*)sHash
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.chuyengia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        NSString *urlStr = @"";
        NSString* dispName = account;
        if([AccInfo sharedInstance].dispName) {
            dispName = [AccInfo sharedInstance].dispName;
        }
        
        NSString* fbID = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_ID];
        if (fbID) {
            NSString* userId = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_ID];
            urlStr   = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userId];
            dispName =[[NSUserDefaults standardUserDefaults] objectForKey:FB_ACOUNT_KEY_NAME];
        }
        
        
        
        if (account!=nil) {
            SOAPHandler *soap = [SOAPHandler new];
            soap.delegate = self;
            [soap sendSOAPRequest:[PresetSOAPMessage get_wsAdd_List_Chat_Message:account message:msg avatar:urlStr name:dispName hash:sHash] soapAction:[PresetSOAPMessage get_wsAdd_List_Chat_SoapAction]];
            
            
        }
    });
}

-(void)fetchListMessage:(float)delay
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.chuyengia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_ThongBao_Message] soapAction:[PresetSOAPMessage get_wsFootBall_ThongBao_SoapAction]];
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsGet_List_Chat_Message] soapAction:[PresetSOAPMessage get_wsGet_List_Chat_SoapAction]];
        
        
    });
}

-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    
    // alway to fetch list message after finish or error
    [self fetchListMessage:3.5f];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
    });
}


-(void)handle_wsFootBall_ChuyenKhoanResult:(NSString *)xmlData
{
 
    
    
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_ChuyenKhoan_SecureResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_ChuyenKhoan_SecureResult>"] objectAtIndex:0];
        
        int status = [jsonStr intValue];
        NSString* messageInfo = @"Transfered not successfully!";
        if(status == _TRANSFER_CODE_ERROR_NOT_EXIST_) {
            messageInfo = NSLocalizedString(@"alert-transfer-money-not-existed.text", @"not existed");
        } else if(status == _TRANSFER_CODE_ERROR_MONEY_) {
            messageInfo = NSLocalizedString(@"alert-transfer-money-not-positive.text", @"not existed");
        } else if(status == _TRANSFER_CODE_ERROR_BALANCE_) {
            // tai khoan ko du
            messageInfo = NSLocalizedString(@"alert-transfer-money-balance.text", @"not existed");
        } else if(status == _TRANSFER_CODE_ERROR_MONEY_UNIT_) {
            // chuyen toi da 5tr
            messageInfo = NSLocalizedString(@"alert-transfer-money-unit.text", @"toi da 5tr sao");
        }
        else if(status == _TRANSFER_CODE_ERROR_MONEY_BALANCE_OVER1_) {
            // so du > 1tr
            messageInfo = NSLocalizedString(@"alert-transfer-money-balance-over1.text", @"so du > 1tr");
        }
        else if(status == _TRANSFER_CODE_ERROR_MONEY_NO_PREDICTION_) {
            // so lan du doan > 50tr
            messageInfo = NSLocalizedString(@"alert-transfer-money-no-prediction.text", @"so du > 1tr");
        }
        else if(status >= 0) {
            messageInfo = NSLocalizedString(@"alert-transfer-money-success.text", @"not existed");
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:messageInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        });
        
        
    }@catch(NSException *ex) {
        
    }
}

-(void)onSoapDidFinishLoading:(NSData *)data
{
    NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    @try {
        
        
        if ([xmlData rangeOfString:@"<Add_List_ChatResult>"].location != NSNotFound) {
            // user info
            [self handle_Add_List_ChatResult:xmlData];
            return;
        } else if([xmlData rangeOfString:@"<wsFootBall_ThongBaoResult>"].location != NSNotFound) {
            [self handle_wsFootBall_ThongBaoResult:xmlData];
            return;
        } else if([xmlData rangeOfString:@"<wsFootBall_ChuyenKhoan_SecureResult>"].location != NSNotFound) {
            [self handle_wsFootBall_ChuyenKhoanResult:xmlData];
            return;
        }
        
       
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<Get_List_ChatResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</Get_List_ChatResult>"] objectAtIndex:0];
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            NSMutableArray* indexPathList = [NSMutableArray new];
            NSUInteger lastIndex = -1;
            NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                ChatItem* item = [[ChatItem alloc] init];
                
                
                long TimeStamp = [(NSNumber*)[dict objectForKey:@"TimeStamp"] longValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:TimeStamp];
//                item.timestamp = [NSString stringWithFormat:@"%lu", timeStr];

                item.timestamp = [dict objectForKey:@"sHash"];
                item.s_username = [dict objectForKey:@"User"];
                item.body = [dict objectForKey:@"Chat"];
                item.avatar_url = [dict objectForKey:@"avatar_url"];
                item.display_name = [dict objectForKey:@"display_name"];
                item.date = date;

                
                if ([item.s_username isEqualToString:account]) {
                    // me
                    item.isSent = YES;
                } else {
                    item.isSent = NO;
                }
                


                NSUInteger indexKey = [self.mKey indexOfObject:item.timestamp];
                
                
                if (indexKey != NSNotFound) {
                    // in array already
                    
                } else {
                    // add key to array
                    [self.mKey addObject:item.timestamp];
                    
                    [self.messages setObject:item forKey:item.timestamp];
                    
                    NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForRow:self.mKey.count-1 inSection:0];
                    [indexPathList addObject:insertedIndexPath];
                }
                

                
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSUInteger rows = [self.tableView numberOfRowsInSection:0];
                if(rows > 0 && self.isFirst) {
                    @try {
                        [self.tableView beginUpdates];
                        
                        
                        [self.tableView insertRowsAtIndexPaths:indexPathList withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                    }
                    @catch (NSException *exception) {
                        if(!self.showAnnouncement) {
                            [self.tableView reloadData];
                        }
                        
                    }
                    
                } else {
                    if(!self.showAnnouncement) {
                        [self.tableView reloadData];
                    }
                    if (self.isFirst == NO) {
                        self.isFirst = YES;
                        [self scrollToBottomAnimated:NO];
                    }
                }
                
            });
        }
        
    }@catch(NSException *ex) {
        [self onSoapError:nil];
        return;
    }
    
    
    // alway to fetch list message after finish or error
    [self fetchListMessage:5.5f];

}


-(void)handle_Add_List_ChatResult:(NSString*)xmlData {
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<Add_List_ChatResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</Add_List_ChatResult>"] objectAtIndex:0];
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            for(int i=0;i<bdDict.count;++i) {
//                [0]	(null)	@"timestamp" : (long)1429158089990
                NSDictionary* dict = [bdDict objectAtIndex:i];
                long tmp = [(NSNumber*)[dict objectForKey:@"timestamp"] longValue];
                if(tmp > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self scrollToBottomAnimated:NO];
                    });
                    
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}


#pragma Announcement box
-(void)setupCommentBoxView {
    NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Announcement-Title.txt", @"Announcement")];
    
    CommentBoxView *boxView = [[[NSBundle mainBundle] loadNibNamed:@"CommentBoxView" owner:nil options:nil] objectAtIndex:0];
    boxView.closeButton.hidden = YES;
    boxView.commentLabel.text = localizedTxt;
    [boxView.sendButton setTitle:@"OK" forState:UIControlStateNormal];
    
    [boxView.sendButton addTarget:self action:@selector(onOkCommentBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentBoxHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.commentBoxHolder.backgroundColor = [UIColor colorWithRed:207/255 green:207/255 blue:207/255 alpha:0.3f];
    
    
    float screenW = [UIScreen mainScreen].bounds.size.width * 0.9f;
    float screenH = 0.8f * [UIScreen mainScreen].bounds.size.height - 20.f;
    
    boxView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - screenW/2, 50, screenW, screenH);
    [self.commentBoxHolder addSubview:boxView];
    self.commentBoxView = boxView;
}

-(IBAction)onAnnouncementClick:(id)sender {
    
    [self.view endEditing:YES];
    self.showAnnouncement = YES;
    [self.view addSubview:self.commentBoxHolder];
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFromTop;
    animation.duration = 0.5;
    


    
    NSString* htmlString = [NSString stringWithFormat:@"<p>%@</p>", self.sNoiDungThongBao];
    if (YES && floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        self.commentBoxView.commentTxtView.attributedText = attributedString;
    } else {
        htmlString = [NSString stringWithFormat:@"%@", [XSUtils stringByStrippingHTML:self.sNoiDungThongBao]];
        
        self.commentBoxView.commentTxtView.text = htmlString;
    }
    
    
    
    self.commentBoxView.commentTxtView.editable = NO;
    [self.commentBoxHolder.layer addAnimation:animation forKey:nil];
}

-(void)onOkCommentBoxClicked:(id)sender {
    [self.commentBoxHolder removeFromSuperview];
    self.showAnnouncement = NO;
    [self.tableView reloadData];
}

-(IBAction)onReviewClick:(id)sender {
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id986690061?ls=1&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}


-(void)handle_wsFootBall_ThongBaoResult:(NSString*)xmlData {
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_ThongBaoResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_ThongBaoResult>"] objectAtIndex:0];
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            NSString* sNoiDung = @"";
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                sNoiDung = [dict objectForKey:@"sNoiDung"];
            }
            
            self.sNoiDungThongBao = sNoiDung;
        }
    }
    @catch (NSException *exception) {
        
    }
}




-(void)doTransferMoney:(NSString*)receiverID sotien:(long)sotien
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.transfer", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* idSender = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_ChuyenKhoan_Secure_SoapMessage:idSender UserName_Nhan:receiverID SoTien:sotien] soapAction:[PresetSOAPMessage get_wsFootBall_ChuyenKhoan_Secure_SoapAction]];
        
        
    });
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    
    if ([alertView isKindOfClass:[TransferAlertView class]]) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSString* receiverID = ((TransferAlertView*)alertView).receiverID;
            long sotien = [[[[alertView textFieldAtIndex:0].text stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""] longLongValue];
            
            
            [self doTransferMoney:receiverID sotien:sotien];
            
        }
    }
    
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




-(void)textFieldDidChange:(UITextField *)theTextField
{
    ZLog(@"text changed: %@", theTextField.text);
    
    if (theTextField.text && theTextField.text.length > 2) {
        theTextField.text = [theTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        theTextField.text = [theTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        theTextField.text = [XSUtils format_iBalance:[theTextField.text integerValue]];
    }
    
    
}





@end
