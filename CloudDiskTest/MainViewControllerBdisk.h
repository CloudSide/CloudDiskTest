//
//  MainViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaiduSDKHeader.h"
#import "BdiskDirectoryInfo.h"

#import "VdiskSDK.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"


@interface MainViewControllerBdisk : UITableViewController <BaiduAPIRequestDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate> {

    CLog *_clog;
}

@property (nonatomic, retain) Baidu *bdConnect;
@property (nonatomic, retain) NSString *path;

@property (nonatomic, retain) BdiskDirectoryInfo *bDiskDirectoryInfo;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, retain) NSString *currentPath;
@property (nonatomic, retain) NSString *deletePath;

@property (nonatomic, retain) ASIFormDataRequest *request;


@end
