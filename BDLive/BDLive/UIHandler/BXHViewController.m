//
//  BXHViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/16/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "BXHViewController.h"
#import "RDVTabBarController.h"
#import "xs_common_inc.h"
#import "LeagueTableViewCell.h"
#import "SampleViewController.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../Models/CountryModel.h"
#import "../Models/AccInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LeagueDetailViewController.h"
#import "SettingsViewController.h"
#import "../AdNetwork/AdNetwork.h"

#define NIB_LEAGUE_CELL @"LeagueTableViewCell"


@interface BXHViewController ()<UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate, UIAlertViewDelegate, GADBannerViewDelegate>

@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) NSMutableArray *listCountry;

@property(nonatomic, strong) NSMutableArray *listCountry_Filter;

@property(atomic, strong) SDWebImageManager *manager;

@end

@implementation BXHViewController

@synthesize bxhSearchBar;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.listCountry = [NSMutableArray new];
        self.listCountry_Filter = [NSMutableArray new];
        _manager = [SDWebImageManager sharedManager];
        
    }
    return self;
    
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    
//    if(self) {
//        self.soapHandler = [[SOAPHandler alloc] init];
//        self.soapHandler.delegate = self;
//        self.listCountry = [NSMutableArray new];
//        
//    }
//    
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    UINib *leagueCell = [UINib nibWithNibName:@"LeagueTableViewCell" bundle:nil];
    [self.tableView registerNib:leagueCell forCellReuseIdentifier:NIB_LEAGUE_CELL];
    
    [self fetchCountryList];
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(searchBarKeyboardDidHide_BXH) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHomeSiteClick:)];
    [XSUtils setTableFooter:self.tableView tap:tapGesture];
    
    
    [[AdNetwork sharedInstance] createAdMobBannerView:self admobDelegate:self tableView:self.tableView];
    
    
    
    
}

-(void)onHomeSiteClick:(id)sender {
    NSString *livescoreLink = @"http://livescore007.com/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:livescoreLink]];
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


-(void) fetchCountryList
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (list.count > 0) {
            [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getListCountrySoapMessage:[list objectAtIndex:0]] soapAction:[PresetSOAPMessage getListCountrySoapAction]];
        }
        
        
    });
}

-(IBAction)onSettingsClick:(id)sender
{
    ZLog(@"[league] click on settings");
    SettingsViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    UIViewController *navController = [[UINavigationController alloc]
                                       initWithRootViewController:set];
    
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma tableview


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.listCountry_Filter.count;
    } else {
        return self.listCountry.count;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//    LeagueTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeagueTableViewCell" owner:nil options:nil] objectAtIndex:0];
    LeagueTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_LEAGUE_CELL];
    
    CountryModel *model = nil;
    
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        model = [self.listCountry_Filter objectAtIndex:indexPath.row];
    } else {
        model = [self.listCountry objectAtIndex:indexPath.row];
    }
    
    
    cell.model = model;
    
    cell.nameLabel.text = model.sTenQuocGia;
    
    [self.manager downloadWithURL:[NSURL URLWithString:model.sLogo]
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
             //                     ZLog(@"download img %@ completed", imgURL);
             
             [XSUtils adjustUIImageView:cell.flagImg image:image];
             [cell.flagImg setImage:image];
             
         }
     }];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LeagueTableViewCell *cell = (LeagueTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    LeagueDetailViewController* view = [[LeagueDetailViewController alloc] initWithNibName:@"LeagueDetailViewController" bundle:nil];
    
    
    
    NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"hdr-bxh.text", @"BẢNG XẾP HẠNG")];
    view.leagueTitle = localizeMsg;
    
    view.countryNameStr = cell.model.sTenQuocGia;
    view.countryFlagStr = cell.model.sLogo;
    view.isBxh = YES;
    [view fetchListLeageByCountry:[NSString stringWithFormat:@"%d", cell.model.iID_MaQuocGia]];
    
    [self.navigationController pushViewController:view animated:YES];
}


-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    });
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self fetchCountryList];
}

-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_QuocgiaResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_QuocgiaResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            
            [self.listCountry removeAllObjects];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                CountryModel *model = [[CountryModel alloc] init];
                model.sLogo = [dict objectForKey:@"sLogo"];
                model.sMaQuocGia_GoalServe = [dict objectForKey:@"sMaQuocGia_GoalServe"];
                model.iID_MaQuocGia = [[dict objectForKey:@"iID_MaQuocGia"] intValue];
                model.sMaQuocGia = [dict objectForKey:@"sMaQuocGia"];
                model.sTenQuocGia = [dict objectForKey:@"sTenQuocGia"];
                model.sMaQuocGia_en = [dict objectForKey:@"sMaQuocGia_en"];
                
                if([AccInfo sharedInstance].isReview) {
                    model.sLogo = [NSString stringWithFormat:@"%@-isreview", model.sLogo];
                }
                
                [self.listCountry addObject:model];
                
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.loadingIndicator stopAnimating];
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
    
    
}





-(void)hideSearchBarNow {
    [self.bxhSearchBar resignFirstResponder];
    
    
    
    self.bxhSearchBar.hidden = YES;
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFromBottom;
    animation.duration = 0.3;
    [self.bxhSearchBar becomeFirstResponder];
    [self.bxhSearchBar.layer addAnimation:animation forKey:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (YES && scrollView.contentOffset.y < -50 && [self.bxhSearchBar isHidden]) { // TOP
        //        NSLog(@"scrollViewDidScroll: %f", scrollView.contentOffset.y);
        self.bxhSearchBar.hidden = NO;
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFromTop;
        animation.duration = 0.7;
        [self.bxhSearchBar becomeFirstResponder];
        [self.bxhSearchBar.layer addAnimation:animation forKey:nil];
        
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //    NSLog(@"searchText: %@", searchText);
}
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//
//}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideSearchBarNow];
}

- (void)searchBarKeyboardDidHide_BXH
{
    if (self.bxhSearchBar.text == nil || [self.bxhSearchBar.text isEqualToString:@""]) {
        [self hideSearchBarNow];
    }
    
}



#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Update the filtered array based on the search text and scope.
    //    NSLog(@"filterContentForSearchText");
    
    // Remove all objects from the filtered search array
    [self.listCountry_Filter removeAllObjects];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bind) {
        
        CountryModel *model = obj;
        NSString* nomalizedStr = [searchText lowercaseString];
        
        NSString* nomalized_sTenQuocGia = [model.sTenQuocGia lowercaseString];
        
        
        if([nomalized_sTenQuocGia rangeOfString:nomalizedStr].location != NSNotFound) {
            return true;
        }
        
        
        
        return false;
        
        
        
        
        
    }];
    
    
    
    
    
    NSArray* tmpList = [self.listCountry filteredArrayUsingPredicate:predicate];
    

    [self.listCountry_Filter addObjectsFromArray:tmpList];
}


#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma  Admob
- (void)adViewDidReceiveAd:(GADBannerView *)view {

    self.tableView.tableHeaderView = view;
    
}
@end
