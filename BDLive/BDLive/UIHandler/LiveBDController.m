//
//  LiveBDController.m
//  BDLive
//
//  Created by Khanh Le on 12/16/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "LiveBDController.h"
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
#import "../Models/BxhTeamModel.h"
#import "../Models/CupModel.h"
#import "Perform/PViewController.h"
#import "ExpertReview.h"
#import "GamePredictorViewController.h"
#import "LiveScoreViewController.h"
#import "DAPagesContainer.h"
#import "TableViewController.h"
#import "GroupScrollView.h"
#import "Cup/GroupHeader.h"
#import "BxhView.h"
#import "../Models/AccInfo.h"
#import "BxhTableViewCell.h"
#import "../AdNetwork/AdNetwork.h"


static NSString* nib_LivescoreCell = @"nib_LivescoreCell";

static const int VONG_BANG = 1;
static const int VONG_1_16 = 2;
static const int VONG_1_8 = 3;
static const int VONG_1_4 = 4;
static const int VONG_1_2 = 5;


@interface LiveBDController () <SOAPHandlerDelegate, UITableViewDataSource, UITableViewDelegate, DAPagesContainerTopBarDelegate, GroupHeaderDelegate, GADBannerViewDelegate>

@property(nonatomic, strong) NSMutableArray* datasource;
@property(nonatomic, strong) NSMutableArray* cupList;
@property(nonatomic, strong) NSMutableArray* listMatchModel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopCons;

@property(nonatomic, strong) NSString* sBangActive;
@property(nonatomic, strong) NSString* sDanhSachBang;


@property(nonatomic, strong) NSString* sBangActive_Cup;

@property(nonatomic, strong) NSMutableDictionary* lichDict;

@property(nonatomic, strong) NSMutableDictionary* cupBxhDict;
@property(nonatomic, strong) NSMutableArray* cupBxhKeyList;

@property(nonatomic, strong) NSMutableDictionary* groupDict;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) IBOutlet UIImageView *backImg;
@property(nonatomic, strong) IBOutlet UIImageView *loadingImg;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, weak) IBOutlet UIView *lichView;
@property (strong, nonatomic) DAPagesContainer *pagesContainer;

@property(nonatomic, strong) IBOutlet UILabel *sTenGiaiLabel;


@end

@implementation LiveBDController {
    CGRect tableFrame;
    NSMutableArray *listMatchModelByGroup;
    NSMutableArray *matchGroup;
    NSMutableArray *allMatchList;
    UIImageView *groupHolderBackground;
    NSArray *labelTextRound;
    NSMutableArray *stadiumList;
    NSMutableArray *stadiumDetails;
    NSMutableArray *reloadPosition;
    UITapGestureRecognizer *tapTableView;
    NSInteger scrollBackPosition;
    BOOL isShowStadiumInfo;
    UIView *introsView;
    UIWebView *introsWebview;
    UIButton *closeIntros;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.datasource = [[NSMutableArray alloc] init];
        self.selectedDateIndex = 0;
        self.lichDict = [[NSMutableDictionary alloc]init];;
        self.groupDict = [[NSMutableDictionary alloc]init];
        self.cupList = @[].mutableCopy;
        self.sDanhSachBang = nil;
        
        self.cupBxhDict = [[NSMutableDictionary alloc] init];
        self.cupBxhKeyList = [[NSMutableArray alloc]init];
        
        self.sBangActive = @"C";
        self.sBangActive_Cup = @"C";
        
        self.listMatchModel = [[NSMutableArray alloc] init];
        listMatchModelByGroup = [[NSMutableArray alloc] init];
        stadiumList = [[NSMutableArray alloc]init];
        matchGroup = [[NSMutableArray alloc]init];
        allMatchList = [[NSMutableArray alloc] init];
        labelTextRound = [[NSArray alloc]init];
        reloadPosition = [[NSMutableArray alloc]init];
        stadiumDetails = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(void)setupFixtureView {
    self.pagesContainer = [[DAPagesContainer alloc] init];
    self.pagesContainer.delegate = self;
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = [UIScreen mainScreen].bounds;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.lichView addSubview:self.pagesContainer.view];
    
    self.pagesContainer.selectedPageItemTitleColor = [UIColor greenColor];
    [self.pagesContainer didMoveToParentViewController:self];
    self.pagesContainer.topBarHeight = 27.f;
    
    NSDate* now = [NSDate date];
    NSString* dateFormat = @"d/M";
    TableViewController *con1 = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    con1.itemImageNamed = @"ic_lich_dau.png";
    con1.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:-2];
    
    TableViewController *con2 = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    con2.itemImageNamed = @"ic_lich_dau.png";
    con2.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:-1];
    
    TableViewController *con3 = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    con3.itemImageNamed = @"ic_lich_dau.png";
    con3.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:0];
    
    
    TableViewController *con4 = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    con4.itemImageNamed = @"ic_lich_dau.png";
    con4.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:1];
    TableViewController *con5 = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    con5.itemImageNamed = @"ic_lich_dau.png";
    con5.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:2];
    
    if(self.bGiaiCup) {
        double delayInSeconds = 0.000;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            UIImageView *headerBackground = [[UIImageView alloc]init];
            headerBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
            headerBackground.image = [UIImage imageNamed:@"BG-header.png"];
            
            UIImageView *headerLogo = [[UIImageView alloc] init];
            headerLogo.frame = CGRectMake(30, 0, 44 * 468 / 133, 44);
            headerLogo.image = [UIImage imageNamed:@"Logo-header.png"];
            
            
            [self.headerLiveBDView addSubview:headerBackground];
            [self.headerLiveBDView addSubview:headerLogo];
            
            [self.headerLiveBDView sendSubviewToBack:headerBackground];
        });

        self.icLivescoreImageView.alpha = 0.0f;
        self.pagesContainer.imageViews = @[@"screen2-cut_14.png", @"screen2-cut_11.png", @"screen2-cut_08.png"];
        con1.title = [NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-group-round-txt", @"Group")];
        con2.title = [NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-fixture-list-txt", @"Fixture List")];
        con3.title = [NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-stadium-txt", @"Stadium")];
        self.pagesContainer.viewControllers = @[con1, con2, con3];
        self.pagesContainer.selectedIndex = 0;
    } else {
        self.headerLiveBDView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        self.pagesContainer.imageViews = @[@"ic_lich_dau.png", @"ic_lich_dau.png", @"ic_lich_dau.png", @"ic_lich_dau.png", @"ic_lich_dau.png"];
        self.pagesContainer.viewControllers = @[con1, con2, con3, con4, con5];
        self.pagesContainer.selectedIndex = 2;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.bGiaiCup) {
        self.loadingImg.image = [UIImage imageNamed:@"refresh.png"];
    }
    isShowStadiumInfo = NO;
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self tableViewConfiguration];
        [self setupFixtureView];
        
        // Do any additional setup after loading the view from its nib.
        self.loadingImg.hidden = YES;
        self.backImg.userInteractionEnabled = YES;
        
        // setup nib files
        UINib *livescoreCell = [UINib nibWithNibName:@"LiveScoreTableViewCell" bundle:nil];
        [self.tableView registerNib:livescoreCell forCellReuseIdentifier:nib_LivescoreCell];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"LiveScoreHeaderSection" bundle:nil] forHeaderFooterViewReuseIdentifier:@"LiveScoreHeaderSection"];
        
        
        [self.tableView registerNib:[UINib nibWithNibName:@"GroupHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"GroupHeader"];
        
        UINib *bxhCell = [UINib nibWithNibName:@"BxhTableViewCell" bundle:nil];
        [self.tableView registerNib:bxhCell forCellReuseIdentifier:@"BxhTableViewCell"];
        
        // end setup nib files
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
        tap.numberOfTapsRequired = 1;
        
        [self.backImg addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReloadClick:)];
        tap.numberOfTapsRequired = 1;
        self.loadingImg.userInteractionEnabled = YES;
        [self.loadingImg addGestureRecognizer:tap2];
        
        [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHomeSiteClick:)];
        [XSUtils setTableFooter:self.tableView tap:tapGesture];
        
        if (self.bGiaiCup) {
            self.sTenGiaiLabel.text = @"";
        }
        else {
            self.sTenGiaiLabel.text = self.sTenGiai;
        }
        [[AdNetwork sharedInstance] createAdMobBannerView:self admobDelegate:self tableView:self.tableView];
        groupHolderBackground = [[UIImageView alloc]init];
        [self addRoundBar];
        [self addGroupBar];
        dispatch_time_t popTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
        dispatch_after(popTime1, dispatch_get_main_queue(), ^(void){
            [self fetch_wsFootBall_GetLichThiDau_TheoBang:self.iID_MaGiai sBang:nil];
        });
        tapTableView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
        [self createIntrosView];
    });
}

- (void) addRoundBar {
    NSArray *iconName = [NSArray arrayWithObjects:@"screen3-cut_12.png", @"screen3-cut_14.png", @"screen3-cut_16.png", @"screen3-cut_18.png", nil];
    labelTextRound = [NSArray arrayWithObjects:@"1/16", @"1/8", @"1/4", @"Final", nil];
    int roundCount = 4;
    CGFloat roundHeight = self.fixtureScrollView.frame.size.height;
    CGFloat roundWidth = self.fixtureScrollView.frame.size.width / roundCount;
    self.fixtureScrollView.contentSize = CGSizeMake(roundWidth * roundCount, roundHeight);
    self.fixtureScrollView.showsHorizontalScrollIndicator = NO;
    UIImageView *scrollBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, roundWidth * roundCount, roundHeight)];
    scrollBackground.image = [UIImage imageNamed:@"screen3-cut_02.png"];
    [self.fixtureScrollView addSubview:scrollBackground];
    
    for (int i = 0; i < roundCount; i++) {
        UIView *roundHolder = [[UIView alloc] init];
        roundHolder.frame = CGRectMake(roundWidth * i, 0, roundWidth, roundHeight);
        
        //Add icon
        UIImageView *roundIcon = [[UIImageView alloc] init];
        if (i == 0) {
            roundIcon.frame = CGRectMake(roundWidth/6, 5, (roundHeight - 10) * 72/49, roundHeight - 10);
        }
        else
            roundIcon.frame = CGRectMake(roundWidth/5, 5, (roundHeight - 10) * 53/51, roundHeight - 10);
        roundIcon.image = [UIImage imageNamed:[iconName objectAtIndex:i]];
        [roundHolder addSubview:roundIcon];
        
        //Add label
        UILabel *roundLabel = [[UILabel alloc] init];
        roundLabel.frame = CGRectMake(roundIcon.frame.size.width + 10, 5, roundWidth - roundIcon.frame.size.width - 10, roundHeight- 10);
        roundLabel.text = [labelTextRound objectAtIndex:i];
        roundLabel.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        roundLabel.textColor = [UIColor whiteColor];
        roundLabel.textAlignment = NSTextAlignmentCenter;
        
        roundHolder.tag = i;
        [roundHolder addSubview:roundLabel];
        
        [self.fixtureScrollView addSubview:roundHolder];
        
        //Add tap gesture
        UITapGestureRecognizer *roundTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(roundHolderTap:)];
        [roundHolder addGestureRecognizer:roundTap];
    }
    self.fixtureScrollView.alpha = 0.0f;
}

- (void) addGroupBar {
    int roundCount = 6;
    if (self.iID_MaGiai == 60) {
        roundCount = 4;
    }
    NSArray *groupTitle = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", nil];
    CGFloat roundHeight = self.groupScrollView.frame.size.height;
    CGFloat roundWidth = self.groupScrollView.frame.size.width / roundCount;
    self.groupScrollView.contentSize = CGSizeMake(roundWidth * roundCount, roundHeight);
    self.groupScrollView.showsHorizontalScrollIndicator = NO;
    UIImageView *scrollBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, roundWidth * roundCount, roundHeight*2)];
    scrollBackground.image = [UIImage imageNamed:@"screen3-cut_04.png"];
    [self.groupScrollView addSubview:scrollBackground];
    
    //Add holder background
    groupHolderBackground.frame = CGRectMake(0.5, 1.0, roundWidth - 1.0, roundHeight - 1.5);
    groupHolderBackground.image = [UIImage imageNamed:@"screen3-cut_05.png"];
    
    for (int i = 0; i < roundCount; i++) {
        UIView *roundHolder = [[UIView alloc] init];
        roundHolder.frame = CGRectMake(roundWidth * i, 0, roundWidth, roundHeight);
        //Add bottom border line
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0, roundHeight - 1.0, roundWidth, 1.0f);
        bottomBorder.backgroundColor = [UIColor grayColor].CGColor;
        //[roundHolder.layer addSublayer:bottomBorder];
        
        //Add right border line
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(roundWidth - 0.5, 0, 0.5, roundHeight);
        rightBorder.backgroundColor = [UIColor blueColor].CGColor;
        //[roundHolder.layer addSublayer:rightBorder];
        
        //Add default holderBackground
//        if (i == 0) {
//            [roundHolder addSubview:groupHolderBackground];
//        }
        
        //Add label
        UILabel *roundLabel = [[UILabel alloc]init];
        roundLabel.frame = CGRectMake(0, 0, roundWidth, roundHeight);
        roundLabel.text = [groupTitle objectAtIndex:i];
        //roundLabel.text = [self.cupBxhKeyList objectAtIndex:i]
        roundLabel.textColor = [UIColor whiteColor];
        roundLabel.textAlignment = NSTextAlignmentCenter;
        roundLabel.font = [UIFont fontWithName:@"VNF-FUTURA" size:14.f];
        
        roundHolder.tag = i;
        [roundHolder addSubview:roundLabel];
        [self.groupScrollView addSubview:roundHolder];
        
        //Add tap gesture
        UITapGestureRecognizer *groupTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(groupHolderTap:)];
        [roundHolder addGestureRecognizer:groupTap];
    }
    self.groupScrollView.alpha = 0.0f;

}


//The event handling method
- (void)roundHolderTap:(UITapGestureRecognizer *)recognizer {
    groupHolderBackground.alpha = 1.0f;
    groupHolderBackground.frame = CGRectMake(0.5, 0.5, recognizer.view.frame.size.width - 1.0, recognizer.view.frame.size.height - 1.0);
    [recognizer.view addSubview:groupHolderBackground];
    [recognizer.view sendSubviewToBack:groupHolderBackground];
    [matchGroup removeAllObjects];
    [listMatchModelByGroup removeAllObjects];
    NSString *roundKey;
    if (recognizer.view.tag == 0) {
        roundKey = @"116";
    }
    else if (recognizer.view.tag == 1) {
        roundKey = @"18";
    }
    else if (recognizer.view.tag == 2) {
        roundKey = @"14";
    }
    else if (recognizer.view.tag == 3) {
        roundKey = @"12";
    }
    for (int j = 0; j < [allMatchList count]; j++) {
        if ([roundKey isEqualToString:[[allMatchList objectAtIndex:j] valueForKey:@"sBang"]]) {
            [matchGroup addObject:[allMatchList objectAtIndex:j]];
            [listMatchModelByGroup addObject:[self.listMatchModel objectAtIndex:j]];
        }
    }
    [self.tableView reloadData];
}

- (void)groupHolderTap:(UITapGestureRecognizer *)recognizer {
    groupHolderBackground.alpha = 1.0f;
    groupHolderBackground.frame = CGRectMake(0.5, 0.5, recognizer.view.frame.size.width - 1.0, recognizer.view.frame.size.height - 1.0);
    [recognizer.view addSubview:groupHolderBackground];
    [recognizer.view sendSubviewToBack:groupHolderBackground];
    [matchGroup removeAllObjects];
    [listMatchModelByGroup removeAllObjects];
    for (int j = 0; j < [allMatchList count]; j++) {
        if ([[self.cupBxhKeyList objectAtIndex:recognizer.view.tag] isEqualToString:[[allMatchList objectAtIndex:j] valueForKey:@"sBang"]]) {
            [matchGroup addObject:[allMatchList objectAtIndex:j]];
            [listMatchModelByGroup addObject:[self.listMatchModel objectAtIndex:j]];
        }
    }
    [self.tableView reloadData];
}

-(void)tableViewConfiguration {
    tableFrame = self.tableView.frame;
    if (self.bGiaiCup) {
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

-(void)onHomeSiteClick:(id)sender {
    NSString *livescoreLink = @"http://livescore007.com/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:livescoreLink]];
}

-(void)onReloadClick:(id)sender
{
    if (!self.bGiaiCup) {
        self.loadingImg.hidden = YES;
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimating];
        [self fetchListLeageLiveByCountry:[NSString stringWithFormat:@"%lu", (unsigned long)self.iID_MaGiai]];
    }
    else {
        self.loadingImg.hidden = YES;
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimating];
        self.tableView.alpha = 0.0f;
        
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        if (self.pagesContainer.selectedIndex == 1) {
            groupHolderBackground.alpha = 0.0f;
            matchGroup = [allMatchList mutableCopy];
            listMatchModelByGroup = [self.listMatchModel mutableCopy];
        }
        [self.tableView reloadData];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.2 animations:^{
                self.loadingImg.hidden = NO;
                self.loadingIndicator.hidden = YES;
                [self.loadingIndicator stopAnimating];
                self.tableView.alpha = 1.0f;
            }];
        });
    }
    
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
    
    if (self.bGiaiCup) {
        if (self.pagesContainer.selectedIndex == 0) {
            return [self.cupBxhKeyList count];
        }
        else if (self.pagesContainer.selectedIndex == 1) {
            if ([matchGroup count] == 0) {
                return 1;
            }
            return [matchGroup count];
        }
        else if (self.pagesContainer.selectedIndex == 2) {
            return 1;
        }
        else
            return 0;
    }
    else if (self.datasource.count > 0) {
        return 1;
    }
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.pagesContainer.selectedIndex == 0 && self.bGiaiCup) {
        return 60.0f;
    }
    else if(self.pagesContainer.selectedIndex == 1 && self.bGiaiCup) {
        if ([matchGroup count] == 0)
            return 50.0f;
        return 22.0f;
    }
    else if (self.pagesContainer.selectedIndex == 2 && self.bGiaiCup)
        return 0;
    return 27.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pagesContainer.selectedIndex == 0 && self.bGiaiCup) {
        float x = (self.view.frame.size.width * 542/1018 + 8 - 60)/4;
        return x;
    }
    else if (self.pagesContainer.selectedIndex == 1 && self.bGiaiCup) {
        if ([matchGroup count] == 0) {
            return 0.0f;
        }
        return 60.0f;
    }
    else if (self.pagesContainer.selectedIndex == 2 && self.bGiaiCup) {
        
        if (isShowStadiumInfo) {
            return self.view.frame.size.width * 1.6;
        }
        else
            return self.view.frame.size.width / 2;
    }
    return 96.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.pagesContainer.selectedIndex == 0 && self.bGiaiCup) {
        return 4;
    }
    else if ( self.pagesContainer.selectedIndex == 1 && self.bGiaiCup ) {
        return 1;
    }
    else if ( self.pagesContainer.selectedIndex == 2 && self.bGiaiCup ) {
        if (isShowStadiumInfo) {
            return 1;
        }
        else
            return [stadiumList count];
    }

    return self.datasource.count;
}


-(UIView *)createBxhViewForHeaderInSection {
    BxhView *view = [[[NSBundle mainBundle] loadNibNamed:@"BxhViewHeaderSection" owner:nil options:nil] objectAtIndex:0];
    
    view.leagueLabel.hidden = YES;
    view.leagueLogo.hidden = YES;
    view.cupHeaderTitle.hidden = NO;
    view.backgroundColor = [UIColor colorWithRed:(24/255.f) green:(27/255.f) blue:(34/255.f) alpha:1.0f];
    
    NSString* cupTitle = [NSString stringWithFormat:@"Group %@", self.sBangActive];
    view.cupHeaderTitle.text = cupTitle;
    
    return view;
}

-(UIView *)createGroupViewForHeaderInSection {
    
    GroupHeader *view = [self.tableView  dequeueReusableHeaderFooterViewWithIdentifier:@"GroupHeader"];
    view.scrollView.frame = CGRectMake(0, 1, [UIScreen mainScreen].bounds.size.width, 26);
    view.delegate = self;
    view.itemViews = @[@"A",@"B",@"C",@"D",@"E",@"F"];
    if (self.sDanhSachBang) {
        view.itemViews = [self.sDanhSachBang componentsSeparatedByString:@","];
    }
    [view createGroupLabels];
    [view setSelectedLabel:self.sBangActive];
    
    return view;
}

-(void)onGroupSelected:(int)selectedIndex title:(NSString*)title groupHeader:(GroupHeader*)groupHeader {
    [groupHeader setSelectedLabel:title];
    self.sBangActive = title;
    
    NSMutableArray *ret = [self.groupDict objectForKey:title];
    
    if(ret) {
        [self.datasource removeAllObjects];
        [self.datasource addObjectsFromArray:ret];
        [self.tableView reloadData];
    } else {
        [self fetch_wsFootBall_GetLichThiDau_TheoBang:self.iID_MaGiai sBang:title];
    }
    NSLog(@"group 1 : %@ - %@ - %@", self.sBangActive, title, ret);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (!self.bGiaiCup) {
//        if (self.pagesContainer.selectedIndex == 0 && section == 0 && self.bGiaiCup) {
//            
//            return [self createGroupViewForHeaderInSection];
//        } else if (self.pagesContainer.selectedIndex == 0 && section == 2 && self.bGiaiCup) {
//            
//            return [self createBxhViewForHeaderInSection];
//        }
//        
//        @try {
//            //
//            [self.datasource objectAtIndex:0];
//        }
//        @catch (NSException *exception) {
//            //
//            int x = 122;
//        }
        LiveScoreHeaderSection *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LiveScoreHeaderSection"];
        LivescoreModel *model = [self.datasource objectAtIndex:0];
        view.aliasLabel.text = model.sTenGiai;

        BDLiveGestureRecognizer* tap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onBxhTap:)];
        //
        tap.sTenGiai = view.aliasLabel.text;
        tap.iID_MaTran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
        tap.numberOfTapsRequired = 1;
        tap.logoGiaiUrl = model.sLogoGiai;
        //
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
    else if (self.bGiaiCup && self.pagesContainer.selectedIndex == 0) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:132.0/255.0 blue:166.0/255.0 alpha:1.0f];
        UIView *backGroundImage = [[UIView alloc] init];
        backGroundImage.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, [[UIScreen mainScreen] scale]);
        [[UIImage imageNamed:@"screen2-cut_20-01.png"] drawInRect:CGRectMake(5, 5, self.view.frame.size.width - 10, (self.view.frame.size.width - 10 ) * 542/1018)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        backGroundImage.backgroundColor = [UIColor colorWithPatternImage:image];
        
        UILabel *sectionHeader = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
        sectionHeader.textAlignment = NSTextAlignmentCenter;

        sectionHeader.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"bCup-group-header-txt", @"Group"), [self.cupBxhKeyList objectAtIndex:section]];
        sectionHeader.font = [UIFont fontWithName:@"VNF-FUTURA" size:16.f];
        sectionHeader.textColor = [UIColor whiteColor];
        //cupBxhDict
        
        UILabel *lblCountry = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, self.view.frame.size.width / 3 - 5, 25)];
        lblCountry.textColor = [UIColor whiteColor];
        lblCountry.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-group-country-txt", @"Country")];
        lblCountry.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        lblCountry.textAlignment = NSTextAlignmentCenter;
        
        UILabel *lblPlayed = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 3 + 30, 35, self.view.frame.size.width / 6, 25)];
        lblPlayed.textColor = [UIColor whiteColor];
        lblPlayed.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-group-played-txt", @"Played")];
        lblPlayed.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        
        UILabel *lblGf = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 30, 35, self.view.frame.size.width / 8 - 20, 25)];
        lblGf.textColor = [UIColor whiteColor];
        lblGf.text = @"GF";
        lblGf.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        
        UILabel *lblGA = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 5 / 8 + 20, 35, self.view.frame.size.width / 8 - 20, 25)];
        lblGA.textColor = [UIColor whiteColor];
        lblGA.text = @"GA";
        lblGA.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        
        UILabel *lblGD = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 3 / 4 + 10, 35, self.view.frame.size.width / 8 - 20, 25)];
        lblGD.textColor = [UIColor whiteColor];
        lblGD.text = @"GD";
        lblGD.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        
        UILabel *lblPoint = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 7 / 8 - 15, 35, self.view.frame.size.width / 8 + 15, 25)];
        lblPoint.textColor = [UIColor whiteColor];
        lblPoint.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-group-point-txt", @"Point")];
        lblPoint.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        
        lblPlayed.textAlignment = NSTextAlignmentCenter;
        lblGf.textAlignment = NSTextAlignmentCenter;
        lblGD.textAlignment = NSTextAlignmentCenter;
        lblGA.textAlignment = NSTextAlignmentCenter;
        lblPoint.textAlignment = NSTextAlignmentCenter;
        
        [view addSubview:backGroundImage];
        [view addSubview:sectionHeader];
        [view addSubview:lblCountry];
        [view addSubview:lblPlayed];
        [view addSubview:lblGf];
        [view addSubview:lblGA];
        [view addSubview:lblGD];
        [view addSubview:lblPoint];
        
        return view;
    }
    else if (self.bGiaiCup && self.pagesContainer.selectedIndex == 1) {
        UIView *view = [[UIView alloc] init];
        if ([matchGroup count] > 0) {
            UIImageView *backGroundImage = [[UIImageView alloc] init];
            backGroundImage.image = [UIImage imageNamed:@"screen3-cut_05.png"];
            backGroundImage.frame = CGRectMake(0, 0, self.view.frame.size.width, 22);
            
            UILabel *lblMatchNo = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 22)];
            lblMatchNo.text = [NSString stringWithFormat:@"Match %@", [[matchGroup objectAtIndex:section] valueForKey:@"iVongDau"]];
            lblMatchNo.textColor = [UIColor yellowColor];
            lblMatchNo.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
            
            UILabel *lblMatchTime = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 110, 22)];
            lblMatchTime.textColor = [UIColor whiteColor];
            lblMatchTime.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
            NSString* matchTime = [[matchGroup objectAtIndex:section] valueForKey:@"dThoiGianThiDau"];
            matchTime = [matchTime stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
            matchTime = [matchTime stringByReplacingOccurrencesOfString:@")/" withString:@""];
            
            NSUInteger dateLong =[matchTime integerValue]/1000;
            
            dateLong = [(NSNumber*)[[matchGroup objectAtIndex:section] objectForKey:@"iC0"] longValue];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateLong];
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"EE dd MMM HH:mm"];
            
            
            lblMatchTime.text = [dateFormatter stringFromDate:date];
            
            UILabel *lblMatchStadium = [[UILabel alloc]initWithFrame:CGRectMake(170, 0, self.view.frame.size.width - 180 , 22)];
            lblMatchStadium.text = [[matchGroup objectAtIndex:section] valueForKey:@"SanVanDong"];
            lblMatchStadium.textColor = [UIColor whiteColor];
            lblMatchStadium.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
            lblMatchStadium.textAlignment = NSTextAlignmentRight;
            
            UIButton *stadiumMapping = [[UIButton alloc] initWithFrame:lblMatchStadium.frame];
            stadiumMapping.tag = section;
            [stadiumMapping addTarget:self  action:@selector(stadiumMapping:) forControlEvents:UIControlEventTouchDown];
            
            [view addSubview:backGroundImage];
            [view addSubview:lblMatchNo];
            [view addSubview:lblMatchTime];
            [view addSubview:lblMatchStadium];
            [view addSubview:stadiumMapping];
        }
        else {
            UILabel *noResult = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
            noResult.text = @"No Result";
            
            noResult.textColor = [UIColor grayColor];
            noResult.font = [UIFont fontWithName:@"VNF-FUTURA" size:27.f];
            noResult.textAlignment = NSTextAlignmentCenter;
            
            [view addSubview:noResult];
        }
        return view;
    }
    else
        return nil;
}



- (UITableViewCell *) createBxhTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BxhTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"BxhTableViewCell"];
    BxhTeamModel *model = nil;
    NSString* key = self.sBangActive;
    NSMutableArray* list = [self.cupBxhDict objectForKey:key];
    model = [list objectAtIndex:(indexPath.row - 0)];
    
    [cell passValue:@[model.sViTri, model.sTenDoi, model.sDiem, model.sSoTranDau, model.sSoTranThang, model.sSoTranHoa, model.sSoTranThua, model.sBanThang, model.sBanThua, model.sHeSo]];
    
    if(indexPath.row%2 == 1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(222/255.f) green:(233/255.f) blue:(251/255.f) alpha:1.0f];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiveScoreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:nib_LivescoreCell];
    
    if (!self.bGiaiCup) {
        [cell resetViewState];
        LivescoreModel *model = [self.datasource objectAtIndex:indexPath.row];
        cell.matchModel = model;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
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
        
        // game du doan
        [cell.setbetButton addTarget:self action:@selector(onMoneyBagClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.setbetButton.model = model;
        if (model.bGameDuDoan) {
            cell.setbetButton.hidden = NO;
        }
        
        [cell.favouriteBtn addTarget:self action:@selector(onFavouriteClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.favouriteBtn.model = model;
        
        // render data now
        [self renderLivescoreDataForCell:cell model:model];
    }
    else {
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
        if  (self.pagesContainer.selectedIndex == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:132.0/255.0 blue:166.0/255.0 alpha:1.0f];
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                
                
                BxhTeamModel *model = [[self.cupBxhDict objectForKey:[self.cupBxhKeyList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                
                
                UIImageView *imgBackground = [[UIImageView alloc] init];
                imgBackground.frame = CGRectMake(5, 0, cell.frame.size.width - 10, (self.view.frame.size.width * 542/1018 + 8 - 60)/4);
                imgBackground.image = [UIImage imageNamed:@"screen2-cut_20-03.png"];
                if (indexPath.row == [[self.cupBxhDict objectForKey:[self.cupBxhKeyList objectAtIndex:indexPath.section] ]count] - 1) {
                    imgBackground.image = [UIImage imageNamed:@"screen2-cut_20-04.png"];
                }
                [cell.contentView addSubview:imgBackground];
                float rowHeight = imgBackground.frame.size.height;
                UIImageView *imgLogo = [[UIImageView alloc] init];
                
                
                if(model!= nil) {
                    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:model.sLogo]
                                                               options:0
                                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
                     {
                         // progression tracking code
                     }
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                     {
                         if (image)
                         {
                             
                             [XSUtils adjustUIImageView:imgLogo image:image];
                             [imgLogo setImage:image];
                             
                         }
                     }];
                }
                imgLogo.frame = CGRectMake(rowHeight/2 , 5, rowHeight - 10, rowHeight - 10);
                imgLogo.layer.cornerRadius = (rowHeight - 10)/2;
                imgLogo.clipsToBounds = YES;
                
                imgLogo.layer.borderWidth = 1.0f;
                imgLogo.layer.borderColor = [UIColor colorWithRed:150.0/255.0 green:200.0/255.0 blue:1.0 alpha:0.8f].CGColor;
                
                UILabel *lblCountry = [[UILabel alloc] initWithFrame:CGRectMake( rowHeight * 3 / 2, 0, self.view.frame.size.width / 3 + 30 - rowHeight / 2, rowHeight)];
                lblCountry.textColor = [UIColor whiteColor];
                lblCountry.text = model.sTenDoi;
                lblCountry.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
                lblCountry.lineBreakMode = UILineBreakModeCharacterWrap;
                
                
                UILabel *lblPlayed = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 3 + 30, 0, self.view.frame.size.width / 6, rowHeight)];
                lblPlayed.textColor = [UIColor whiteColor];
                lblPlayed.text = model.sSoTranDau;
                lblPlayed.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
                
                UILabel *lblGf = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 30, 0, self.view.frame.size.width / 8 - 20, rowHeight)];
                lblGf.textColor = [UIColor whiteColor];
                lblGf.text = model.sBanThang;
                lblGf.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
                
                UILabel *lblGA = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 5 / 8 + 20, 0, self.view.frame.size.width / 8 - 20, rowHeight)];
                lblGA.textColor = [UIColor whiteColor];
                lblGA.text = model.sBanThua;
                lblGA.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
                
                UILabel *lblGD = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 3 / 4 + 10, 0, self.view.frame.size.width / 8 - 20, rowHeight)];
                lblGD.textColor = [UIColor whiteColor];
                lblGD.text = model.sHeSo;
                lblGD.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
                
                UILabel *lblPoint = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 7 / 8 - 15, 0, self.view.frame.size.width / 8 + 15, rowHeight)];
                lblPoint.textColor = [UIColor whiteColor];
                lblPoint.text = model.sDiem;
                lblPoint.font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
                
                lblPlayed.textAlignment = NSTextAlignmentCenter;
                lblGf.textAlignment = NSTextAlignmentCenter;
                lblGD.textAlignment = NSTextAlignmentCenter;
                lblGA.textAlignment = NSTextAlignmentCenter;
                lblPoint.textAlignment = NSTextAlignmentCenter;
                
                [cell.contentView addSubview:lblCountry];
                [cell.contentView addSubview:lblPlayed];
                [cell.contentView addSubview:lblGf];
                [cell.contentView addSubview:lblGA];
                [cell.contentView addSubview:lblGD];
                [cell.contentView addSubview:lblPoint];
                [cell.contentView addSubview:imgLogo];
                
            });
        }
        else if (self.pagesContainer.selectedIndex == 1 ) {
            
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            UIImageView *cellBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
            cellBackground.image = [UIImage imageNamed:@"Gradient-BG_02.png"];
            
            UIImageView *logoHome = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 25 , 15, 30, 30)];
            
            if( matchGroup != nil) {
                [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:[[matchGroup objectAtIndex:indexPath.section] valueForKey:@"sLogoDoiNha"]]
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize)
                 {
                     // progression tracking code
                 }
                                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                 {
                     if (image)
                     {
                         
                         [XSUtils adjustUIImageView:logoHome image:image];
                         [logoHome setImage:image];
                         
                     }
                     
//                     else {
//                         [logoHome setImage:[UIImage imageNamed:@"tbdPlayer.png"]];
//                     }
                 }];
            }
            logoHome.layer.cornerRadius = 15;
            logoHome.clipsToBounds = YES;
            
            logoHome.layer.borderWidth = 1.0f;
            logoHome.layer.borderColor = [UIColor colorWithRed:150.0/255.0 green:200.0/255.0 blue:1.0 alpha:0.8f].CGColor;
            
            
            UIImageView *logoGuest = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 23 / 24 - 30, 15, 30, 30)];
            
            if( matchGroup != nil) {
                [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:[[matchGroup objectAtIndex:indexPath.section] valueForKey:@"sLogoDoiKhach"]]
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize)
                 {
                     // progression tracking code
                 }
                                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                 {
                     if (image)
                     {
                         
                         [XSUtils adjustUIImageView:logoGuest image:image];
                         [logoGuest setImage:image];
                         
                     }
                     
//                     else {
//                         [logoGuest setImage:[UIImage imageNamed:@"tbdPlayer.png"]];
//                     }
                 }];
            }
            logoGuest.layer.cornerRadius = 15;
            logoGuest.clipsToBounds = YES;
            
            logoGuest.layer.borderWidth = 1.0f;
            logoGuest.layer.borderColor = [UIColor colorWithRed:150.0/255.0 green:200.0/255.0 blue:1.0 alpha:0.8f].CGColor;
            
            UILabel *homePlayer = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 25 + 30, 0, self.view.frame.size.width / 5, 60)];
            homePlayer.textColor = [UIColor whiteColor];
            homePlayer.font = [UIFont fontWithName:@"VNF-FUTURA" size:14.f];
            homePlayer.text = [[matchGroup objectAtIndex:indexPath.section] valueForKey:@"sTenDoiNha"];
            homePlayer.textAlignment = NSTextAlignmentRight;
            homePlayer.numberOfLines = 2;
            
            if ([homePlayer.text containsString:@"2nd Group"] ) {
                homePlayer.text = [homePlayer.text stringByReplacingOccurrencesOfString:@"2nd Group" withString:@"2nd\nGroup"];
            }
            
            UILabel *guestPlayer = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 19 / 25 - 30, 0, self.view.frame.size.width / 5, 60)];
            guestPlayer.textColor = [UIColor whiteColor];
            guestPlayer.font = [UIFont fontWithName:@"VNF-FUTURA" size:14.f];
            guestPlayer.text = [[matchGroup objectAtIndex:indexPath.section] valueForKey:@"sTenDoiKhach"];
            guestPlayer.textAlignment = NSTextAlignmentLeft;
            guestPlayer.numberOfLines = 2;
            
            if ([guestPlayer.text containsString:@"2nd Group"] ) {
                guestPlayer.text = [guestPlayer.text stringByReplacingOccurrencesOfString:@"2nd Group" withString:@"2nd\nGroup"];
            }
            
            if (self.view.frame.size.width == 320) {
                homePlayer.font = [UIFont fontWithName:@"VNF-FUTURA" size:12.f];
                guestPlayer.font = [UIFont fontWithName:@"VNF-FUTURA" size:12.f];
            }
            
            UILabel *matchResult = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 6 / 25 + 40, 0, self.view.frame.size.width / 3.5, 60)];
            matchResult.center = CGPointMake(self.view.frame.size.width/2, 30);
            matchResult.textColor = [UIColor whiteColor];
            matchResult.font = [UIFont fontWithName:@"VNF-FUTURA" size:30.0f];
            matchResult.text = @"-";
            matchResult.textAlignment = NSTextAlignmentCenter;
            
            UILabel *homePlayerResult = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 6 / 25 + 43, 0, self.view.frame.size.width / 11, 60)];
            homePlayerResult.textColor = [UIColor whiteColor];
            homePlayerResult.font = [UIFont fontWithName:@"VNF-FUTURA" size:14.f];
            homePlayerResult.text = [NSString stringWithFormat:@"%@", [[matchGroup objectAtIndex:indexPath.section] valueForKey:@"iCN_BanThang_DoiNha"]];
            homePlayerResult.textAlignment = NSTextAlignmentCenter;
            
            UILabel *guestPlayerResult = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 184 / 275 - 43, 0, self.view.frame.size.width / 11, 60)];
            guestPlayerResult.textColor = [UIColor whiteColor];
            guestPlayerResult.font = [UIFont fontWithName:@"VNF-FUTURA" size:14.f];
            guestPlayerResult.text = [NSString stringWithFormat:@"%@", [[matchGroup objectAtIndex:indexPath.section] valueForKey:@"iCN_BanThang_DoiKhach"]];
            guestPlayerResult.textAlignment = NSTextAlignmentCenter;
            
            UIImageView *homeResultBoder = [[UIImageView alloc] initWithFrame:CGRectMake(homePlayerResult.frame.origin.x - 5, 0, self.view.frame.size.width / 11 + 10, (self.view.frame.size.width / 11 + 10) * 67 / 128)];
            homeResultBoder.image = [UIImage imageNamed:@"screen3-cut_28.png"];
            homeResultBoder.center = CGPointMake(homeResultBoder.center.x, 30);
            
            UIImageView *guestResultBoder = [[UIImageView alloc] initWithFrame:CGRectMake(guestPlayerResult.frame.origin.x - 5, 0, self.view.frame.size.width / 11 + 10, (self.view.frame.size.width / 11 + 10 ) * 67 / 128)];
            guestResultBoder.image = [UIImage imageNamed:@"screen3-cut_28.png"];
            guestResultBoder.center = CGPointMake(guestResultBoder.center.x, 30);
            
            if ( [[[matchGroup objectAtIndex:indexPath.row] objectForKey:@"iTrangThai"] integerValue] == 1) {
                homePlayerResult.text = @"";
                guestPlayerResult.text = @"";
            }
            
            [cell.contentView addSubview:cellBackground];
            [cell.contentView addSubview:logoHome];
            [cell.contentView addSubview:logoGuest];
            [cell.contentView addSubview:homePlayer];
            [cell.contentView addSubview:guestPlayer];
            [cell.contentView addSubview:matchResult];
            [cell.contentView addSubview:homePlayerResult];
            [cell.contentView addSubview:guestPlayerResult];
            [cell.contentView addSubview:homeResultBoder];
            [cell.contentView addSubview:guestResultBoder];
            
            
        }
        else if (self.pagesContainer.selectedIndex == 2) {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            if (!isShowStadiumInfo) {
                //SVD
                UIImageView *imgStadium = [[UIImageView alloc] init];
                imgStadium.frame = CGRectMake(0, 3, self.view.frame.size.width, self.view.frame.size.width / 2 - 3);
                
                if ([stadiumList objectAtIndex:indexPath.row] != nil) {
                    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:[[stadiumList objectAtIndex:indexPath.row] valueForKey:@"sAnh1"]]
                                                               options:0
                                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
                     {
                         
                     }
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                     {
                         if (image)
                         {
                             [XSUtils adjustUIImageView:imgStadium image:image];
                             [imgStadium setContentMode:UIViewContentModeScaleAspectFill];
                             [imgStadium setClipsToBounds:YES];
                             [imgStadium setImage:image];
                         }
                     }];
                }
                
                
                
                [cell.contentView addSubview:imgStadium];
                
                UILabel *lblStadiumName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width/8 , self.view.frame.size.width, self.view.frame.size.width/8)];
                lblStadiumName.text = [[stadiumList objectAtIndex:indexPath.row] objectForKey:@"sTenSVD"];
                
                lblStadiumName.font = [UIFont fontWithName:@"UTM-Neo-Sans-Intel" size:30.f];
                lblStadiumName.textColor = [UIColor colorWithRed:194.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1];
                lblStadiumName.textAlignment = NSTextAlignmentCenter;
                
                lblStadiumName.layer.shadowColor = [[UIColor blackColor] CGColor];
                lblStadiumName.layer.shadowOffset = CGSizeMake(0.3f, 1.0f);
                lblStadiumName.layer.shadowOpacity = 1.0f;
                lblStadiumName.layer.shadowRadius = 1.0f;
                
                UILabel *lblStadiumCity = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width/4, self.view.frame.size.width, self.view.frame.size.width/8)];
                lblStadiumCity.text = [[stadiumList objectAtIndex:indexPath.row]objectForKey:@"sThanhPho"];
                lblStadiumCity.font = [UIFont fontWithName:@"UTMNeoSansIntelBold" size:30.f];
                lblStadiumCity.textColor = [UIColor whiteColor];
                lblStadiumCity.textAlignment = NSTextAlignmentCenter;
                
                lblStadiumCity.layer.shadowColor = [[UIColor blackColor] CGColor];
                lblStadiumCity.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
                lblStadiumCity.layer.shadowOpacity = 1.0f;
                lblStadiumCity.layer.shadowRadius = 1.0f;
                
                [cell.contentView addSubview:lblStadiumName];
                [cell.contentView addSubview:lblStadiumCity];
                
                lblStadiumCity.alpha = 0.4f;
                lblStadiumName.alpha = 0.4f;
                imgStadium.alpha = 0.4f;
                
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [UIView animateWithDuration:0.2 animations:^{
                        lblStadiumCity.alpha = 1.0f;
                        lblStadiumName.alpha = 1.0f;
                        imgStadium.alpha = 1.0f;
                    }];
                });
            }
            else {
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *headerBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 238 / 1080)];
                headerBackground.image = [UIImage imageNamed:@"screen5_02.png"];
                
                UILabel *lblStadiumName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , self.view.frame.size.width / 2, self.view.frame.size.width/14)];
                lblStadiumName.text = [stadiumDetails valueForKey:@"sThanhPho"];
                
                lblStadiumName.font = [UIFont fontWithName:@"UTMNeoSansIntelBold" size:20.f];
                lblStadiumName.textColor = [UIColor colorWithRed:194.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1];
                
                lblStadiumName.layer.shadowColor = [[UIColor blackColor] CGColor];
                lblStadiumName.layer.shadowOffset = CGSizeMake(0.3f, 1.0f);
                lblStadiumName.layer.shadowOpacity = 1.0f;
                lblStadiumName.layer.shadowRadius = 1.0f;
                
                UILabel *lblStadiumCity = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.width/14, self.view.frame.size.width / 2, self.view.frame.size.width/7)];
                NSString *stadiumNameStr = [stadiumDetails valueForKey:@"sTenSVD"];
                if (stadiumNameStr.length <= 22) {
                    lblStadiumCity.text = [NSString stringWithFormat:@"%@\n", stadiumNameStr];
                }
                else
                    lblStadiumCity.text = stadiumNameStr;
                lblStadiumCity.font = [UIFont fontWithName:@"UTMNeoSansIntelBold" size:18.f];
                if (self.view.frame.size.width == 320) {
                    lblStadiumCity.font = [UIFont fontWithName:@"UTMNeoSansIntelBold" size:16.f];
                }
                lblStadiumCity.textColor = [UIColor whiteColor];
                lblStadiumCity.numberOfLines = 0;
                lblStadiumCity.layer.shadowColor = [[UIColor blackColor] CGColor];
                lblStadiumCity.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
                lblStadiumCity.layer.shadowOpacity = 1.0f;
                lblStadiumCity.layer.shadowRadius = 1.0f;
                
                
                UIFont *font;
                if (self.view.frame.size.width == 320) {
                    font = [UIFont fontWithName:@"VNF-FUTURA" size:12.f];
                }
                else
                    font = [UIFont fontWithName:@"VNF-FUTURA" size:14.f];
                UIButton *introsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 2/3, 0, self.view.frame.size.width / 3 - 10, 30)];
                UILabel *introsButtonText = [[UILabel alloc] initWithFrame:introsButton.frame];
                
                [introsButton addTarget:self  action:@selector(callIntrosView) forControlEvents:UIControlEventTouchDown];
                introsButtonText.textAlignment = NSTextAlignmentRight;
                introsButtonText.textColor = [UIColor whiteColor];
                introsButtonText.font = [UIFont fontWithName:@"VNF-FUTURA" size:12.f];
                NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
                introsButtonText.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",NSLocalizedString(@"bCup-intros-hyper-txt", @"Introduces")] attributes:underlineAttribute];
                
                UILabel *lblCapacity = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, headerBackground.frame.size.height/2, headerBackground.frame.size.width/2 - 10, headerBackground.frame.size.height/2)];
                NSString *capaStr = [stadiumDetails valueForKey:[NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-stadium-capacity-txt", @"sSucChua")]];
                
                capaStr = [capaStr stringByReplacingOccurrencesOfString:@". " withString:@".\n"];
                lblCapacity.font = font;
                lblCapacity.numberOfLines = 2;
                lblCapacity.textAlignment = NSTextAlignmentRight;
                lblCapacity.textColor = [UIColor whiteColor];
                lblCapacity.text = capaStr;
                
                UIScrollView *crvImage = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerBackground.frame.size.height, self.view.frame.size.width , self.view.frame.size.width * 3 / 4)];
                
                
                UIImageView *ivSAnh1 = [[UIImageView alloc] init];
                
                if ([stadiumList objectAtIndex:indexPath.row] != nil) {
                    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:[stadiumDetails valueForKey:@"sAnh1"]]
                                                               options:0
                                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
                     {
                         
                     }
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                     {
                         if (image)
                         {
                             ivSAnh1.frame = CGRectMake(3, 3, self.view.frame.size.width * 3 / 4 * image.size.width / image.size.height, self.view.frame.size.width * 3 / 4);
                             [XSUtils adjustUIImageView:ivSAnh1 image:image];
                             [ivSAnh1 setImage:image];
                             crvImage.contentSize = CGSizeMake(ivSAnh1.frame.size.width + 3, ivSAnh1.frame.size.height );
                         }
                     }];
                }

                [crvImage addSubview:ivSAnh1];
                
                UIImageView *ivSAnh111 = [[UIImageView alloc] init];
                
                
                if ([stadiumList objectAtIndex:indexPath.row] != nil) {
                    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:[stadiumDetails valueForKey:@"sAnh111"]]
                                                               options:0
                                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
                     {
                         
                     }
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                     {
                         if (image)
                         {
                             ivSAnh111.frame = CGRectMake(ivSAnh1.frame.size.width + 6, 3, self.view.frame.size.width * 3 / 4 * image.size.width / image.size.height, self.view.frame.size.width * 3 / 4);
                             [XSUtils adjustUIImageView:ivSAnh111 image:image];
                             [ivSAnh111 setImage:image];
                             crvImage.contentSize = CGSizeMake(ivSAnh1.frame.size.width + ivSAnh111.frame.size.width + 9, ivSAnh1.frame.size.height );
                         }
                     }];
                }
                [crvImage addSubview:ivSAnh111];
                
                UIImageView *ivSAnh112 = [[UIImageView alloc] init];
                
                if ([stadiumList objectAtIndex:indexPath.row] != nil) {
                    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:[stadiumDetails valueForKey:@"sAnh112"]]
                                                               options:0
                                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
                     {
                         
                     }
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                     {
                         if (image)
                         {
                             ivSAnh112.frame = CGRectMake(ivSAnh1.frame.size.width + ivSAnh111.frame.size.width + 9, 3, self.view.frame.size.width * 3 / 4 * image.size.width / image.size.height, self.view.frame.size.width * 3 / 4);
                             [XSUtils adjustUIImageView:ivSAnh112 image:image];
                             [ivSAnh112 setImage:image];
                             crvImage.contentSize = CGSizeMake(ivSAnh1.frame.size.width + ivSAnh111.frame.size.width + ivSAnh112.frame.size.width + 12, ivSAnh1.frame.size.height);
                         }
                     }];
                }
                [crvImage addSubview:ivSAnh112];
                [crvImage setShowsHorizontalScrollIndicator:NO];
                [crvImage setShowsVerticalScrollIndicator:NO];
                [cell.contentView addSubview:crvImage];
                
                
                UILabel *lblNote = [[UILabel alloc]init];
                
                /*
                 NSString *string = @"123-456-7890";
                 int times = [[string componentsSeparatedByString:@"-"] count]-1;
                 
                 NSLog(@"Counted times: %i", times);
                 */
                NSString *noteStr = [stadiumDetails valueForKey:[NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-stadium-note-txt", @"sGhiChu")]];
                
                NSInteger times = [[noteStr componentsSeparatedByString:@"\n"] count];
                
                lblNote.frame = CGRectMake(10, headerBackground.frame.size.height + self.view.frame.size.width * 3 / 4, self.view.frame.size.width - 20, times * 22);
                
                NSLog(@"Counted times: %li", (long)times);
                
                lblNote.text = noteStr;
                lblNote.textColor = [UIColor blackColor];
                lblNote.numberOfLines = 0;
                lblNote.font = font;
                
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.width * 1.6 - 40, self.view.frame.size.width - 20, 30)];
                [closeButton setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"bCup-stadium-close-button", @"Close")] forState:UIControlStateNormal];
                [closeButton addTarget:self  action:@selector(closeStadiumDetails:) forControlEvents:UIControlEventTouchDown];
                closeButton.layer.cornerRadius = 7.0f;
                closeButton.titleLabel.font = [UIFont fontWithName:@"VNF-FUTURA" size:15.f];
                closeButton.backgroundColor = [UIColor colorWithRed:0.0 green:76.0/255.0 blue:153.0/255.0 alpha:0.8];
                
                [cell.contentView addSubview:headerBackground];

                [cell.contentView addSubview:lblStadiumName];
                [cell.contentView addSubview:lblStadiumCity];
                [cell.contentView addSubview:lblCapacity];
                [cell.contentView addSubview:introsButtonText];
                [cell.contentView addSubview:introsButton];
                [cell.contentView addSubview:lblNote];
                [cell.contentView addSubview:closeButton];
                /*
                 "bCup-stadium-intro-txt" = "sGioiThieu_en";
                 "bCup-stadium-note-txt" = "sGhiChu_en";
                 "bCup-stadium-capacity-txt" = "sSucChua_en";
                 bCup-stadium-close-button
                 NSLocalizedString(@"bCup-group-round-txt", @"Group")
                 */
//                cell.contentView.alpha = 0.0f;
//                double delayInSeconds = 0.3f;
//                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                    [UIView animateWithDuration:0.2 animations:^{
//                        cell.contentView.alpha = 1.0f;
//                    }];
//                });
            }
        }
    }
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
    [self.navigationController pushViewController:exp animated:YES];
    
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
    //indexPath.section == 1 &&
    if (!self.bGiaiCup) {
        self.tableView.allowsSelection = YES;
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
    else {
        
        if (self.pagesContainer.selectedIndex == 0) {
            self.tableView.allowsSelection = YES;
            [self.pagesContainer setSelectedIndex:1 animated:YES];
            //set data for matchGroup
            [matchGroup removeAllObjects];
            [listMatchModelByGroup removeAllObjects];
            groupHolderBackground.alpha = 0.0f;
            BxhTeamModel *model = [[self.cupBxhDict objectForKey:[self.cupBxhKeyList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            for (int i = 0; i < [allMatchList count]; i ++) {
                if (model.iID_MaDoi == [[[allMatchList objectAtIndex:i] objectForKey:@"iID_MaDoiNha"] integerValue] || model.iID_MaDoi == [[[allMatchList objectAtIndex:i] objectForKey:@"iID_MaDoiKhach"] integerValue]) {
                    [matchGroup addObject:[allMatchList objectAtIndex:i]];
                    [listMatchModelByGroup addObject:[self.listMatchModel objectAtIndex:i]];
                }
            }
            [self setupForPageContainerTwo];
            [self.tableView reloadData];
        }
        else if (self.pagesContainer.selectedIndex == 1) {
            self.tableView.allowsSelection = YES;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            LivescoreModel* model = [listMatchModelByGroup objectAtIndex:indexPath.section];
            
            DetailMatchController *detail = [[DetailMatchController alloc] initWithNibName:@"DetailMatchController" bundle:nil];
            detail.iID_MaTran = model.iID_MaTran;
            detail.matchModel = model;
            [detail fetchMatchDetailById];
            
            [self.navigationController pushViewController:detail animated:YES];
        }
        else if (self.pagesContainer.selectedIndex == 2) {
            self.tableView.allowsSelection = YES;
            stadiumDetails = [stadiumList objectAtIndex:indexPath.row];
            if (!isShowStadiumInfo) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                isShowStadiumInfo = YES;
                scrollBackPosition = indexPath.row;
                double delayInSeconds = 0.3f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self.tableView setContentOffset:CGPointZero animated:NO];
                    [self.tableView reloadData];
                });
                
            }
            
        }
    }
     
}
-(void) closeStadiumDetails:(UIButton*)sender {
    if (isShowStadiumInfo) {
        isShowStadiumInfo = NO;
        double delayInSeconds = 0.03f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:scrollBackPosition inSection:0]
                                  atScrollPosition:UITableViewScrollPositionMiddle
                                          animated:YES];
            [self.tableView reloadData];
        });
    }
}
-(void) stadiumMapping : (UIButton *)sender {
    for (int i = 0; i < [stadiumList count]; i++) {
        if ([[[matchGroup objectAtIndex:sender.tag] valueForKey:@"SanVanDong"] isEqualToString:[[stadiumList objectAtIndex:i] valueForKey:@"sTenSVD"]]) {
            stadiumDetails = [stadiumList objectAtIndex:i];
            [self.pagesContainer setSelectedIndex:2 animated:YES];
            [self.tableView reloadData];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            isShowStadiumInfo = YES;
            scrollBackPosition = 0;
            double delayInSeconds = 0.3f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.tableView setContentOffset:CGPointZero animated:NO];
                [self.tableView reloadData];
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.tableView.frame = tableFrame;
                    self.fixtureScrollView.alpha = 0.0f;
                    self.groupScrollView.alpha = 0.0f;
                }];
                self.tableTopCons.constant = 0;
                [self.view updateConstraints];
            });
        }
    }
    
}
-(void) createIntrosView {
    introsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 0)];
    [self.view addSubview:introsView];
    introsWebview = [[UIWebView alloc] init];
    introsWebview.frame = CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height - 50);
    
    [introsView addSubview:introsWebview];
    
    closeIntros = [[UIButton alloc]init];
    
    [closeIntros addTarget:self  action:@selector(closeIntrosView) forControlEvents:UIControlEventTouchDown];
    
    closeIntros.frame = CGRectMake( 10, 10, self.view.frame.size.width - 20, 30);
    [closeIntros setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"bCup-stadium-close-button", @"Close")] forState:UIControlStateNormal];
    closeIntros.layer.cornerRadius = 7.0f;
    closeIntros.titleLabel.font = [UIFont fontWithName:@"VNF-FUTURA" size:15.f];
    closeIntros.backgroundColor = [UIColor colorWithRed:0.0 green:76.0/255.0 blue:153.0/255.0 alpha:0.8];
    
//    UIImageView *closeIntrosImage = [[UIImageView alloc] initWithFrame:closeIntros.frame];
//    closeIntrosImage.image = [UIImage imageNamed:@"close-down.png"];
//    [introsView addSubview:closeIntrosImage];
    
    [introsView addSubview:closeIntros];
    introsView.backgroundColor = [UIColor whiteColor];
}
-(void) callIntrosView {
    
    [UIView animateWithDuration:0.5 animations:^{
        introsView.frame = self.tableView.frame;
    }];
    NSString *htmlString = [stadiumDetails valueForKey:[NSString stringWithFormat:@"%@", NSLocalizedString(@"bCup-stadium-intro-txt", @"sGioithieu")]];
    NSString *cssString = [NSString stringWithFormat:@"<style type='text/css'>img {width: %fpx; height: auto;}</style>", self.view.frame.size.width - 15];
    htmlString = [NSString stringWithFormat:@"%@%@",cssString,htmlString];
    [introsWebview loadHTMLString:htmlString baseURL:nil];
}

-(void) closeIntrosView {
    [UIView animateWithDuration:0.5 animations:^{
        introsView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 0);
    }];
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    NSLog(@"Touch here : %f -- %f -- %ld", tapLocation.x, tapLocation.y, indexPath.row);
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




-(void) fetchListLeageLiveByCountry:(NSString*)iID_MaGiai {
    
    
    NSInteger offset = [[NSTimeZone defaultTimeZone] secondsFromGMTForDate: [NSDate date]];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT: offset];

    NSString* timeZoneName = [timeZone name];
    timeZoneName = [timeZoneName stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
    


    int timeZoneNameInt = [timeZoneName intValue];

    int hh = (abs(timeZoneNameInt) / 100) * (timeZoneNameInt/timeZoneNameInt);
    int mm = (abs(timeZoneNameInt) % 100) * (timeZoneNameInt/timeZoneNameInt);

    
    
    int dateInterval = (int)(self.selectedDateIndex - 2);
    long currentTime = [[XSUtils getDateByGivenDateInterval:[NSDate date] dateInterval:dateInterval] timeIntervalSince1970];
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iID_MaQuocGia", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_GetLichThiDau_TheoNgay_SoapMessage:iID_MaGiai datetimelocal:[NSString stringWithFormat:@"%lu", currentTime] HH:[NSString stringWithFormat:@"%d", hh] MM:[NSString stringWithFormat:@"%d", mm]] soapAction:[PresetSOAPMessage get_wsFootBall_GetLichThiDau_TheoNgay_SoapAction]];
        
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
        
        
        if ([xmlData rangeOfString:@"<wsFootBall_VongDauResult>"].location != NSNotFound) {
            // user info
            [self handle_wsFootBall_VongDauResult:xmlData];
            return;
        } else if ([xmlData rangeOfString:@"<wsFootBall_LiveScore_EuroResult>"].location != NSNotFound) {
            // user info
            [self handle_wsFootBall_GetLichThiDau_TheoBangResult:xmlData];
            
            return;
            
        }else if ([xmlData rangeOfString:@"<wsFootBall_BangXepHangResult>"].location != NSNotFound) {
            // user info
            [self handle_wsFootBall_BangXepHangResult:xmlData];
            return;
            
        }else if ([xmlData rangeOfString:@"<wsFootBall_SVDResult>"].location != NSNotFound) {
            // user info
            [self handle_wsFootBall_SVD:xmlData];
            return;
            
        }
        
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_GetLichThiDau_TheoNgayResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_GetLichThiDau_TheoNgayResult>"] objectAtIndex:0];
        
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
            long currentTime = [[NSDate date] timeIntervalSince1970];
            
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                LivescoreModel* model = [self createLiveScoreModelByDict:dict currentTime:currentTime];
                [self.datasource addObject:model];
                
            }
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.loadingImg.hidden = NO;
                self.loadingIndicator.hidden = YES;
                [self.loadingIndicator stopAnimating];
                
                
                [self.tableView reloadData];
                [self.lichDict setValue:[NSMutableArray arrayWithArray:self.datasource] forKey:[NSString stringWithFormat:@"%lu", self.selectedDateIndex]];
            });
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
}

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(id)sender {
    [self closeIntrosView];
    [self.tableView reloadData];
    
    if(self.bGiaiCup) {
        if (self.pagesContainer.selectedIndex == 0) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
        if (self.pagesContainer.selectedIndex == 1) {
            groupHolderBackground.alpha = 0.0f;
            matchGroup = [allMatchList mutableCopy];
            listMatchModelByGroup = [self.listMatchModel mutableCopy];
            [self.tableView reloadData];
            [self setupForPageContainerTwo];
        }
        else  {
            [UIView animateWithDuration:0.5 animations:^{
                self.tableView.frame = tableFrame;
                self.fixtureScrollView.alpha = 0.0f;
                self.groupScrollView.alpha = 0.0f;
            }];
            double delayInSeconds = 0.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.tableTopCons.constant = 0;
                [self.view updateConstraints];
            });
            
        }
        //Set table gesture
//        if (self.pagesContainer.selectedIndex == 2) {
//            [self.tableView addGestureRecognizer:tapTableView];
//        }
//        else {
//            [self.tableView removeGestureRecognizer:tapTableView];
//        }
        
        [self.datasource removeAllObjects];
        [self.tableView reloadData];
    }
    else {
        if (self.selectedDateIndex == index) {
            return;
        }
        self.selectedDateIndex = index;
        NSMutableArray *ret = [self.lichDict objectForKey:[NSString stringWithFormat:@"%lu", self.selectedDateIndex]];
        if(ret) {
            [self.datasource removeAllObjects];
            [self.datasource addObjectsFromArray:ret];
            [self.tableView reloadData];
        } else {
            [self onReloadClick:nil];
        }
    }
}
-(void) setupForPageContainerTwo {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, tableFrame.origin.y + self.fixtureScrollView.frame.size.height + self.groupScrollView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.fixtureScrollView.alpha = 1.0f;
        self.groupScrollView.alpha = 1.0f;
    }];
    double delayInSeconds = 0.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.tableTopCons.constant = self.fixtureScrollView.frame.size.height + self.groupScrollView.frame.size.height;
        [self.view updateConstraints];
    });
}

-(void)fetch_wsFootBall_VongDau {
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_VongDau_SoapMessage:self.iID_MaGiai] soapAction:[PresetSOAPMessage get_wsFootBall_VongDau_SoapAction]];
    });

}


-(void)handle_wsFootBall_GetLichThiDau_TheoBangResult:(NSString*)xmlData {
    
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_LiveScore_EuroResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_LiveScore_EuroResult>"] objectAtIndex:0];
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        [allMatchList addObjectsFromArray:bdDict];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            //[self.datasource removeAllObjects]; // remove all objects
            long currentTime = [[NSDate date] timeIntervalSince1970];
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                LivescoreModel* model = [self createLiveScoreModelByDict:dict currentTime:currentTime];
                [self.listMatchModel addObject:model];
                
            }
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.loadingImg.hidden = NO;
                self.loadingIndicator.hidden = YES;
                [self.loadingIndicator stopAnimating];
                
                if (self.pagesContainer.selectedIndex == 0) {
                    [self.groupDict setValue:[NSMutableArray arrayWithArray:self.datasource] forKey:self.sBangActive];
                } else {
                    [self.lichDict setValue:[NSMutableArray arrayWithArray:self.datasource] forKey:self.sBangActive_Cup];
                }
                [self.tableView reloadData];
            });
            
        }
        
    }
    @catch (NSException *exception) {
        
    }
}


-(void)handle_wsFootBall_VongDauResult:(NSString*)xmlData {
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_VongDauResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_VongDauResult>"] objectAtIndex:0];
        
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            int activeRound = 2;
            NSString* sBangActive = @"A";
            
            [self.cupList removeAllObjects];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                CupModel* model = [CupModel new];
                model.bCoLich = [[dict objectForKey:@"bCoLich"] boolValue];
                model.bVongActive = [[dict objectForKey:@"bVongActive"] boolValue];
                model.iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] intValue];
                model.iSTT = [(NSNumber*)[dict objectForKey:@"iSTT"] intValue];
                
                model.sDanhSachBang = [dict objectForKey:@"sDanhSachBang"];
                
                if (model.sDanhSachBang && model.sDanhSachBang.length > 1 && self.sDanhSachBang == nil) {
                    self.sDanhSachBang = model.sDanhSachBang;
                }
                
                
                model.sTen_en = [dict objectForKey:@"sTen_en"];
                model.sTen = [dict objectForKey:@"sTen"];
                
                if (model.iSTT == VONG_BANG) {
                    sBangActive = [dict objectForKey:@"sBangActive"];
                }
                
                
                if (model.bVongActive) {
                    activeRound = model.iSTT;
                }
                
                
                [self.cupList addObject:model];
                
            }
            
            
            self.sBangActive = sBangActive;
            
            [self.cupList sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"iSTT" ascending:YES]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pagesContainer.selectedIndex = (activeRound-1);
            });
            
            
            if (activeRound == VONG_BANG) {
                
            } else if (activeRound == VONG_1_16) {
                sBangActive = @"116";
            }else if (activeRound == VONG_1_8) {
                sBangActive = @"18";
            }else if (activeRound == VONG_1_4) {
                sBangActive = @"14";
            }else if (activeRound == VONG_1_2) {
                sBangActive = @"12";
            }
            
            self.sBangActive_Cup = sBangActive;
            
            //[self fetch_wsFootBall_GetLichThiDau_TheoBang:self.iID_MaGiai sBang:sBangActive];
        }
        
    }
    @catch (NSException *exception) {
        
    }
}

-(void)fetch_wsFootBall_GetLichThiDau_TheoBang:(int)MaGiai sBang:(NSString*)sBang {
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        //[self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_GetLichThiDau_TheoBang_SoapMessage:MaGiai sBang:sBang] soapAction:[PresetSOAPMessage get_wsFootBall_GetLichThiDau_TheoBang_SoapAction]];
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_LiveScore_Euro_SoapMessage:MaGiai sBang:sBang] soapAction:[PresetSOAPMessage get_wsFootBall_LiveScore_Euro_SoapAction]];
    });
}

-(void)fetch_wsFootBall_SVD {
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_SVD_SoapMessage:self.iID_MaGiai] soapAction:[PresetSOAPMessage get_wsFootBall_SVD_SoapAction]];
    });
}

-(LivescoreModel*)createLiveScoreModelByDict:(NSDictionary*) dict currentTime:(long)currentTime{
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
    
    
    [model adjustImageURLForReview];
    
    NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
    NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:matran];
    if(number != nil && [number intValue] == 1) {
        model.isFavourite = YES;
    } else {
        model.isFavourite = NO;
    }
    
    [LiveScoreViewController update_iCN_Phut_By_LivescoreModel:model c0:currentTime]; // update iCN_Phut by local time
    
    return model;
}

-(void) fetch_wsFootBall_BangXepHang
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getBxhSoapMessage:[NSString stringWithFormat:@"%ld", self.iID_MaGiai]] soapAction:[PresetSOAPMessage getBxhSoapAction]];
    });
    
}

-(void)handle_wsFootBall_SVD: (NSString*)xmlData {
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_SVDResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_SVDResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        [stadiumList addObjectsFromArray:bdDict];
        NSLog(@"San Van dong :%@", [stadiumList objectAtIndex:0]);
        
        for (int i = 0; i < [bdDict count]; i++) {
            [reloadPosition addObject:@"YES"];
        }
    }
    @catch(NSException *ex) {
        
        
    }

}
-(void)handle_wsFootBall_BangXepHangResult:(NSString*)xmlData {
    
    @try {
        
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
            
           
            [self.cupBxhKeyList removeAllObjects];
            [self.cupBxhDict removeAllObjects];
            
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
                model.sLogo = [dict objectForKey:@"sLogo"];
                model.iID_MaDoi = [[dict objectForKey:@"iID_MaDoi"] integerValue];
                model.sTieuDeBXH = [dict objectForKey:@"sTieuDeBXH"];
                model.iChiSoBXH = [(NSNumber*)[dict objectForKey:@"iChiSoBXH"] intValue];
                
                
                if([model.sTieuDeBXH isEqualToString:@""]) {
                    // ko phai dau cup
                    
                    
                } else {
                    // dau cup
                    NSString* cupKey = [NSString stringWithFormat:@"%c", 'A' + model.iChiSoBXH];
                    NSMutableArray* list = [self.cupBxhDict valueForKey:cupKey];
                    if(list == nil) {
                        list = [NSMutableArray new];
                        [self.cupBxhDict setObject:list forKey:cupKey];
                        [self.cupBxhKeyList addObject:cupKey];
                    }
                    [list addObject:model];
                    
                }
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.pagesContainer.selectedIndex == 0) {
//                    [self.tableView reloadData];
                }
            });
            
        }
    }@catch(NSException *ex) {
        

    }
}

#pragma  Admob
- (void)adViewDidReceiveAd:(GADBannerView *)view {

    self.tableView.tableHeaderView = view;
    
}



@end
