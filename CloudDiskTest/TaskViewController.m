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
@synthesize cancelButton = _cancelButton;
@synthesize internetReachable = _internetReachable;
@synthesize networkLabel = _networkLabel;
@synthesize taskHint = _taskHint;
@synthesize labelHint = _labelHint;

@synthesize deletePath = _deletePath;
@synthesize request = _request;

@synthesize taskAProcessLabel = _taskAProcessLabel;
@synthesize taskBProcessLabel = _taskBProcessLabel;

@synthesize userName = _userName;
@synthesize phoneNum = _phoneNum;

- (void)dealloc {
    
    [_vdiskRestClient cancelAllRequests];
    [_vdiskRestClient setDelegate:nil];
    [_vdiskRestClient release];
    
    [_taskButtonWifi release];
    [_taskButton3G release];
    [_bdConnect release];
    [_numTaskToDo release];
    [_backButton release];
    [_cancelButton release];
    [_internetReachable release];
    [_networkLabel release];
    [_taskAProcessLabel release];
    [_taskBProcessLabel release];
    [_taskHint release];
    [_labelHint release];
    [_userName release];
    [_phoneNum release];
    
    if (_request != nil && ![_request isFinished]) {
        
        [_request cancel];
        [_request setDelegate:nil];
        [_request setDownloadProgressDelegate:nil];
    }
    [_request release];

    [_deletePath release];
    
    [_clogUpload release], _clogUpload = nil;
    [_clogDownload release], _clogDownload = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _vdiskRestClient = [[VdiskRestClient alloc] initWithSession:[VdiskSession sharedSession]];
        [_vdiskRestClient setDelegate:self];
        
        _taskIndex = 0;
        _taskFlag = 0;
        _bDiskUpDownFlag = 0;
        _indexRound = 0;
        
        _task3GFinished = 0;
        _taskWifiFinished = 0;
        
        _processTotal = 0;
        
        _numTaskFinished = 0;
        
        _isRunning = NO;
        _alertByNetChange = NO;
        
        _taskFailed = NO;
        
        _clogUpload = [[CLog alloc] init];
        [_clogUpload setCustomType:kLogCustomType];
        
        _clogDownload = [[CLog alloc] init];
        [_clogDownload setCustomType:kLogCustomType];
        
        [self cleanTempFiles];
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
    
    _labelHint = [[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 250, 50)] autorelease];
    _labelHint.text = [NSString stringWithFormat:@"正在测试，请不要关闭程序"];
    [self.view addSubview:_labelHint];
    _labelHint.textColor = [UIColor redColor];
    [_labelHint setHidden:YES];
    
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
    
    // 网络状态
    _networkLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30, 320, 250, 30)] autorelease];
    [self.view addSubview:[_networkLabel retain]];
    
    if ([TaskViewController IsEnable3G]) {
        
        [_taskButton3G setUserInteractionEnabled:YES];
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        _networkLabel.text = [NSString stringWithFormat:@"当前网络：2G/3G"];
        
    } else if ([TaskViewController IsEnableWIFI]) {
        
        [_taskButtonWifi setUserInteractionEnabled:YES];
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
        _networkLabel.text = [NSString stringWithFormat:@"当前网络：WIFI"];
        
    } else {
        
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
        _networkLabel.text = [NSString stringWithFormat:@"当前无可用网络，任务不可执行"];
    }
    
    // 任务提示
    _taskHint = [[[UILabel alloc] initWithFrame:CGRectMake(30, 360, 250, 30)] autorelease];
    _taskHint.text = [NSString stringWithFormat:@"请执行未完成任务"];
    [self.view addSubview:[_taskHint retain]];
    
    // 任务进度
    _taskAProcessLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 150, 250, 30)] autorelease];
    [self.view addSubview:[_taskAProcessLabel retain]];
    [_taskAProcessLabel setHidden:YES];
    [_taskAProcessLabel setFont: [UIFont fontWithName:@"Helvetica Neue" size:14]];
    _taskAProcessLabel.textColor = [UIColor redColor];
    
    _taskBProcessLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 280, 250, 30)] autorelease];
    [self.view addSubview:[_taskBProcessLabel retain]];
    [_taskBProcessLabel setHidden:YES];
    [_taskBProcessLabel setFont: [UIFont fontWithName:@"Helvetica Neue" size:14]];
    _taskBProcessLabel.textColor = [UIColor redColor];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backButton setExclusiveTouch:YES];
    [_backButton setTitle:@"取消本轮任务" forState:UIControlStateNormal];
    _backButton.frame = CGRectMake(20, 410, 100, 30);
    [_backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cancelButton setExclusiveTouch:YES];
    [_cancelButton setTitle:@"停止当前任务" forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake(200, 410, 100, 30);
    [_cancelButton addTarget:self action:@selector(onCancelTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    [_cancelButton setHidden:YES];
    
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
            
            if (_isRunning) {
                [_taskButton3G setUserInteractionEnabled:NO];
            } else {
                [_taskButton3G setUserInteractionEnabled:YES];
            }
            
            _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
            [_taskButtonWifi setUserInteractionEnabled:NO];
            
            _networkLabel.text = [NSString stringWithFormat:@"当前网络：2G/3G"];
            
        } else if ([TaskViewController IsEnableWIFI]) {
            
            _taskButtonWifi.titleLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
            
            if (_isRunning) {
                [_taskButtonWifi setUserInteractionEnabled:NO];
            } else {
                [_taskButtonWifi setUserInteractionEnabled:YES];
            }
            
            _taskButton3G.titleLabel.textColor = [UIColor grayColor];
            [_taskButton3G setUserInteractionEnabled:NO];
            
            _networkLabel.text = [NSString stringWithFormat:@"当前网络：WIFI"];
            
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
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (_isRunning) {
        [self onCancelTask:nil];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTask3G:(id)sender {
    
    if (_task3GFinished == 1) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A已完成"
                                                                message:[NSString stringWithFormat:@"切换到wifi网络执行任务B"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
        [alertView show];
        [alertView release];
    
    } else {
        
        [self cleanTempFiles];
        _taskFlag = 0;
        _isRunning = YES;
        [_cancelButton setHidden:NO];
        
        [_taskAProcessLabel setHidden:NO];
        
        [_backButton setUserInteractionEnabled:NO];
        [_taskButton3G setUserInteractionEnabled:NO];
        [_taskButtonWifi setUserInteractionEnabled:NO];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk", documentsDirectoryPath];
        NSString *tmpDirectory2 = [NSString stringWithFormat:@"%@/vdisk", documentsDirectoryPath];
        [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory2 error:nil];
        
        [self upLoadDataVdisk:_taskIndex];
        
        [_labelHint setHidden:NO];
    }
}

- (void)onTaskWifi:(id)sender {
    
    if (_taskWifiFinished == 1) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B已完成"
                                                            message:[NSString stringWithFormat:@"切换到2G/3G网络执行任务A"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
    } else {
        
        [self cleanTempFiles];
        _taskFlag = 1;
        _isRunning = YES;
        [_cancelButton setHidden:NO];
        
        [_taskBProcessLabel setHidden:NO];
        
        [_backButton setUserInteractionEnabled:NO];
        [_taskButton3G setUserInteractionEnabled:NO];
        [_taskButtonWifi setUserInteractionEnabled:NO];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk", documentsDirectoryPath];
        NSString *tmpDirectory2 = [NSString stringWithFormat:@"%@/vdisk", documentsDirectoryPath];
        [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory2 error:nil];
        
        [self upLoadDataVdisk:_taskIndex];
        
        [_labelHint setHidden:NO];
    }
}

- (void)upLoadDataVdisk:(int)index {
    
    if (index == 0) {
        
        NSString *fileName = @"0_2M.txt";
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:0.2*1024*1024];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        [emptyData release];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            
            NSString *destPath = [NSString stringWithFormat:@"/"];
            [_vdiskRestClient uploadFile:fileName toPath:destPath fromPath:tmpPath params:@{@"overwrite":@"true"}];
        }
    } else if (index == 1) {
        
        NSString *fileName = @"0_7M.txt";
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:0.7*1024*1024];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        [emptyData release];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            
            NSString *destPath = [NSString stringWithFormat:@"/"];
            [_vdiskRestClient uploadFile:fileName toPath:destPath fromPath:tmpPath params:@{@"overwrite":@"true"}];
        }
    } else if (index == 2){
        
        NSString *fileName = @"1_2M.txt";
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:1.2*1024*1024];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        [emptyData release];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            
            NSString *destPath = [NSString stringWithFormat:@"/"];
            [_vdiskRestClient uploadFile:fileName toPath:destPath fromPath:tmpPath params:@{@"overwrite":@"true"}];
        }
    }
}

- (void)upLoadDataBdisk:(int)index {
    
    if (index == 0) {
        
        NSString *fileName = @"0_2M.txt";
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:0.2*1024*1024];
        _uploadSize = 0.2*1024*1024;        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        [emptyData release];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            
            if (_request != nil) {
                [_request cancel];
            }
            
            self.deletePath = tmpPath;
            
            NSString *destPath = [NSString stringWithFormat:@"/apps/CloudDisk/%@", fileName];
            NSString *access_token = [BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken;
            NSString *requestText = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/file?method=upload&path=%@&access_token=%@&ondup=overwrite", [destPath URLEncodedString], access_token];
            
            NSString *httpMethodText = @"POST";
            
            NSURL *requestUrl = [NSURL URLWithString:requestText];
            self.request = [ASIFormDataRequest requestWithURL:requestUrl];
            [_request setRequestMethod:httpMethodText];
            [_request setFile:tmpPath forKey:@"file"];
            [_request setDelegate:self];
            [_request setUploadProgressDelegate:self];
            [_request setShouldAttemptPersistentConnection:NO];
            
            [_request startAsynchronous];
            
            [_clogUpload startRecordTime];
        }
    } else if (index == 1) {
        
        NSString *fileName = @"0_7M.txt";
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:0.7*1024*1024];
        _uploadSize = 0.7*1024*1024;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        [emptyData release];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            
            if (_request != nil) {
                [_request cancel];
            }
            
            self.deletePath = tmpPath;
            
            NSString *destPath = [NSString stringWithFormat:@"/apps/CloudDisk/%@", fileName];
            NSString *access_token = [BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken;
            NSString *requestText = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/file?method=upload&path=%@&access_token=%@&ondup=overwrite", [destPath URLEncodedString], access_token];
            
            NSString *httpMethodText = @"POST";
            
            NSURL *requestUrl = [NSURL URLWithString:requestText];
            self.request = [ASIFormDataRequest requestWithURL:requestUrl];
            [_request setRequestMethod:httpMethodText];
            [_request setFile:tmpPath forKey:@"file"];
            [_request setDelegate:self];
            [_request setUploadProgressDelegate:self];
            [_request setShouldAttemptPersistentConnection:NO];
            
            [_request startAsynchronous];
            
            [_clogUpload startRecordTime];
        }
    } else if (index == 2){
        
        NSString *fileName = @"1_2M.txt";
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:1.2*1024*1024];
        _uploadSize = 1.2*1024*1024;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        [emptyData release];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            
            if (_request != nil) {
                [_request cancel];
            }
            
            self.deletePath = tmpPath;
            
            NSString *destPath = [NSString stringWithFormat:@"/apps/CloudDisk/%@", fileName];
            NSString *access_token = [BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken;
            NSString *requestText = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/file?method=upload&path=%@&access_token=%@&ondup=overwrite", [destPath URLEncodedString], access_token];
            
            NSString *httpMethodText = @"POST";
            
            NSURL *requestUrl = [NSURL URLWithString:requestText];
            self.request = [ASIFormDataRequest requestWithURL:requestUrl];
            [_request setRequestMethod:httpMethodText];
            [_request setFile:tmpPath forKey:@"file"];
            [_request setDelegate:self];
            [_request setUploadProgressDelegate:self];
            [_request setShouldAttemptPersistentConnection:NO];
            
            [_request startAsynchronous];
            
            [_clogUpload startRecordTime];
        }
    }
}

- (void)downLoadDataVdisk:(int)index {
    
    NSString *fileName = nil;
    NSString *fromPath = nil;
    
    if (index == 0) {
        fileName = @"0_2M.txt";
        fromPath = @"/0_2M.txt";
    }
    if (index == 1) {
        fileName = @"0_7M.txt";
        fromPath = @"/0_7M.txt";
    }
    if (index == 2) {
        fileName = @"1_2M.txt";
        fromPath = @"/1_2M.txt";
    }
    
    if (fileName != nil) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *tmpDirectory = [NSString stringWithFormat:@"%@/vdisk", documentsDirectoryPath];
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:tmpPath]) {
            
            if ([fileManager createDirectoryAtPath:tmpDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
                
                [_vdiskRestClient loadFile:fromPath intoPath:tmpPath];
            }
        }
    }
    
}

- (void)downLoadDataBdisk:(int)index {
    
    NSString *fileName = nil;
    NSString *fromPath = nil;
    
    if (index == 0) {
        fileName = @"0_2M.txt";
        fromPath = @"/apps/CloudDisk/0_2M.txt";
    }
    if (index == 1) {
        fileName = @"0_7M.txt";
        fromPath = @"/apps/CloudDisk/0_7M.txt";
    }
    if (index == 2) {
        fileName = @"1_2M.txt";
        fromPath = @"/apps/CloudDisk/1_2M.txt";
    }
    
    if (fileName != nil) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk", documentsDirectoryPath];
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:tmpPath]) {
            
            if ([fileManager createDirectoryAtPath:tmpDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
                
                NSString *access_token = [BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken;
                
                NSString *requestText = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/file?method=download&access_token=%@&path=%@", access_token, [fromPath URLEncodedString]];
                
                NSString *httpMethodText = @"GET";
                
                if (_request != nil) {
                    [_request cancel];
                }
                
                NSURL *requestUrl = [NSURL URLWithString:requestText];
                self.request = [ASIHTTPRequest requestWithURL:requestUrl];
                [_request setDownloadDestinationPath:tmpPath];
                [_request setRequestMethod:httpMethodText];
                [_request setDelegate:self];
                [_request setDownloadProgressDelegate:self];
                [_request startAsynchronous];
                
                [_clogDownload startRecordTime];
                
            }
        }
    }
    
}

- (void)onBackButton:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"提示"];
    [alert setMessage:@"取消本轮任何后，本轮已完成的任务也将撤销，下次需要再次执行。确定要取消吗？"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert show];
    [alert release];
}

- (void)onCancelTask:(id)sender {
    
    [self stopTask];
    [_cancelButton setHidden:YES];
}

- (void)stopTask {
    
    [_vdiskRestClient cancelAllRequests];
    
    if (_request != nil && ![_request isFinished]) {
        
        [_request cancel];
        [_request clearDelegatesAndCancel];
    }
    
    _taskFailed = YES;
    
    _taskIndex = 0;
    _bDiskUpDownFlag = 0;
    _indexRound = 0;
    _processTotal = 0;
    
    NSString *alertTitle = nil;
    
    if (_taskFlag == 0) {
        
        alertTitle = @"任务A已取消";
        [_taskButton3G setUserInteractionEnabled:YES];
        [_taskAProcessLabel setHidden:YES];
        
    } else {
        
        alertTitle = @"任务B已取消";
        [_taskButtonWifi setUserInteractionEnabled:YES];
        [_taskBProcessLabel setHidden:YES];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
    
    [_backButton setUserInteractionEnabled:YES];
    [_cancelButton setHidden:YES];
    
    _isRunning = NO;
    [_labelHint setHidden:YES];
    
    [self cleanTempFiles];
}

- (void)taskFinished {
    
    //
    NSString *fileNameLoad = [self filePath:@"userInfo.archiver"];
    NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileNameLoad];
        
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataLoad];
    NSString *name  = [unArchiver decodeObjectForKey:@"userName"];
    NSString *phone = [unArchiver decodeObjectForKey:@"userPhone"];
    NSString *month = [unArchiver decodeObjectForKey:@"userTaskMonth"];
    self.numTaskToDo = [unArchiver decodeObjectForKey:@"userNumTaskToDo"];
    
    _userName = [name retain];
    _phoneNum = [phone retain];
    
    [unArchiver finishDecoding];
    [unArchiver release];
        
    NSMutableData   *data     = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    NSInteger num = [_numTaskToDo integerValue];
    if (num == 0) {
        self.numTaskToDo = [NSString stringWithFormat:@"%d",num];
    } else {
        self.numTaskToDo = [NSString stringWithFormat:@"%d",num-1];
    }
    [archiver encodeObject:self.numTaskToDo forKey:@"userNumTaskToDo"];
    [archiver encodeObject:name forKey:@"userName"];
    [archiver encodeObject:phone forKey:@"userPhone"];
    [archiver encodeObject:month forKey:@"userTaskMonth"];
    
    [archiver finishEncoding];
    [data writeToFile:fileNameLoad atomically:YES];
    [archiver release];
    
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [objAppDelegate scheduleAlarm];
    
    [_labelHint setHidden:YES];
    
    [_taskButton3G retain];
    [_taskButtonWifi retain];
    [_backButton retain];
    [_internetReachable retain];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cleanTempFiles {
    
    NSString *fileName = @"0_2M.txt";
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
    [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    
    NSString *fileName2 = @"0_7M.txt";
    NSString *tmpPath2 = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName2];
    [[NSFileManager defaultManager] removeItemAtPath:tmpPath2 error:nil];
    
    NSString *fileName3 = @"1_2M.txt";
    NSString *tmpPath3 = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName3];
    [[NSFileManager defaultManager] removeItemAtPath:tmpPath3 error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/vdisk", documentsDirectoryPath];
    [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
    
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath2 = [paths2 objectAtIndex:0];
    NSString *tmpDirectory2 = [NSString stringWithFormat:@"%@/bdisk", documentsDirectoryPath2];
    [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory2 error:nil];
}

- (void)getData {
    
    NSString *fileNameLoad = [self filePath:@"userInfo.archiver"];
    NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileNameLoad];
    
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataLoad];
    
    _userName = [unArchiver decodeObjectForKey:@"userName"];
    _phoneNum = [unArchiver decodeObjectForKey:@"userPhone"];
    
    [unArchiver finishDecoding];
    [unArchiver release];
    
    if (_phoneNum == nil) {
        _phoneNum = @"phone null";
    }
    if (_userName == nil) {
        _userName = @"name null";
    }

}

- (NSString *)filePath: (NSString* )fileName {
    
    NSArray  *myPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    NSString *filePath  = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

#pragma mark - Network state

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
    
    if (_isRunning) {
        
        _alertByNetChange = YES;
        [self onCancelTask:nil];
    }
    
    if ([TaskViewController IsEnable3G]) {
        
        _taskButton3G.titleLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
        [_taskButton3G setUserInteractionEnabled:YES];
        
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        [_taskButtonWifi setUserInteractionEnabled:NO];
        
        _networkLabel.text = [NSString stringWithFormat:@"当前网络：2G/3G"];
        
    } else if ([TaskViewController IsEnableWIFI]) {
        
        _taskButtonWifi.titleLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
        [_taskButtonWifi setUserInteractionEnabled:YES];
        
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
        [_taskButton3G setUserInteractionEnabled:NO];
        
        _networkLabel.text = [NSString stringWithFormat:@"当前网络：WIFI"];
    } else {
        
        [_taskButton3G setUserInteractionEnabled:NO];
        [_taskButtonWifi setUserInteractionEnabled:NO];
        _taskButtonWifi.titleLabel.textColor = [UIColor grayColor];
        _taskButton3G.titleLabel.textColor = [UIColor grayColor];
        
        _networkLabel.text = [NSString stringWithFormat:@"当前无可用网络，任务不可执行"];
    }
    
}

#pragma mark - VdiskRestClientDelegate

- (void)restClient:(VdiskRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(VdiskMetadata *)metadata {
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
    
    _taskIndex++;
    _processTotal++;
    
    if (_taskIndex < numberOfTask) {
        
        [self upLoadDataVdisk:_taskIndex];
        
    } else {
        
        _taskIndex = 0;
        _bDiskUpDownFlag = 0;
        [self upLoadDataBdisk:_taskIndex];
    }
}

- (void)restClient:(VdiskRestClient *)client uploadFileFailedWithError:(NSError *)error {
    
    _taskFailed = YES;
    
    if (_taskFlag == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A失败"
                                                            message:[NSString stringWithFormat:@"请重试"]
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_taskButton3G setUserInteractionEnabled:YES];
        [_taskAProcessLabel setHidden:YES];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B失败"
                                                            message:[NSString stringWithFormat:@"请重试"]
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_taskButtonWifi setUserInteractionEnabled:YES];
        [_taskBProcessLabel setHidden:YES];
    }
    
    [_backButton setUserInteractionEnabled:YES];
    [_cancelButton setHidden:YES];
    
    _taskIndex = 0;
    _bDiskUpDownFlag = 0;
    _indexRound = 0;
    _processTotal = 0;
    
    [_labelHint setHidden:YES];
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:[error.userInfo objectForKey:@"sourcePath"] error:nil];
    
    if ([[VdiskSession sharedSession] isLinked] && ![[VdiskSession sharedSession] isExpired] && [self.bdConnect isUserSessionValid]) {
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆超时"
                                                            message:[NSString stringWithFormat:@"请重新登陆"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_bdConnect currentUserLogout];
        [[VdiskSession sharedSession] unlink];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)restClient:(VdiskRestClient *)client loadedFile:(NSString *)destPath {
    
    _taskIndex++;
    _processTotal++;
    
    if (_taskIndex < numberOfTask) {
        
        [self downLoadDataVdisk:_taskIndex];
        
    } else {
        
        _taskIndex = 0;
        _bDiskUpDownFlag = 1;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *tmpDirectory = [NSString stringWithFormat:@"%@/vdisk", documentsDirectoryPath];

        [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
        
        [self downLoadDataBdisk:_taskIndex];
    }

}

- (void)restClient:(VdiskRestClient *)client loadFileFailedWithError:(NSError *)error {
    
    _taskFailed = YES;
    
    if (_taskFlag == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A失败"
                                                            message:[NSString stringWithFormat:@"请重试"]
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_taskButton3G setUserInteractionEnabled:YES];
        [_taskAProcessLabel setHidden:YES];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B失败"
                                                            message:[NSString stringWithFormat:@"请重试"]
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_taskButtonWifi setUserInteractionEnabled:YES];
        [_taskBProcessLabel setHidden:YES];
    }
    
    [_backButton setUserInteractionEnabled:YES];
    [_cancelButton setHidden:YES];
    
    _taskIndex = 0;
    _bDiskUpDownFlag = 0;
    _indexRound = 0;
    _processTotal = 0;
    
    [_labelHint setHidden:YES];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/vdisk", documentsDirectoryPath];
    
    [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
    
    if ([[VdiskSession sharedSession] isLinked] && ![[VdiskSession sharedSession] isExpired] && [self.bdConnect isUserSessionValid]) {
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆超时"
                                                            message:[NSString stringWithFormat:@"请重新登陆"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_bdConnect currentUserLogout];
        [[VdiskSession sharedSession] unlink];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

}

- (void)restClient:(VdiskRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath {
    
    if (_taskFlag == 0) {
        _taskAProcessLabel.text = [NSString stringWithFormat:@"总进度：%d/24, 当前进度：%.1f%%", _processTotal, progress*100.0f];
    }
    
    if (_taskFlag == 1) {
        _taskBProcessLabel.text = [NSString stringWithFormat:@"总进度：%d/24, 当前进度：%.1f%%", _processTotal, progress*100.0f];
    }
}

- (void)restClient:(VdiskRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
    
    if (_taskFlag == 0) {
        _taskAProcessLabel.text = [NSString stringWithFormat:@"总进度：%d/24, 当前进度：%.1f%%", _processTotal, progress*100.0f];
    }
    
    if (_taskFlag == 1) {
        _taskBProcessLabel.text = [NSString stringWithFormat:@"总进度：%d/24, 当前进度：%.1f%%", _processTotal, progress*100.0f];
    }
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (_bDiskUpDownFlag == 0) { // upload callback
        
        if ([request responseStatusCode] / 100 == 2) {
            
            [self getData];
            
            [_clogUpload setCustomKeys:@[@"app_name", @"action", @"error_code", _userName] andValues:@[kLogAppNameBaiduDisk, @"upload", @"", _phoneNum]];
            [_clogUpload setHttpBytesUp:[NSString stringWithFormat:@"%llu", _uploadSize]];
            [_clogUpload stopRecordTime];
            DDLogInfo(@"%@", _clogUpload);
            
            [[NSFileManager defaultManager] removeItemAtPath:_deletePath error:nil];
            _taskIndex++;
            _processTotal++;
            
            if (_taskIndex < numberOfTask) {
                
                [self upLoadDataBdisk:_taskIndex];
                
            } else {
                
                _taskIndex = 0;
                [self downLoadDataVdisk:_taskIndex];
            }
            
        } else {
            
            [self getData];
            
            [_clogUpload setCustomKeys:@[@"app_name", @"action", @"error_code", _userName] andValues:@[kLogAppNameBaiduDisk, @"upload", [NSString stringWithFormat:@"%d", [request responseStatusCode]], _phoneNum]];
            [_clogUpload stopRecordTime];
            DDLogInfo(@"%@", _clogUpload);
            
            _taskIndex = 0;
            _bDiskUpDownFlag = 0;
            _indexRound = 0;
            _processTotal = 0;
            _taskFailed = YES;
            
            if (_taskFlag == 0) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A失败"
                                                                    message:[NSString stringWithFormat:@"请重试"]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
                
                [alertView show];
                [alertView release];
                
                [_taskButton3G setUserInteractionEnabled:YES];
                [_taskAProcessLabel setHidden:YES];
                
            } else {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B失败"
                                                                    message:[NSString stringWithFormat:@"请重试"]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
                
                [alertView show];
                [alertView release];
                
                [_taskButtonWifi setUserInteractionEnabled:YES];
                [_taskBProcessLabel setHidden:YES];
            }
            
            [_backButton setUserInteractionEnabled:YES];
            [_cancelButton setHidden:YES];
            [_labelHint setHidden:YES];
            
            [[NSFileManager defaultManager] removeItemAtPath:_deletePath error:nil];
        }
    }
    
    if (_bDiskUpDownFlag == 1) {
        
        if ([request responseStatusCode] / 100 == 2) {
            
            [self getData];
            
            [_clogDownload setCustomKeys:@[@"app_name", @"action", @"error_code", _userName] andValues:@[kLogAppNameBaiduDisk, @"download", @"", _phoneNum]];
            [_clogDownload setHttpBytesDown:[NSString stringWithFormat:@"%llu", [request contentLength]]];
            [_clogDownload stopRecordTime];
            DDLogInfo(@"%@", _clogDownload);
            
            _taskIndex++;
            _processTotal++;
            
            if (_taskIndex < numberOfTask) {
                
                [self downLoadDataBdisk:_taskIndex];
                
            } else {
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectoryPath = [paths objectAtIndex:0];
                NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk", documentsDirectoryPath];
                
                [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
                
                _indexRound++;
                _taskIndex = 0;
                _bDiskUpDownFlag = 0;
                
                if (_indexRound < numberOfRound) {
                    
                    _processTotal++;
                    [self upLoadDataVdisk:_taskIndex];
                
                } else {

                    _indexRound = 0;
                    _processTotal = 0;
                    _numTaskFinished++;
                    
                    _isRunning = NO;
                    [_cancelButton setHidden:YES];
                    
                    if (_numTaskFinished != 2) {
                        
                        if (_taskFlag == 0) {
                            
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A已完成"
                                                                                message:[NSString stringWithFormat:@"切换到wifi网络执行任务B"]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"Okay"
                                                                      otherButtonTitles:nil];
                            
                            [alertView show];
                            [alertView release];
                            
                            [_taskButton3G setUserInteractionEnabled:YES];
                            [_taskButton3G setTitle:@"任务A：（2G/3G 网络测试）(已完成)" forState:UIControlStateNormal];
                            _task3GFinished = 1;
                            [_taskAProcessLabel setHidden:YES];
                            
                        } else {
                            
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B已完成"
                                                                                message:[NSString stringWithFormat:@"切换到2G/3G网络执行任务A"]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"Okay"
                                                                      otherButtonTitles:nil];
                            
                            [alertView show];
                            [alertView release];
                            
                            [_taskButtonWifi setUserInteractionEnabled:YES];
                            [_taskButtonWifi setTitle:@"任务B：（Wifi 网络测试）（已完成）" forState:UIControlStateNormal];
                            _taskWifiFinished = 1;
                            [_taskBProcessLabel setHidden:YES];
                        }
                        
                        [_backButton setUserInteractionEnabled:YES];
                        [_cancelButton setHidden:YES];
                        _taskHint.text = [NSString stringWithFormat:@"请切换网络，执行未完成任务"];
                        
                    } else {
                        
                        [_backButton setUserInteractionEnabled:YES];
                        [_cancelButton setHidden:YES];
                        _taskHint.text = [NSString stringWithFormat:@"请切换网络，执行未完成任务"];
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"恭喜您！"
                                                                            message:[NSString stringWithFormat:@"您已经完成本轮测试"]
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Okay"
                                                                  otherButtonTitles:nil];
                        
                        [alertView show];
                        [alertView release];
                    }
                }
            }
                        
        } else {
            
            [self getData];
            
            [_clogDownload setCustomKeys:@[@"app_name", @"action", @"error_code", _userName] andValues:@[kLogAppNameBaiduDisk, @"download", [NSString stringWithFormat:@"%d", [request responseStatusCode]], _phoneNum]];
            [_clogDownload setHttpBytesDown:[NSString stringWithFormat:@"%llu", [request contentLength]]];
            [_clogDownload stopRecordTime];
            DDLogInfo(@"%@", _clogDownload);
            
            _taskIndex = 0;
            _bDiskUpDownFlag = 0;
            _indexRound = 0;
            _processTotal = 0;
            _taskFailed = YES;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk", documentsDirectoryPath];
            
            [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
            
            if (_taskFlag == 0) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A失败"
                                                                    message:[NSString stringWithFormat:@"请重试"]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
                
                [alertView show];
                [alertView release];
                
                [_taskButton3G setUserInteractionEnabled:YES];
                [_taskAProcessLabel setHidden:YES];
                
            } else {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B失败"
                                                                    message:[NSString stringWithFormat:@"请重试"]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
                
                [alertView show];
                [alertView release];
                
                [_taskButtonWifi setUserInteractionEnabled:YES];
                [_taskBProcessLabel setHidden:YES];
            }
            
            [_backButton setUserInteractionEnabled:YES];
            [_cancelButton setHidden:YES];
            [_labelHint setHidden:YES];
        }
    }
    
    if ([[VdiskSession sharedSession] isLinked] && ![[VdiskSession sharedSession] isExpired] && [self.bdConnect isUserSessionValid]) {
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆超时"
                                                            message:[NSString stringWithFormat:@"请重新登陆"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_bdConnect currentUserLogout];
        [[VdiskSession sharedSession] unlink];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    _taskFailed = YES;
    
    if (_bDiskUpDownFlag == 0) {
        
        [self getData];
        
        [_clogUpload setCustomKeys:@[@"app_name", @"action", @"error_code", _userName] andValues:@[kLogAppNameBaiduDisk, @"upload", [NSString stringWithFormat:@"%d", [request responseStatusCode]], _phoneNum]];
        [_clogUpload stopRecordTime];
        DDLogInfo(@"%@", _clogUpload);
        
        _taskIndex = 0;
        _bDiskUpDownFlag = 0;
        _indexRound = 0;
        _processTotal = 0;
        
        if (_taskFlag == 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A失败"
                                                                message:[NSString stringWithFormat:@"请重试"]
                                                               delegate:self
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
            
            [_taskButton3G setUserInteractionEnabled:YES];
            [_taskAProcessLabel setHidden:YES];
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B失败"
                                                                message:[NSString stringWithFormat:@"请重试"]
                                                               delegate:self
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
            
            [_taskButtonWifi setUserInteractionEnabled:YES];
            [_taskBProcessLabel setHidden:YES];
        }
        
        [_backButton setUserInteractionEnabled:YES];
        [_cancelButton setHidden:YES];
        [_labelHint setHidden:YES];
        
        //delete tmp file
        [[NSFileManager defaultManager] removeItemAtPath:_deletePath error:nil];
    
    } else {
        
        [self getData];
        
        [_clogDownload setCustomKeys:@[@"app_name", @"action", @"error_code", _userName] andValues:@[kLogAppNameBaiduDisk, @"download", [NSString stringWithFormat:@"%d", [request responseStatusCode]], _phoneNum]];
        [_clogDownload setHttpBytesDown:[NSString stringWithFormat:@"%llu", [request contentLength]]];
        [_clogDownload stopRecordTime];
        DDLogInfo(@"%@", _clogDownload);
        
        _taskIndex = 0;
        _bDiskUpDownFlag = 0;
        _indexRound = 0;
        _processTotal = 0;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk", documentsDirectoryPath];
        
        [[NSFileManager defaultManager] removeItemAtPath:tmpDirectory error:nil];
        
        if (_taskFlag == 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务A失败"
                                                                message:[NSString stringWithFormat:@"请重试"]
                                                               delegate:self
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
            
            [_taskButton3G setUserInteractionEnabled:YES];
            [_taskAProcessLabel setHidden:YES];
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务B失败"
                                                                message:[NSString stringWithFormat:@"请重试"]
                                                               delegate:self
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
            
            [_taskButtonWifi setUserInteractionEnabled:YES];
            [_taskBProcessLabel setHidden:YES];
        }
        
        [_backButton setUserInteractionEnabled:YES];
        [_cancelButton setHidden:YES];
        [_labelHint setHidden:YES];
    }
    
    if ([[VdiskSession sharedSession] isLinked] && ![[VdiskSession sharedSession] isExpired] && [self.bdConnect isUserSessionValid]) {

    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆超时"
                                                            message:[NSString stringWithFormat:@"请重新登陆"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
        [_bdConnect currentUserLogout];
        [[VdiskSession sharedSession] unlink];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)setProgress:(float)newProgress {
    
    if (_taskFlag == 0) {
        _taskAProcessLabel.text = [NSString stringWithFormat:@"总进度：%d/24, 当前进度：%.1f%%", _processTotal, newProgress*100.0f];
    }
    
    if (_taskFlag == 1) {
        _taskBProcessLabel.text = [NSString stringWithFormat:@"总进度：%d/24, 当前进度：%.1f%%", _processTotal, newProgress*100.0f];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (_numTaskFinished == 2) {
        
        _numTaskFinished = 0;
        [self taskFinished];
    
    } else if (_alertByNetChange) {
        
        _alertByNetChange = NO;
        
        if (_taskFlag == 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络异常"
                                                                message:[NSString stringWithFormat:@"任务A要在2G/3G下进行，请检查网络状态后重试"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络异常"
                                                                message:[NSString stringWithFormat:@"任务B要在wifi下进行，请检查网络状态后重试"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
        }
    } else if (_taskFailed == YES) {
        
        _taskFailed = NO;
    } else {
        
        if (buttonIndex == 0) {
            
            [_taskButton3G retain];
            [_taskButtonWifi retain];
            [_backButton retain];
            [_internetReachable retain];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
}

@end
