//
//  VdiskReaderViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-12.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VdiskSDK.h"

@interface VdiskReaderViewController : UIViewController <VdiskRestClientDelegate, UIWebViewDelegate> {
    
    VdiskRestClient *_vdiskRestClient;
    BOOL _isExecuting;
}

@property (nonatomic, retain) VdiskMetadata *metadata;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@end
