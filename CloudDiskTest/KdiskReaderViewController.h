//
//  KdiskReaderViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-12.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <KuaiPanOpenAPI/KuaiPanOpenAPI.h>
#import "VdiskSDK.h"

@interface KdiskReaderViewController : UIViewController <KPOperationDelegate, UIWebViewDelegate> {
    
    KPDownloadFileOperation             *_downloadFileOp;    // 下载文件
    BOOL _isExecuting;
    CLog *_clog;
}

@property (nonatomic, retain) KPFileInfo *metadata;
@property (nonatomic, retain) KPUserInfo *userInfo;
@property (nonatomic, retain) NSString *root;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@end
