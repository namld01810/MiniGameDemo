//
//  SampleViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "SampleViewController.h"

@interface SampleViewController ()

@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGesture;

@end

@implementation SampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gestureFired:)];
    [self.view addGestureRecognizer:self.swipeGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - gesture method

-(void)gestureFired:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
