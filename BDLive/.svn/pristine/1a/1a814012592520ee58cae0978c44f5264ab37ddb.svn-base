//
//  GameTableViewCell.h
//  BDLive
//
//  Created by Khanh Le on 12/24/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameSlider.h"
#import "BDButton.h"
#import "../Utils/GameLabelLeft.h"
#import "../Utils/GameLabelRight.h"
#import "../Utils/GameLabelX.h"



@interface BetGameButton : UIButton

@property(nonatomic, weak) id cell;

@property(nonatomic) NSUInteger bet_type;

@property(nonatomic) NSUInteger picked;

@end


@interface GameTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *hostTeam;

@property (weak, nonatomic) IBOutlet UILabel *hostNS;

@property (weak, nonatomic) IBOutlet UILabel *hostDD;

@property (weak, nonatomic) IBOutlet UILabel *oppositeTeam;

@property (weak, nonatomic) IBOutlet UILabel *oppositeNS;


@property (weak, nonatomic) IBOutlet UILabel *oppositeDD;

@property (weak, nonatomic) IBOutlet UILabel *finalPredict;

@property (weak, nonatomic) IBOutlet UILabel *tyleCuoc;


@property (weak, nonatomic) IBOutlet GameSlider *hostSlider;

@property (weak, nonatomic) IBOutlet GameSlider *oppositeSlider;


@property (weak, nonatomic) IBOutlet UIButton *htButton;


@property (weak, nonatomic) IBOutlet BDButton *compBtn;


@property (weak, nonatomic) IBOutlet BDButton *pdoBtn;

@property (weak, nonatomic) IBOutlet BDButton *expertBtn;


@property (nonatomic) float hostDDVal;
@property (nonatomic) float oppositeDDVal;

@property (nonatomic) int iTrangThai;

@property (weak, nonatomic) IBOutlet UILabel *originalKeo;


-(void)setNSBorder:(UIColor*)bColor;



//
@property (weak, nonatomic) IBOutlet GameLabelLeft *g_NSLabel;

@property (weak, nonatomic) IBOutlet GameLabelLeft *g_NSLabel2;

@property (weak, nonatomic) IBOutlet UILabel *g_DD_1x2_Nha;

@property (weak, nonatomic) IBOutlet UILabel *g_DD_uo_Nha;

@property (weak, nonatomic) IBOutlet UILabel *g_DD_1x2_Khach;

@property (weak, nonatomic) IBOutlet UILabel *g_DD_uo_Khach;


@property (weak, nonatomic) IBOutlet UILabel *g_xLabel;

@property (weak, nonatomic) IBOutlet UILabel *g_tyleTaiXiu;

@property (weak, nonatomic) IBOutlet UILabel *g_tyleX;


@property (weak, nonatomic) IBOutlet BetGameButton *g_asiaBtn_Nha;

@property (weak, nonatomic) IBOutlet BetGameButton *g_1x2Btn_Nha;


@property (weak, nonatomic) IBOutlet BetGameButton *g_underBtn;


@property (weak, nonatomic) IBOutlet BetGameButton *g_overBtn;

@property (weak, nonatomic) IBOutlet BetGameButton *g_1x2Btn_Khach;

@property (weak, nonatomic) IBOutlet BetGameButton *g_asiaBtn_Khach;

@property (weak, nonatomic) IBOutlet BetGameButton *g_xButton;

@property (weak, nonatomic) IBOutlet GameLabelRight *g_underTyle;

@property (weak, nonatomic) IBOutlet GameLabelRight *g_overTyle;

@property (weak, nonatomic) IBOutlet GameLabelRight *g_1x2Tyle_1;

@property (weak, nonatomic) IBOutlet GameLabelX *g_1x2Tyle_x;

@property (weak, nonatomic) IBOutlet GameLabelRight *g_1x2Tyle_2;


@property (weak, nonatomic) IBOutlet GameLabelRight *g_asiaTyle_Nha;

@property (weak, nonatomic) IBOutlet GameLabelRight *g_asiaTyleKhach;


// label border
@property (weak, nonatomic) IBOutlet UILabel *asialabelBorder;

@property (weak, nonatomic) IBOutlet UILabel *txlabelBorder;


@end
