//
//  BdiskReaderViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-12.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VdiskSDK.h"

#import "BaiduSDKHeader.h"
#import "BdiskFileInfo.h"

@interface BdiskReaderViewController : UIViewController <UIWebViewDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate> {
    
    CGFloat _progress;
    BOOL _isExecuting;
    CLog *_clog;
}

@property (nonatomic, retain) Baidu *bdConnect;
@property (nonatomic, retain) BdiskFileInfo *metadata;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, retain) ASIHTTPRequest *request;

@end
