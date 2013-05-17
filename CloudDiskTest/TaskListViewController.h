//
//  TaskListViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-5-16.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaiduSDKHeader.h"

@interface TaskListViewController : UIViewController

@property (nonatomic, retain) Baidu *bdConnect;
@property (nonatomic, retain) UIButton *startButton;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) NSString *numTaskToDo;

- (void)onStartButton:(id)sender;
- (void)onBackButton:(id)sender;

@end
