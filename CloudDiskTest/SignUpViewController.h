//
//  SignUpViewController.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VdiskSDK.h"
#import "Baidu.h"
#import "BaiduDelegate.h"


@interface SignUpViewController : UIViewController <BaiduAPIRequestDelegate>

@property (nonatomic, retain) NSString *diskName;
@property (strong, nonatomic) UINavigationController *mainViewNavigationController;

@property (nonatomic, retain) Baidu *bdConnect;

@end
