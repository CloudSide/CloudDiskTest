//
//  TaskListViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-5-16.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "TaskListViewController.h"
#import "TaskViewController.h"
#import "AppDelegate.h"

@interface TaskListViewController ()

@end

@implementation TaskListViewController

@synthesize bdConnect = _bdConnect;
@synthesize startButton = _startButton;
@synthesize backButton = _backButton;
@synthesize numTaskToDo = _numTaskToDo;

- (void)dealloc {
    
    [_bdConnect release];
    [_startButton release];
    [_backButton release];
    [_numTaskToDo release];
    
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
    
    _startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_startButton setExclusiveTouch:YES];
    [_startButton setTitle:@"开始新任务" forState:UIControlStateNormal];
    _startButton.frame = CGRectMake(20, 200, 280, 50);
    [_startButton addTarget:self action:@selector(onStartButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    _backButton.frame = CGRectMake(20, 410, 50, 30);
    [_backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
}

- (void)viewDidAppear:(BOOL)animated {
    
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    objAppDelegate.currentViewController = [self retain];
    
    NSString *fileNameLoad = [self filePath:@"userInfo.archiver"];
    NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileNameLoad];
    
    if ([dataLoad length] > 0) {
        
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataLoad];
        
        self.numTaskToDo = [unArchiver decodeObjectForKey:@"userNumTaskToDo"];
        
        UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 150, 250, 50)] autorelease];
        label.text = [NSString stringWithFormat:@"本月您还有 %@ 轮任务需要执行", _numTaskToDo];
        [self.view addSubview:label];
        
        [unArchiver finishDecoding];
        [unArchiver release];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(objAppDelegate->_applicationFromBackground)
    {
        objAppDelegate->_applicationFromBackground = FALSE;
    
        NSString *fileNameLoad = [self filePath:@"userInfo.archiver"];
        NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileNameLoad];
        
        if ([dataLoad length] > 0) {
            
            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataLoad];
            
            self.numTaskToDo = [unArchiver decodeObjectForKey:@"userNumTaskToDo"];
            
            UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 150, 250, 50)] autorelease];
            label.text = [NSString stringWithFormat:@"本月您还有 %@ 轮任务需要执行", _numTaskToDo];
            [self.view addSubview:label];
            
            [unArchiver finishDecoding];
            [unArchiver release];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onStartButton:(id)sender {
    
    TaskViewController *taskViewController = [[[TaskViewController alloc] init] autorelease];
    taskViewController.bdConnect = self.bdConnect;
    taskViewController.numTaskToDo = self.numTaskToDo;
    [self.navigationController pushViewController:taskViewController animated:YES];
}

- (void)onBackButton:(id)sender {
    
    [_startButton retain];
    [_backButton retain];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSString *)filePath: (NSString* )fileName {
    
    NSArray  *myPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    NSString *filePath  = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
