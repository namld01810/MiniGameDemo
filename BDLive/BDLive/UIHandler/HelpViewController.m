//
//  HelpViewController.m
//  BDLive
//
//  Created by Khanh Le on 4/9/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "HelpViewController.h"
#import "xs_common_inc.h"

@interface HelpViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *helpImgView;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismissHelpViewController:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
   /* if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        self.helpImgView.image = [UIImage imageNamed:@"ic_help_fake.png"];
    } else {
        self.helpImgView.image = [XSUtils imageBaseOnResolution:@"splash_bg" ext:@"png"];
    }*/
    
    
    NSArray* langs = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if(langs && langs.count > 0) {
        if([[langs objectAtIndex:0] isEqualToString:@"vi"]) {
            self.helpImgView.image = [XSUtils imageBaseOnResolution:@"helpvi" ext:@"png"];
        } else {
            self.helpImgView.image = [XSUtils imageBaseOnResolution:@"helpen" ext:@"png"];
        }
        
    } else {
        self.helpImgView.image = [XSUtils imageBaseOnResolution:@"helpvi" ext:@"png"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)onDismissHelpViewController:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
