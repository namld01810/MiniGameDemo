//
//  GroupHeader.m
//  BDLive
//
//  Created by Khanh Le on 9/3/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "GroupHeader.h"

#define MIN_ITEM_WIDTH 60.f

@implementation GroupHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




-(void) createGroupLabels {
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollEnabled = YES;

    
    CGFloat h = CGRectGetHeight(self.frame);
    CGFloat w = MIN_ITEM_WIDTH;
    
    CGFloat lengthW = self.itemViews.count * MIN_ITEM_WIDTH;
    
    if (YES || lengthW < self.frame.size.width) {
        w = self.scrollView.frame.size.width / 8;
    }
    

    
    
    
    
    NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:self.itemViews.count];
    
    
    for (int i=0; i < self.itemViews.count; i++) {
        UILabel* gr = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];

        
        gr.textColor = [UIColor whiteColor];
        gr.text = [self.itemViews objectAtIndex:i];
        gr.textAlignment = NSTextAlignmentCenter;
        
        gr.userInteractionEnabled = YES;
        GroupHeaderTapGestureRecognizer* tap = [[GroupHeaderTapGestureRecognizer alloc] initWithTarget:self action:@selector(onButtonClicked:)];
        tap.numberOfTapsRequired = 1;
        tap.selectedIndex = i;
        tap.selectedTitle = [self.itemViews objectAtIndex:i];

        [gr addGestureRecognizer:tap];
        
        
        
        [self.scrollView addSubview:gr];
        
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
        gr.frame = CGRectMake(x, 5.f, gr.frame.size.width, gr.frame.size.height-5.f);
        
        x += gr.frame.size.width;
        
    }
    
    
    
    // For horizontal scrolling
    self.scrollView.contentSize = CGSizeMake(x+10.f, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    

    
}


-(UIView *)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        
        roundedView.layer.mask = maskLayer;
        return roundedView;
    } else {
        return view;
    }
    
}

-(void) setSelectedLabel:(NSString*)grLabel {
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        NSString* itemTitle = [self.itemViews objectAtIndex:i];
        UILabel *gr = self.labelViews[i];
        if ([itemTitle isEqualToString:grLabel]) {
            
            gr = (UILabel*)[self roundCornersOnView:gr onTopLeft:YES topRight:YES bottomLeft:NO bottomRight:NO radius:5.0f];
            gr.backgroundColor = [UIColor colorWithRed:(237/255.f) green:(237/255.f) blue:(237/255.f) alpha:1.0f];
            gr.textColor = [UIColor blackColor];
            
            if(i>=8) {
                self.scrollView.contentOffset = CGPointMake(self.center.x, 0.f);
            }
            
        } else {
//            gr = (UILabel*)[self roundCornersOnView:gr onTopLeft:YES topRight:YES bottomLeft:NO bottomRight:NO radius:0.0f];
            gr.backgroundColor = [UIColor colorWithRed:(24/255.f) green:(138/255.f) blue:(24/255.f) alpha:1.0f];
            gr.textColor = [UIColor whiteColor];
        }
    }
}

-(void)onButtonClicked:(GroupHeaderTapGestureRecognizer*)sender {
    if (self.delegate != nil) {
        [self.delegate onGroupSelected:sender.selectedIndex title:sender.selectedTitle groupHeader:self];
    }
}

@end


@implementation GroupHeaderTapGestureRecognizer

@end
