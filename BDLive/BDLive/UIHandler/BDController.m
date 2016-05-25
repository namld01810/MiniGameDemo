//
//  BDController.m
//  BDLive
//
//  Created by Khanh Le on 12/10/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "BDController.h"

@interface BDController ()

@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGesture;

@end

@implementation BDController

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

-(void)gestureFired:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        
        if(self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}

@end
