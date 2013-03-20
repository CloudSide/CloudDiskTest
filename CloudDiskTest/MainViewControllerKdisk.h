//
//  MainViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <KuaiPanOpenAPI/KuaiPanOpenAPI.h>

#import "MBProgressHUD.h"

#import "KPAuthViewController.h"
#import "KdiskReaderViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "VdiskSDK.h"


#define kKPAppKey                       @"xcInFxiv9tnMmS5a"
#define kKPAppSecret                    @"D7JvQn0wTR5rP9D9"

#ifndef kKPAppKey
#error
#endif

#ifndef kKPAppSecret
#error
#endif


@interface MainViewControllerKdisk : UITableViewController <KPOperationDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    KPGetDirectoryOperation             *_getDirectoryOp;    // 获取文件（夹）信息操作
    KPUploadFileOperation               *_uploadFileOp;      // 上传文件
    KPGetUserInfoOperation              *_getUserInfoOp;     // 获取用户信息操作
    CLog *_clog;
}

@property (nonatomic, retain) KPUserInfo *userInfo;
@property (nonatomic, retain) KPAuthViewController *authController;
@property (nonatomic, retain) KPConsumer *consumer;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) KPDirectoryInfo *directoryInfo;

@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) NSString *currentPath;
@property (nonatomic, retain) NSString *deletePath;

@end
