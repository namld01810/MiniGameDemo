//
//  LiveScoreViewController.h
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LiveScoreTableViewCell;
@class LivescoreModel;

@interface LiveScoreViewController : UIViewController

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property IBOutlet UISearchBar *livescoreSearchBar;

-(void) fetchLivescoreList;

-(void) retryFetchLivescoreList;


@property(nonatomic) BOOL isLoadingData;

+(void)updateLiveScoreTableViewCell:(LiveScoreTableViewCell*)cell model:(LivescoreModel*)model;
+(void)update_iCN_Phut_By_LivescoreModel:(LivescoreModel*)model c0:(long)c0;


@end
