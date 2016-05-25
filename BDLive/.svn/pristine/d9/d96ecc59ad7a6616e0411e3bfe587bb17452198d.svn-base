//
//  GroupHeader.h
//  BDLive
//
//  Created by Khanh Le on 9/3/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GroupHeaderDelegate <NSObject>

@optional
-(void)onGroupSelected:(int)selectedIndex title:(NSString*)title groupHeader:(id)groupHeader;

@end

@interface GroupHeader : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (strong, nonatomic) NSArray *itemViews;

@property (strong, nonatomic) NSArray *labelViews;

@property (strong, nonatomic) id<GroupHeaderDelegate> delegate;



-(void) createGroupLabels;

-(void) setSelectedLabel:(NSString*)grLabel;


@end


@interface GroupHeaderTapGestureRecognizer : UITapGestureRecognizer
@property(nonatomic) int selectedIndex;
@property(nonatomic, strong) NSString* selectedTitle;
@end
