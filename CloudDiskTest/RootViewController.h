//
//  RootViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-1.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VdiskSDK.h"

#import "Baidu.h"
#import "BaiduDelegate.h"

#define nameVDiskBtn @"vDiskBtn"
#define nameBDiskBtn @"bDiskBtn"
#define nameKDiskBtn @"kDiskBtn"

#define kVdiskSDKDemoAppKey             @"1760281982"
#define kVdiskSDKDemoAppSecret          @"8f836595aff61dd26028c9a381109631"
#define kVdiskSDKDemoAppRedirectURI     @"http://vauth.appsina.com/callback.php"

#define kWeiboAppKey                    @"2938478327"
#define kWeiboAppSecret                 @"968d785bb0fd2188d2d132a8dd8ed990"
#define kWeiboAppRedirectURI            @"http://2.vauth.appsina.com/callback.php"

#define kBaiduApiKey                    @"tedA8CGptSClqfwy42B9RRHT"
#define kBaiduAppSecret                 @"guyz3Zs4uz4lDDbCDQNYEbS0gMvGxFcG"
#define kBaiduAppId                     @"315198"

#define tagBtnVdisk  1001
#define tagBtnBdisk  1002
#define tagBtnKdisk  1003


#ifndef kBaiduApiKey
#error
#endif

#ifndef kBaiduAppId
#error
#endif

#ifndef kVdiskSDKDemoAppKey
#error
#endif

#ifndef kVdiskSDKDemoAppRedirectURI
#error
#endif

#ifndef kVdiskSDKDemoAppSecret
#error
#endif

#ifndef kWeiboAppKey
#error
#endif

#ifndef kWeiboAppSecret
#error
#endif

#ifndef kWeiboAppRedirectURI
#error
#endif

#ifndef nameVDiskBtn
#error
#endif

#ifndef nameBDiskBtn
#error
#endif

#ifndef nameKDiskBtn
#error
#endif

@class VdiskSession;

@interface RootViewController : UIViewController <VdiskSessionDelegate, VdiskNetworkRequestDelegate, SinaWeiboDelegate, BaiduAuthorizeDelegate>

@property (nonatomic, retain) NSString *currentPressedButton;

@property (nonatomic, retain) UIButton *vDiskBtn;
@property (nonatomic, retain) UIButton *bDiskBtn;
@property (nonatomic, retain) UIButton *kDiskBtn;

@property (nonatomic, retain) Baidu *bdConnect;

- (void)createButton:(UIButton *)button withName:(NSString *)name atView:(UIView *)view;
- (void)goToSignUp:(id)sender;

@end
