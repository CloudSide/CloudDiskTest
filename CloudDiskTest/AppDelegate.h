//
//  AppDelegate.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-1.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
@public
    BOOL _applicationFromBackground;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (retain, nonatomic) id currentViewController;

@end
