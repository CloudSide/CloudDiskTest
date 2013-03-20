//
//  BaiduAuthorizeViewController.h
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//
#import "BaiduBaseNavigationViewController.h"
#import "Baidu.h"

/*
 * 授权窗口的代理
 */
@protocol BaiduAuthorizeViewDelegate <NSObject>
/*
 * 取消授权的代理方法
 */
-(void)userDidCancel;
/*
 * 成功授权的代理方法
 */
-(void)userDidFinishSuccess;
/*
 * 授权发生错误的代理方法
 */
-(void)userDidFailWithError:(NSError *)error;

@end

/*
 * 授权窗口的视图控制器
 */
@interface BaiduAuthorizeViewController : BaiduBaseNavigationViewController<UIWebViewDelegate>{
    
    UIButton *_closeButton;
    UIView *_panelView;
}
/*
 * 授权窗口的代理
 */
@property(nonatomic, assign)id<BaiduAuthorizeViewDelegate> delegate;
/*
 * 权限列表
 */
@property(nonatomic, copy)NSString *scope;

@end