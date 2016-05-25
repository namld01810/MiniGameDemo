//
//  CommentTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 5/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BDButton.h"

@interface CommentTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UITextView *commentTxtView;


@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *dispNameLabel;
@property (weak, nonatomic) IBOutlet BDButton *btnLike;

@property (weak, nonatomic) IBOutlet UILabel *likeLabel;

@property (weak, nonatomic) IBOutlet BDButton *btnDislike;

@property (weak, nonatomic) IBOutlet UILabel *dislikeLabel;



@end
