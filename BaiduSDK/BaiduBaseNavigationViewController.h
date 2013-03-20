//
//  BaiduBaseNavigationViewController.h
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * SDK中所有窗口的视图控制类的基类
 */
@interface BaiduBaseNavigationViewController : UIViewController {
}
/*
 * 当前设备的显示方向
 */
@property (nonatomic, assign) UIDeviceOrientation orientation;
/*
 * 显示窗口
 */
- (void)show;
/*
 * 关闭窗口
 */
- (void)close;
/*
 * 子类重载此方法，在显示方向改变时进行适配处理
 */
- (void)setSubViewOrientationChange;

@end
