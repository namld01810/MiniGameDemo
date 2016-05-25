//
//  GroupScrollView.m
//  BDLive
//
//  Created by Khanh Le on 9/3/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "GroupScrollView.h"

#define MIN_ITEM_WIDTH 60.f


@interface GroupScrollView ()



@end



@implementation GroupScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = [UIColor blackColor];
        
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame itemTitles:(NSArray*)itemTitles {
    self = [self initWithFrame:frame];
    
    if (self) {
        self.itemViews = [NSArray arrayWithArray:itemTitles];
        
        [self createGroupLabels];
    }
    
    return self;
}


-(void) createGroupLabels {
    CGFloat h = CGRectGetHeight(self.frame);
    CGFloat w = MIN_ITEM_WIDTH;
    
    CGFloat lengthW = self.itemViews.count * MIN_ITEM_WIDTH;
    
    if (lengthW < self.frame.size.width) {
        w = self.frame.size.width / self.itemViews.count;
    }
    
    
    NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:self.itemViews.count];
    
    
    for (int i=0; i < self.itemViews.count; i++) {
        UILabel* gr = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        gr.backgroundColor = [UIColor blackColor];
        gr.text = [self.itemViews objectAtIndex:i];
        gr.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:gr];
        
        [mutableItemViews addObject:gr];
        
        
    }
    
    self.labelViews = [NSArray arrayWithArray:mutableItemViews];
    
    [self layoutItemViews];
}

- (void)layoutItemViews
{
    
    CGFloat x = 0.f;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {

        UILabel *gr = self.labelViews[i];
        gr.frame = CGRectMake(x, 0, gr.frame.size.width, gr.frame.size.height);
        
        x += gr.frame.size.width;
        
    }
    
    
    
    
//    self.contentSize = CGSizeMake(x, CGRectGetHeight(self.frame));
//    CGRect frame = self.frame;
//    if (CGRectGetWidth(self.frame) > x) {
//        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
//        frame.size.width = x;
//    } else {
//        frame.origin.x = 0.;
//        frame.size.width = CGRectGetWidth(self.frame);
//    }
//    self.frame = frame;
}

@end
