//
//  TableViewController.m
//  BDLive
//
//  Created by Khanh Le on 8/3/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "TableViewController.h"

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
#import "DAPagesContainer.h"
#import "TableViewController.h"


static NSString* nib_LivescoreCell = @"nib_LivescoreCell";

@interface TableViewController () <SOAPHandlerDelegate, UITableViewDataSource, UITableViewDelegate>


@property(nonatomic, strong) SOAPHandler *soapHandler;



@end

@implementation TableViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.datasource = [NSMutableArray new];
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHomeSiteClick:)];
    [XSUtils setTableFooter:self.tableView tap:tapGesture];
    
    
    // setup nib files
    UINib *livescoreCell = [UINib nibWithNibName:@"LiveScoreTableViewCell" bundle:nil];
    [self.tableView registerNib:livescoreCell forCellReuseIdentifier:nib_LivescoreCell];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveScoreHeaderSection" bundle:nil] forHeaderFooterViewReuseIdentifier:@"LiveScoreHeaderSection"];
    // end setup nib files
}


-(void)onHomeSiteClick:(id)sender {
    NSString *livescoreLink = @"http://livescore007.com/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:livescoreLink]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView




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
    
    return nil;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}



@end
