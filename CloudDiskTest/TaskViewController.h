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
#import "BaiduSDKHeader.h"
#import "BaiduDelegate.h"

#import "MBProgressHUD.h"

#define numberOfTask        3
#define numberOfRound       2

@interface TaskViewController : UIViewController <VdiskRestClientDelegate, VdiskSessionDelegate, BaiduAPIRequestDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate, UIAlertViewDelegate> {
    
    VdiskRestClient *_vdiskRestClient;
    int _taskIndex;
    int _taskFlag;
    CLog *_clogUpload;
    CLog *_clogDownload;
    long long _uploadSize;
    
    int _bDiskUpDownFlag;
    int _indexRound;
    
    BOOL _task3GFinished;
    BOOL _taskWifiFinished;
    
    int _processTotal;
    int _numTaskFinished;
    
    BOOL _isRunning;
    BOOL _alertByNetChange;
}

@property (nonatomic, retain) Baidu *bdConnect;
@property (nonatomic, retain) UIButton *taskButton3G;
@property (nonatomic, retain) UIButton *taskButtonWifi;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) NSString *numTaskToDo;
@property (nonatomic, retain) Reachability *internetReachable;
@property (nonatomic, retain) UILabel *networkLabel;

@property (nonatomic, retain) NSString *deletePath;
@property (nonatomic, retain) ASIFormDataRequest *request;

@property (nonatomic, retain) UILabel *taskAProcessLabel;
@property (nonatomic, retain) UILabel *taskBProcessLabel;
@property (nonatomic, retain) UILabel *taskHint;
@property (nonatomic, retain) UILabel *labelHint;

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *phoneNum;

- (void)onBackButton:(id)sender;
- (void)onTask3G:(id)sender;
- (void)onTaskWifi:(id)sender;
- (void)onCancelTask:(id)sender;

- (void)upLoadDataVdisk:(int)index;
- (void)upLoadDataBdisk:(int)index;
- (void)downLoadDataVdisk:(int)index;
- (void)downLoadDataBdisk:(int)index;

- (void)taskFinished;

+ (BOOL)IsEnableWIFI;
+ (BOOL)IsEnable3G;

- (void)getData;

@end
