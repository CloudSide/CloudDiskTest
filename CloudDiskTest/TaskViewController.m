//
//  TaskViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-5-17.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "TaskViewController.h"

#import "AppDelegate.h"


@interface TaskViewController ()

@end

@implementation TaskViewController

@synthesize taskButton3G = _taskButton3G;
@synthesize taskButtonWifi = _taskButtonWifi;
@synthesize bdConnect = _bdConnect;
@synthesize numTaskToDo = _numTaskToDo;
@synthesize backButton = _backButton;
@synthesize internetReachable = _internetReachable;
@synthesize networkLabel = _networkLabel;

- (void)dealloc {
    
    [_taskButtonWifi release];
    [_taskButton3G release];
    [_bdConnect release];
    [_numTaskToDo release];
    [_backButton release];
    [_internetReachable release];
    [_networkLabel release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(40, 50, 250, 50)] autorelease];
    NSInteger num = [_numTaskToDo integerValue];
    label.text = [NSString stringWithFormat:@"第 %d 轮任务，包括任务A、任务B", 5-num+1];
    [self.view addSubview:label];
    
    _taskButton3G = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_taskButton3G setExclusiveTouch:YES];
    [_taskButton3G setTitle:@"任务A：（2G/3G 网络测试）" forState:UIControlStateNormal];
    _taskButton3G.frame = CGRectMake(20, 100, 280, 50);
    [_taskButton3G addTarget:self action:@selector(onTask3G:) forControlEvents:UIControlEventTouchUpInside];
    [_taskButton3G setUserInteractionEnabled:NO];
    [self.view addSubview:_taskButton3G];
    
    _taskButtonWifi = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_taskButtonWifi setExclusiveTouch:YES];
    [_taskButtonWifi setTitle:@"任务B：（Wifi 网络测试）     " forState:UIControlStateNormal];
    _taskButtonWifi.frame = CGRectMake(20, 230, 280, 50);
    [_taskButtonWifi addTarget:self action:@selector(onTaskWifi:) forControlEvents:UIControlEventTouchUpInside];
    [_taskButtonWifi setUserInteractionEnabled:NO];
    [self.view addSubview:_taskButtonWifi];
    
    _networkLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 350, 250, 50)] autorelease];
    [self.view addSubview:[_networkLabel retain]];

    
    if ([TaskViewController IsEnable3G]) {
        
        [_taskButton3G setUserInteractionEnabled:YES];
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        _networkLabel.text = [NSString stringWithFormat:@"当前网络是：2G/3G，请执行任务A"];
        
    } else if ([TaskViewController IsEnableWIFI]) {
        
        [_taskButtonWifi setUserInteractionEnabled:YES];
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
        _networkLabel.text = [NSString stringWithFormat:@"当前网络是：WIFI，请执行任务B"];
        
    } else {
        
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
        _networkLabel.text = [NSString stringWithFormat:@"当前无可用网络，任务不可执行"];
    }
    
    _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backButton setExclusiveTouch:YES];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    _backButton.frame = CGRectMake(20, 410, 50, 30);
    [_backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    _internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [_internetReachable startNotifier];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // Create AppDelegate instance
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(objAppDelegate->_applicationFromBackground)
    {
        objAppDelegate->_applicationFromBackground = FALSE;
        
        if ([TaskViewController IsEnable3G]) {
            
            _taskButton3G.titleLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
            [_taskButton3G setUserInteractionEnabled:YES];
            
            _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
            [_taskButtonWifi setUserInteractionEnabled:NO];
            
            _networkLabel.text = [NSString stringWithFormat:@"当前网络是：2G/3G，请执行任务A"];
            
        } else if ([TaskViewController IsEnableWIFI]) {
            
            _taskButtonWifi.titleLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
            [_taskButtonWifi setUserInteractionEnabled:YES];
            
            _taskButton3G.titleLabel.textColor = [UIColor grayColor];
            [_taskButton3G setUserInteractionEnabled:NO];
            
            _networkLabel.text = [NSString stringWithFormat:@"当前网络是：WIFI，请执行任务B"];
            
        } else {
            
            [_taskButton3G setUserInteractionEnabled:NO];
            [_taskButtonWifi setUserInteractionEnabled:NO];
            _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
            _taskButton3G.titleLabel.textColor = [UIColor grayColor];
            
            _networkLabel.text = [NSString stringWithFormat:@"当前无可用网络，任务不可执行"];
        }
        
        [_internetReachable startNotifier];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    objAppDelegate.currentViewController = [self retain];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTask3G:(id)sender {
    
    NSLog(@"3g tested");
}

- (void)onTaskWifi:(id)sender {
    
    NSLog(@"wifi tested");
}

- (void)onBackButton:(id)sender {
    
    [_taskButton3G retain];
    [_taskButtonWifi retain];
    [_backButton retain];
    [_internetReachable retain];
    [self.navigationController popViewControllerAnimated:YES];
}

+ (BOOL)IsEnableWIFI {
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kReachableViaWiFi) {
        return YES;
    }
    
    return NO;
}

// 是否3G
+ (BOOL)IsEnable3G {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kReachableViaWWAN) {
        return YES;
    }
    
    return NO;
}

- (void)checkNetworkStatus:(NSNotification *)notice {
    
    if ([TaskViewController IsEnable3G]) {
        
        _taskButton3G.titleLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
        [_taskButton3G setUserInteractionEnabled:YES];
        
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        [_taskButtonWifi setUserInteractionEnabled:NO];
        
    } else if ([TaskViewController IsEnableWIFI]) {
        
        _taskButtonWifi.titleLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
        [_taskButtonWifi setUserInteractionEnabled:YES];
        
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
        [_taskButton3G setUserInteractionEnabled:NO];
    } else {
        
        [_taskButton3G setUserInteractionEnabled:NO];
        [_taskButtonWifi setUserInteractionEnabled:NO];
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
    }
    
}

@end
