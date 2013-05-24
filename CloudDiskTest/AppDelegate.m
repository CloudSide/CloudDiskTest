//
//  AppDelegate.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-1.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "AppDelegate.h"

#import "RootViewController.h"

#import "TaskViewController.h"
#import "TaskListViewController.h"

@implementation AppDelegate

@synthesize navigationController = _navigationController;

@synthesize currentViewController = _currentViewController;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_currentViewController release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    RootViewController *rootViewController = [[[RootViewController alloc] init] autorelease];
    
    //rootViewController.title = @"CloudDiskTest";
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
    self.window.rootViewController = self.navigationController;
    
//    [self.navigationController.navigationBar setHidden:YES];
    
    _applicationFromBackground = FALSE;
    
    // 通知
    [self scheduleAlarm];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES ];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"任务提醒"
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)scheduleAlarm {
    
    UIApplication *appTemp = [UIApplication sharedApplication];
    [appTemp cancelAllLocalNotifications];
    
    
    NSString *fileNameLoad = [self filePath:@"userInfo.archiver"];
    NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileNameLoad];
    NSString *numTaskToDo;
    
    if ([dataLoad length] > 0) {
        
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataLoad];
        numTaskToDo = [unArchiver decodeObjectForKey:@"userNumTaskToDo"];
        [unArchiver finishDecoding];
        [unArchiver release];
        
        if ([numTaskToDo intValue] == 0) {
            
            NSDate *date = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *dateComps;
            
            dateComps = [calendar components:(NSYearCalendarUnit   |
                                              NSMonthCalendarUnit  |
                                              NSDayCalendarUnit    |
                                              NSHourCalendarUnit   |
                                              NSMinuteCalendarUnit |
                                              NSSecondCalendarUnit |
                                              NSWeekdayCalendarUnit) fromDate:date];
            
            int totalDays = 0;
            if ([dateComps month] == 1  ||
                [dateComps month] == 3  ||
                [dateComps month] == 5  ||
                [dateComps month] == 7  ||
                [dateComps month] == 8  ||
                [dateComps month] == 10 ||
                [dateComps month] == 12 ) {
                
                totalDays = 31;
                
            } else if ([dateComps month] == 2) {
                
                if ([dateComps year]%4==0) {
                    totalDays = 29;
                } else {
                    totalDays = 28;
                }
                
            } else {
                totalDays = 30;
            }
            
            UILocalNotification *noti_2 = [[[UILocalNotification alloc] init] autorelease];
            UILocalNotification *noti_4 = [[[UILocalNotification alloc] init] autorelease];
            UILocalNotification *noti_6 = [[[UILocalNotification alloc] init] autorelease];
            
            if ([dateComps month] == 12) {
                [dateComps setYear:[dateComps year]+1];
                [dateComps setMonth:1];
            }else {
                [dateComps setYear:[dateComps year]];
                [dateComps setMonth:[dateComps month]+1];
            }
            
            [dateComps setHour:alarmHour];
            [dateComps setMinute:alarmMinute];
            [dateComps setSecond:alarmSecond];
            
            NSInteger tempWeekDay = [dateComps weekday];
            NSInteger tempDay = [dateComps day];
            
            if (noti_2) {
                
                [dateComps setWeekday:3];
                
                for(int i=1; i<5; i++) {
                    
                    if (tempDay + 7*i > totalDays) {
                        
                        [dateComps setDay:tempDay + 7*i - totalDays + 3 - tempWeekDay];
                        break;
                    }
                }
                
                
                noti_2.fireDate = [calendar dateFromComponents:dateComps];
                noti_2.timeZone = [NSTimeZone defaultTimeZone];
                noti_2.repeatInterval = NSWeekCalendarUnit;
                noti_2.soundName = UILocalNotificationDefaultSoundName;
                noti_2.alertBody = @"来做一次网盘测试任务吧！本月任务还剩 5 次。";
                
                NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_2" forKey:@"noti"];
                noti_2.userInfo = infoDic;
                
                UIApplication *app = [UIApplication sharedApplication];
                [app scheduleLocalNotification:noti_2];
            }
            
            if (noti_4) {
                
                [dateComps setWeekday:5];
                
                for(int i=1; i<5; i++) {
                    
                    if (tempDay + 7*i > totalDays) {
                        
                        [dateComps setDay:tempDay + 7*i - totalDays + 5 - tempWeekDay];
                        break;
                    }
                }
                
                noti_4.fireDate = [calendar dateFromComponents:dateComps];
                noti_4.timeZone = [NSTimeZone defaultTimeZone];
                noti_4.repeatInterval = NSWeekCalendarUnit;
                noti_4.soundName = UILocalNotificationDefaultSoundName;
                noti_4.alertBody = @"来做一次网盘测试任务吧！本月任务还剩 5 次。";
                
                NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_4" forKey:@"noti"];
                noti_4.userInfo = infoDic;
                
                UIApplication *app = [UIApplication sharedApplication];
                [app scheduleLocalNotification:noti_4];
            }
            
            if (noti_6) {
                
                [dateComps setWeekday:7];
                
                for(int i=1; i<5; i++) {
                    
                    if (tempDay + 7*i > totalDays) {
                        
                        [dateComps setDay:tempDay + 7*i - totalDays + 7 - tempWeekDay];
                        break;
                    }
                }
                
                noti_6.fireDate = [calendar dateFromComponents:dateComps];
                noti_6.timeZone = [NSTimeZone defaultTimeZone];
                noti_6.repeatInterval = NSWeekCalendarUnit;
                noti_6.soundName = UILocalNotificationDefaultSoundName;
                noti_6.alertBody = @"来做一次网盘测试任务吧！本月任务还剩 5 次。";
                
                NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_6" forKey:@"noti"];
                noti_6.userInfo = infoDic;
                
                UIApplication *app = [UIApplication sharedApplication];
                [app scheduleLocalNotification:noti_6];
            }
            
        } else {
            
            NSDate *date = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *dateComps;
            
            dateComps = [calendar components:(NSYearCalendarUnit   |
                                              NSMonthCalendarUnit  |
                                              NSDayCalendarUnit    |
                                              NSHourCalendarUnit   |
                                              NSMinuteCalendarUnit |
                                              NSSecondCalendarUnit |
                                              NSWeekdayCalendarUnit) fromDate:date];
            
            UILocalNotification *noti_2 = [[[UILocalNotification alloc] init] autorelease];
            UILocalNotification *noti_4 = [[[UILocalNotification alloc] init] autorelease];
            UILocalNotification *noti_6 = [[[UILocalNotification alloc] init] autorelease];
            
            
            [dateComps setYear:[dateComps year]];
            [dateComps setMonth:[dateComps month]];
            [dateComps setHour:alarmHour];
            [dateComps setMinute:alarmMinute];
            [dateComps setSecond:alarmSecond];
            
            NSInteger tempWeekDay = [dateComps weekday];
            NSInteger tempDay = [dateComps day];
            if (noti_2) {
                
                [dateComps setWeekday:3];
                
                if (tempWeekDay <= 3) {
                    [dateComps setDay:tempDay + 3 - tempWeekDay];
                } else {
                    [dateComps setDay:tempDay + 3 - tempWeekDay + 7];
                }
                
                noti_2.fireDate = [calendar dateFromComponents:dateComps];
                noti_2.timeZone = [NSTimeZone defaultTimeZone];
                noti_2.repeatInterval = NSWeekCalendarUnit;
                noti_2.soundName = UILocalNotificationDefaultSoundName;
                noti_2.alertBody = [NSString stringWithFormat:@"来做一次网盘测试任务吧！本月任务还剩 %@ 次。", numTaskToDo];
                
                NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_2" forKey:@"noti"];
                noti_2.userInfo = infoDic;
                
                UIApplication *app = [UIApplication sharedApplication];
                [app scheduleLocalNotification:noti_2];
            }
            
            if (noti_4) {
                
                [dateComps setWeekday:5];
                
                if (tempWeekDay <= 5) {
                    [dateComps setDay:tempDay + 5 - tempWeekDay];
                } else {
                    [dateComps setDay:tempDay + 5 - tempWeekDay + 7];
                }
                
                noti_4.fireDate = [calendar dateFromComponents:dateComps];
                noti_4.timeZone = [NSTimeZone defaultTimeZone];
                noti_4.repeatInterval = NSWeekCalendarUnit;
                noti_4.soundName = UILocalNotificationDefaultSoundName;
                noti_4.alertBody = [NSString stringWithFormat:@"来做一次网盘测试任务吧！本月任务还剩 %@ 次。", numTaskToDo];
                
                NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_4" forKey:@"noti"];
                noti_4.userInfo = infoDic;
                
                UIApplication *app = [UIApplication sharedApplication];
                [app scheduleLocalNotification:noti_4];
            }
            
            if (noti_6) {
                
                [dateComps setWeekday:7];
                [dateComps setDay:tempDay + 7 - tempWeekDay];
                
                noti_6.fireDate = [calendar dateFromComponents:dateComps];
                noti_6.timeZone = [NSTimeZone defaultTimeZone];
                noti_6.repeatInterval = NSWeekCalendarUnit;
                noti_6.soundName = UILocalNotificationDefaultSoundName;
                noti_6.alertBody = [NSString stringWithFormat:@"来做一次网盘测试任务吧！本月任务还剩 %@ 次。", numTaskToDo];
                
                NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_6" forKey:@"noti"];
                noti_6.userInfo = infoDic;
                
                UIApplication *app = [UIApplication sharedApplication];
                [app scheduleLocalNotification:noti_6];
            }
        }
        
    } else { // 第一次运行程序
            
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComps;
        
        dateComps = [calendar components:(NSYearCalendarUnit   |
                                          NSMonthCalendarUnit  |
                                          NSDayCalendarUnit    |
                                          NSHourCalendarUnit   |
                                          NSMinuteCalendarUnit |
                                          NSSecondCalendarUnit |
                                          NSWeekdayCalendarUnit) fromDate:date];
        
        UILocalNotification *noti_2 = [[[UILocalNotification alloc] init] autorelease];
        UILocalNotification *noti_4 = [[[UILocalNotification alloc] init] autorelease];
        UILocalNotification *noti_6 = [[[UILocalNotification alloc] init] autorelease];
        
        [dateComps setYear:[dateComps year]];
        [dateComps setMonth:[dateComps month]];
        [dateComps setHour:alarmHour];
        [dateComps setMinute:alarmMinute];
        [dateComps setSecond:alarmSecond];
        
        NSInteger tempWeekDay = [dateComps weekday];
        NSInteger tempDay = [dateComps day];
        
        if (noti_2) {
            
            [dateComps setWeekday:3];
            
            if (tempWeekDay <= 3) {
                [dateComps setDay:tempDay + 3 - tempWeekDay];
            } else {
                [dateComps setDay:tempDay + 3 - tempWeekDay + 7];
            }
            
            
            noti_2.fireDate = [calendar dateFromComponents:dateComps];
            noti_2.timeZone = [NSTimeZone defaultTimeZone];
            noti_2.repeatInterval = NSWeekCalendarUnit;
            noti_2.soundName = UILocalNotificationDefaultSoundName;
            noti_2.alertBody = @"来做一次网盘测试任务吧！本月任务还剩 5 次。";
            
            NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_2" forKey:@"noti"];
            noti_2.userInfo = infoDic;
            
            UIApplication *app = [UIApplication sharedApplication];
            [app scheduleLocalNotification:noti_2];
        }
        
        if (noti_4) {
            
            [dateComps setWeekday:5];
            
            if (tempWeekDay <= 5) {
                [dateComps setDay:tempDay + 5 - tempWeekDay];
            } else {
                [dateComps setDay:tempDay + 5 - tempWeekDay + 7];
            }
            
            noti_4.fireDate = [calendar dateFromComponents:dateComps];
            noti_4.timeZone = [NSTimeZone defaultTimeZone];
            noti_4.repeatInterval = NSWeekCalendarUnit;
            noti_4.soundName = UILocalNotificationDefaultSoundName;
            noti_4.alertBody = @"来做一次网盘测试任务吧！本月任务还剩 5 次。";
            
            NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_4" forKey:@"noti"];
            noti_4.userInfo = infoDic;
            
            UIApplication *app = [UIApplication sharedApplication];
            [app scheduleLocalNotification:noti_4];
        }
        
        if (noti_6) {
            
            [dateComps setWeekday:7];
            [dateComps setDay:tempDay + 7 - tempWeekDay];
            
            noti_6.fireDate = [calendar dateFromComponents:dateComps];
            noti_6.timeZone = [NSTimeZone defaultTimeZone];
            noti_6.repeatInterval = NSWeekCalendarUnit;
            noti_6.soundName = UILocalNotificationDefaultSoundName;
            noti_6.alertBody = @"来做一次网盘测试任务吧！本月任务还剩 5 次。";
            
            NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_6" forKey:@"noti"];
            noti_6.userInfo = infoDic;
            
            UIApplication *app = [UIApplication sharedApplication];
            [app scheduleLocalNotification:noti_6];
        }
    }
    
    /*
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps;
    
    dateComps = [calendar components:(NSYearCalendarUnit   |
                                      NSMonthCalendarUnit  |
                                      NSDayCalendarUnit    |
                                      NSHourCalendarUnit   |
                                      NSMinuteCalendarUnit |
                                      NSSecondCalendarUnit |
                                      NSWeekdayCalendarUnit) fromDate:date];
    
    UILocalNotification *noti_4 = [[[UILocalNotification alloc] init] autorelease];
    
    [dateComps setYear:[dateComps year]];
    [dateComps setMonth:[dateComps month]];
    [dateComps setDay:[dateComps day] + 5 - [dateComps weekday]];
    [dateComps setHour:10];
    [dateComps setMinute:40];
    [dateComps setSecond:1];
    
    if (noti_4) {
        
        [dateComps setWeekday:5];
        
        noti_4.fireDate = [calendar dateFromComponents:dateComps];
        noti_4.timeZone = [NSTimeZone defaultTimeZone];
        noti_4.repeatInterval = kCFCalendarUnitMinute;// kCFCalendarUnitMinute // NSWeekCalendarUnit
        noti_4.soundName = UILocalNotificationDefaultSoundName;
        noti_4.alertBody = @"来做一次网盘测试任务吧！本月任务还剩 5 次。";
        noti_4.applicationIconBadgeNumber = 1;
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"noti_4" forKey:@"noti"];
        noti_4.userInfo = infoDic;
        
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:noti_4];
    }
     */
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    _applicationFromBackground = TRUE;
    
    if ([_currentViewController isKindOfClass:[TaskViewController class]]) {
        
        [(TaskViewController *)_currentViewController viewWillDisappear:NO];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    if ([_currentViewController isKindOfClass:[TaskViewController class]]) {
        
        [(TaskViewController *)_currentViewController viewWillAppear:NO];
    }
    if ([_currentViewController isKindOfClass:[TaskListViewController class]]) {
        
        [(TaskListViewController *)_currentViewController viewWillAppear:NO];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps;
    dateComps = [calendar components:NSMonthCalendarUnit fromDate:date];
    NSString * month = [NSString stringWithFormat:@"%d", [dateComps month]];
    
    //
    NSString *fileNameLoad = [self filePath:@"userInfo.archiver"];
    NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileNameLoad];
    
    if ([dataLoad length] > 0) {
        
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataLoad];
        NSString *name  = [unArchiver decodeObjectForKey:@"userName"];
        NSString *phone = [unArchiver decodeObjectForKey:@"userPhone"];
        NSString *monthLoad = [unArchiver decodeObjectForKey:@"userTaskMonth"];
        
        [unArchiver finishDecoding];
        [unArchiver release];
        
        if ([month intValue] == [monthLoad intValue]) {
            
        } else {
            
            NSMutableData   *data     = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
            
            NSString *numTaskToDo = @"5";
            [archiver encodeObject:numTaskToDo forKey:@"userNumTaskToDo"];
            [archiver encodeObject:name forKey:@"userName"];
            [archiver encodeObject:phone forKey:@"userPhone"];
            [archiver encodeObject:month forKey:@"userTaskMonth"];
            
            [archiver finishEncoding];
            [data writeToFile:fileNameLoad atomically:YES];
            [archiver release];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *)filePath: (NSString* )fileName {
    
    NSArray  *myPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    NSString *filePath  = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
