//
//  ChatViewController.h
//  BDLive
//
//  Created by Khanh Le on 3/17/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../../JSMessagesViewController/JSMessagesViewController.h"


@interface ChatViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource>

@end
