//
//  TaskViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-5-17.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Reachability.h>

#import "VdiskSDK.h"

#import "Baidu.h"
#import "BaiduDelegate.h"

@interface TaskViewController : UIViewController

@property (nonatomic, retain) Baidu *bdConnect;
@property (nonatomic, retain) UIButton *taskButton3G;
@property (nonatomic, retain) UIButton *taskButtonWifi;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) NSString *numTaskToDo;
@property (nonatomic, retain) Reachability *internetReachable;
@property (nonatomic, retain) UILabel * networkLabel;

- (void)onBackButton:(id)sender;
- (void)onTask3G:(id)sender;
- (void)onTaskWifi:(id)sender;

+ (BOOL)IsEnableWIFI;
+ (BOOL)IsEnable3G;

@end
