//
//  LivescoreModel.h
//  BDLive
//
//  Created by Khanh Le on 12/11/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LivescoreModel : NSObject

@property(nonatomic, strong) NSDate* dThoiGianThiDau;
@property(nonatomic, strong) NSString* sThoiGian;
@property(nonatomic, strong) NSString* sTenDoiNha;
@property(nonatomic, strong) NSString* sTenDoiKhach;
@property(nonatomic, strong) NSString* sTenGiai;
@property(nonatomic, strong) NSString* sLogoQuocGia;
@property(nonatomic, strong) NSString* sLogoGiai;
@property(nonatomic) NSUInteger iID_MaGiai;
@property(nonatomic) int iTrangThai;

@property(nonatomic) NSUInteger SoSaoDatDoiNha;
@property(nonatomic) NSUInteger SoSaoDatDoiKhach;

@property(nonatomic) NSUInteger SaoDat1;
@property(nonatomic) NSUInteger SaoDat2;
@property(nonatomic) NSUInteger SaoDatX;
@property(nonatomic) NSUInteger SaoDatU;
@property(nonatomic) NSUInteger SaoDatO;


@property(nonatomic) BOOL isHighlightNha;
@property(nonatomic) BOOL isHighlightKhach;


@property(nonatomic) BOOL isHighlight_1x2_1;
@property(nonatomic) BOOL isHighlight_1x2_x;
@property(nonatomic) BOOL isHighlight_1x2_2;
@property(nonatomic) BOOL isHighlight_uo_u;
@property(nonatomic) BOOL isHighlight_uo_o;


@property(nonatomic, strong) NSString* sDoiNha_BXH;
@property(nonatomic, strong) NSString* sDoiKhach_BXH;





@property(nonatomic) long c0; // time hien tai cua event tren server
@property(nonatomic) long iC0; // ngay gio thi dau
@property(nonatomic) long iC1; // ngay gio thi dau
@property(nonatomic) long iC2; // ngay gio thi dau
@property(nonatomic) long iSoPhut1Hiep; // ngay gio thi dau


//iID_MaDoiKhach,iID_MaDoiNha



@property(nonatomic, strong) NSString* sTip;

////iID_MaDoiNha, iID_MaDoiKhach
@property(nonatomic) NSUInteger iID_MaQuocGia;
@property(nonatomic) NSUInteger iID_MaDoiNha;
@property(nonatomic) NSUInteger iID_MaDoiKhach;

@property(nonatomic) NSUInteger iCN_BanThang_DoiKhach_HT;
@property(nonatomic) NSUInteger iCN_BanThang_DoiNha_HT;
@property(nonatomic) NSUInteger iCN_BanThang_DoiNha_FT;
@property(nonatomic) NSUInteger iCN_BanThang_DoiKhach_FT;
@property(nonatomic) NSUInteger iID_MaTran;

@property(nonatomic) NSUInteger iCN_BanThang_DoiNha_ET;
@property(nonatomic) NSUInteger iCN_BanThang_DoiKhach_ET;

@property(nonatomic, strong) NSString* sLogoDoiNha;
@property(nonatomic, strong) NSString* sLogoDoiKhach;

@property(nonatomic, strong) NSString* sMaDoiNha;
@property(nonatomic, strong) NSString* sMaDoiKhach;

//sMaTran, sMaNhanDinh
@property(nonatomic, strong) NSString* sMaTran;
@property(nonatomic, strong) NSString* sMaNhanDinh;


@property(nonatomic) float saoDD;


@property(nonatomic) BOOL bNhanDinhChuyenGia;
@property(nonatomic) BOOL bMayTinhDuDoan;
@property(nonatomic) BOOL bGameDuDoan;

@property(nonatomic) BOOL isFavourite;


@property(nonatomic) NSUInteger iCN_Phut;

// pens
@property(nonatomic) NSUInteger iCN_BanThang_DoiNha_Pen;
@property(nonatomic) NSUInteger iCN_BanThang_DoiKhach_Pen;

@property(nonatomic) NSUInteger iPhutThem;


//iCN_PhatGoc_DoiNha,iCN_PhatGoc_DoiKhach,fPoss_DoiNha,fPoss_DoiKhach
@property(nonatomic) int iCN_PhatGoc_DoiNha;
@property(nonatomic) int iCN_PhatGoc_DoiKhach;
@property(nonatomic) float fPoss_DoiNha;
@property(nonatomic) float fPoss_DoiKhach;


@property(nonatomic, strong) NSString* sTyLe_ChapBong;
@property(nonatomic, strong) NSString* sTyLe_ChauAu;
@property(nonatomic, strong) NSString* sTyLe_TaiSuu;

@property(nonatomic, strong) NSString* sTyLe_ChauAu_Live;
@property(nonatomic, strong) NSString* sTyLe_TaiSuu_Live;


-(NSString*) get_sTyLe_ChapBong:(NSString*)sTyLe_ChapBong;
-(NSString*) get_dThoiGianThiDau:(NSDate*)dThoiGianThiDau;

@property(nonatomic) BOOL isHighlightedView;


@property(nonatomic) BOOL highlightedGame;



-(NSString*) get_sTyLe_ChapBong_ChauAu_Live:(NSString*)sTyLe_ChapBong;
-(NSString*) get_sTyLe_ChapBong_TaiSuu_Live:(NSString*)sTyLe_ChapBong;


-(void)adjustImageURLForReview;

//Trạng thái trận đấu: <=1:Chưa đá; 2,4: Đang đá; 3: HT; 5,8,9,15: FT; 6: Bù giờ; 7,14: Pens; 11: Hoãn;  12: CXĐ; 13: Dừng; 16: W.O

//sTenDoiNha,sTenDoiNha_188Bet,sTenDoiNha_7MSport
//sTenDoiKhach_188Bet, sTenDoiKhach_7MSport,sTenDoiKhach
//sTenGiai, sTenGiai_188Bet, sTenGiai_7MSport
//sLogoQuocGia

@end
