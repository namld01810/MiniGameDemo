//
//  LeagueViewController.h
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeagueViewController : UIViewController


@property(nonatomic, strong) NSMutableData *webData;
@property(nonatomic, strong) NSMutableString *soapResults;

@property (weak, nonatomic) IBOutlet UIView *headerLeageView;
@property IBOutlet UISearchBar *leagueSearchBar;

@end
