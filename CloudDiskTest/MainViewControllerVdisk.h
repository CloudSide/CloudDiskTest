//
//  MainViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "VdiskSDK.h"
#import "VdiskReaderViewController.h"

#import "MBProgressHUD.h"

@interface MainViewControllerVdisk : UITableViewController <VdiskRestClientDelegate, VdiskSessionDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate> {
    
    VdiskRestClient *_vdiskRestClient;
    VdiskMetadata *_metadata;
}

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, retain) NSString *currentPath;

@end
