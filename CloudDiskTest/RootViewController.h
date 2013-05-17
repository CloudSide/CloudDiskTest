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


@class VdiskSession;

@interface RootViewController : UIViewController <VdiskSessionDelegate, VdiskNetworkRequestDelegate, SinaWeiboDelegate, BaiduAuthorizeDelegate, UITextFieldDelegate>

@property (nonatomic, retain) NSString *currentPressedButton;

@property (nonatomic, retain) UIButton *vDiskBtn;
@property (nonatomic, retain) UIButton *bDiskBtn;
@property (nonatomic, retain) UIButton *kDiskBtn;

@property (nonatomic, retain) UITextField *textFieldName;
@property (nonatomic, retain) UITextField *textFieldPhone;
@property (nonatomic, retain) UIButton *signUpButton;
@property (nonatomic, retain) UIButton *signOutButton;

@property (nonatomic, retain) Baidu *bdConnect;

@property (nonatomic, retain) NSString *numTaskToDo;

- (void)createButton:(UIButton *)button withName:(NSString *)name atView:(UIView *)view;

- (void)createTextFieldAtView:(UIView *)view;

- (void)goToSignUp:(id)sender;

- (void)onSignUpButton:(id)sender;
- (void)onSignOutButton:(id)sender;

- (NSString *)filePath:(NSString* )fileName;

@end
