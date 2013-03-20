//
//  BaiduAuthorizeManager.h
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Baidu.h"
#import "BaiduAuthorizeViewController.h"

/*
 * 负责授权管理的类
 */
@interface BaiduAuthorizeManager : NSObject <BaiduAuthorizeViewDelegate>

/*
 * 取得授权管理共享对象
 */
+ (BaiduAuthorizeManager*)shareAuthorizeManager;

/*
 * 销毁授权管理共享对象
 */
+ (void)destroyAuthorizeManager;

/*
 * 判断能否进行SSO
 */
- (BOOL)canProcessSSO;

/*
 * 页面授权方式进行授权
 */
- (void)authorizeToOpenWebPageWithScope:(NSString*)scope andDelegate:(id<BaiduAuthorizeDelegate>)delegate;

/*
 * SSO授权方式进行授权
 */
- (void)authorizeToProcessSSOWithScope:(NSString*)scope andDelegate:(id<BaiduAuthorizeDelegate>)delegate;

/*
 * SSO完成后，此方法进行对主客户端的回调进行处理
 */
- (BOOL)handleOpenURL:(NSURL *)url;

@end
