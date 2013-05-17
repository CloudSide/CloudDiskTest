//
//  RootViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-1.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MainViewControllerVdisk.h"
#import "MainViewControllerBdisk.h"
#import "MainViewControllerKdisk.h"

#import "TaskListViewController.h"

#import "AppDelegate.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize currentPressedButton = _currentPressedButton;

@synthesize vDiskBtn = _vDiskBtn;
@synthesize bDiskBtn = _bDiskBtn;
@synthesize kDiskBtn = _kDiskBtn;

@synthesize textFieldName = _textFieldName;
@synthesize textFieldPhone = _textFieldPhone;
@synthesize signUpButton = _signUpButton;
@synthesize signOutButton  = _signOutButton;
@synthesize numTaskToDo = _numTaskToDo;

- (void)dealloc
{
    [_currentPressedButton release];
    
    [_vDiskBtn release];
    [_bDiskBtn release];
    [_kDiskBtn release];
    
    [_textFieldName release];
    [_textFieldPhone release];
    [_signUpButton release];
    [_signOutButton release];
    [_numTaskToDo release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if ([VdiskSession sharedSession] == nil) {
            
            SinaWeibo *sinaWeibo = [[[SinaWeibo alloc] initWithAppKey:kWeiboAppKey appSecret:kWeiboAppSecret appRedirectURI:kWeiboAppRedirectURI andDelegate:self] autorelease];
            
            VdiskSession *session = [[[VdiskSession alloc] initWithAppKey:kVdiskSDKDemoAppKey appSecret:kVdiskSDKDemoAppSecret appRoot:@"basic" sinaWeibo:sinaWeibo] autorelease];
            session.delegate = self;
            
            [session setRedirectURI:kVdiskSDKDemoAppRedirectURI];
            
            [VdiskSession setSharedSession:session];
            [VdiskComplexRequest setNetworkRequestDelegate:self];
        }
        
        if (_bdConnect == nil) {
            
            self.bdConnect = [[[Baidu alloc] initWithAPIKey:kBaiduApiKey appId:kBaiduAppId] autorelease];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationController.navigationBar setHidden:YES];
	
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:1];
    
    // 输入框
    [self createTextFieldAtView:view];
    
    // 点背景隐藏键盘
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [view addGestureRecognizer:singleTouch];
    
    // 按钮
    _signUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_signUpButton setExclusiveTouch:YES];
    [_signUpButton setTitle:@"登录微盘、百度云" forState:UIControlStateNormal];
    _signUpButton.frame = CGRectMake(15, 350, 140, 50);
    [_signUpButton addTarget:self action:@selector(onSignUpButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_signUpButton];
    
    _signOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_signOutButton setTitle:@"注销账号" forState:UIControlStateNormal];
    _signOutButton.frame = CGRectMake(165, 350, 140, 50);
    [_signOutButton addTarget:self action:@selector(onSignOutButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_signOutButton];
    
    /*
    [self createButton:_vDiskBtn withName:nameVDiskBtn atView:view];
    [self createButton:_bDiskBtn withName:nameBDiskBtn atView:view];
    [self createButton:_kDiskBtn withName:nameKDiskBtn atView:view];
    */
    [self setTitle:@"网盘选择"];
    
    self.view = view;
    [view release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    self.navigationController.toolbarHidden = YES;
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

- (void)createTextFieldAtView:(UIView *)view
{
    _textFieldName = [[UITextField alloc] initWithFrame:CGRectMake(40, 220, 240, 40)];
    [_textFieldName setBorderStyle:UITextBorderStyleRoundedRect];
    [_textFieldName setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1]];
    [_textFieldName setPlaceholder:@"请输入您的名字"];
    _textFieldName.returnKeyType = UIReturnKeyDone;
    _textFieldName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textFieldName.delegate = self;
    [view addSubview:_textFieldName];
    
    _textFieldPhone = [[UITextField alloc] initWithFrame:CGRectMake(40, 270, 240, 40)];
    [_textFieldPhone setBorderStyle:UITextBorderStyleRoundedRect];
    [_textFieldPhone setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1]];
    [_textFieldPhone setPlaceholder:@"请输入您的电话"];
    _textFieldPhone.returnKeyType = UIReturnKeyDone;
    _textFieldPhone.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textFieldPhone.delegate = self;
    [view addSubview:_textFieldPhone];


    
    NSString *fileNameLoad = [self filePath:@"userInfo.archiver"];
    NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileNameLoad];
    
    if ([dataLoad length] > 0) {
        
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataLoad];
        NSString *name  = [unArchiver decodeObjectForKey:@"userName"];
        NSString *phone = [unArchiver decodeObjectForKey:@"userPhone"];
        self.numTaskToDo = [unArchiver decodeObjectForKey:@"userNumTaskToDo"];
        
        [unArchiver finishDecoding];
        [unArchiver release];
        
        _textFieldName.text = name;
        _textFieldName.textColor = [UIColor grayColor];
        [_textFieldName setUserInteractionEnabled:NO];
        
        _textFieldPhone.text = phone;
        _textFieldPhone.textColor = [UIColor grayColor];
        [_textFieldPhone setUserInteractionEnabled:NO];
    }
}

- (void)onSignUpButton:(id)sender {
    
    NSString *fileName = [self filePath:@"userInfo.archiver"];
    NSData   *dataLoad     = [NSData dataWithContentsOfFile:fileName];
    
    if ([dataLoad length] > 0) {
        

    } else {
        
        NSMutableData   *data     = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        
        self.numTaskToDo = @"5";
        [archiver encodeObject:self.numTaskToDo forKey:@"userNumTaskToDo"];
        [archiver encodeObject:self.textFieldName.text forKey:@"userName"];
        [archiver encodeObject:self.textFieldPhone.text forKey:@"userPhone"];
        
        [archiver finishEncoding];
        [data writeToFile:fileName atomically:YES];
        [archiver release];
    }
    
    // 登陆
    if ([[VdiskSession sharedSession] isLinked] && ![[VdiskSession sharedSession] isExpired] && [self.bdConnect isUserSessionValid]) {
        
        TaskListViewController *taskListViewController = [[[TaskListViewController alloc] init] autorelease];
        taskListViewController.bdConnect = self.bdConnect;
        taskListViewController.numTaskToDo = self.numTaskToDo;
        [self.navigationController pushViewController:taskListViewController animated:YES];
        
    }else {
        
        //
        [self onSignOutButton:nil];
        [[VdiskSession sharedSession] linkWithSessionType:kVdiskSessionTypeDefault];
        
        //
//        [self.bdConnect authorizeWithScope:@"basic,netdisk" andDelegate:self];
    }

}

- (void)onSignOutButton:(id)sender {
    
    [_bdConnect currentUserLogout];
    [[VdiskSession sharedSession] unlink];
}

- (NSString *)filePath: (NSString* )fileName {
    
    NSArray  *myPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    NSString *filePath  = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}


#pragma mark -
#pragma Button define and function

- (void)createButton:(UIButton *)button withName:(NSString *)name atView:(UIView *)view
{
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setExclusiveTouch:YES];
    
    //按钮的背景图
    UIImage *backgroundBtnImg = [UIImage imageNamed:@"hotBackground.png"];
    UIImage *backgroundBtnImgCap = [backgroundBtnImg stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    UIImage *backgroundBtnClickImg = [UIImage imageNamed:@"hotBackgroundPressed.png"];
    UIImage *backgroundBtnClickImgCap = [backgroundBtnClickImg stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    
    //图片倒圆角
    CALayer *layer = button.imageView.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:8.0];
    
    [button setBackgroundImage:backgroundBtnImgCap forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundBtnClickImgCap forState:UIControlStateHighlighted];
    
    //按钮边框
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:8.0];
    [button.layer setBorderWidth:1];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpace,(CGFloat[]){ 1, 0, 0, 0 });
    [button.layer setBorderColor:colorRef];
    
    if ([name isEqualToString:nameVDiskBtn]) {
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0.7, 0, 0, 0);
        [button setTitleColor:[UIColor colorWithRed:45/255.0f green:45/255.0f blue:45/255.0f alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.titleEdgeInsets = UIEdgeInsetsMake(90, -110, 10, 0);
        
        UIImage *btnImg = [UIImage imageNamed:@"Icon@2x.png"];
        [button setImage:btnImg forState:UIControlStateNormal];
        [button setTitle:@"微盘" forState:UIControlStateNormal];
        button.frame = CGRectMake(110, 50, 100, 100);
        
        //按钮方法
        [button addTarget:self action:@selector(goToSignUp:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = tagBtnVdisk;

    } else if ([name isEqualToString:nameBDiskBtn]) {
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0.27, 0, 0, 0);
        [button setTitleColor:[UIColor colorWithRed:45/255.0f green:45/255.0f blue:45/255.0f alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.titleEdgeInsets = UIEdgeInsetsMake(90, -170, 10, 0);
        
        UIImage *btnImg = [UIImage imageNamed:@"bb.jpg"];
        [button setImage:btnImg forState:UIControlStateNormal];
        [button setTitle:@"百度云" forState:UIControlStateNormal];
        button.frame = CGRectMake(110, 180, 100, 100);
        
        //按钮方法
        [button addTarget:self action:@selector(goToSignUp:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = tagBtnBdisk;
        
    } else {
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0.7, 0, 0, 0);
        [button setTitleColor:[UIColor colorWithRed:45/255.0f green:45/255.0f blue:45/255.0f alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.titleEdgeInsets = UIEdgeInsetsMake(90, -110, 10, 0);
        
        UIImage *btnImg = [UIImage imageNamed:@"kk@2x.png"];
        [button setImage:btnImg forState:UIControlStateNormal];
        [button setTitle:@"快盘" forState:UIControlStateNormal];
        button.frame = CGRectMake(110, 310, 100, 100);
        
        //按钮方法
        [button addTarget:self action:@selector(goToSignUp:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = tagBtnKdisk;
    }
    
    [view addSubview:button];
}


- (void)goToSignUp:(id)sender {
    
    if ( ((UIButton *)sender).tag == tagBtnVdisk ) {
        
        /* Littlebox-XXOO 加log之后放上面初始化去了
        if ([VdiskSession sharedSession] == nil) {
            
            SinaWeibo *sinaWeibo = [[[SinaWeibo alloc] initWithAppKey:kWeiboAppKey appSecret:kWeiboAppSecret appRedirectURI:kWeiboAppRedirectURI andDelegate:self] autorelease];
            
            VdiskSession *session = [[[VdiskSession alloc] initWithAppKey:kVdiskSDKDemoAppKey appSecret:kVdiskSDKDemoAppSecret appRoot:@"basic" sinaWeibo:sinaWeibo] autorelease];
            session.delegate = self;
            
            [session setRedirectURI:kVdiskSDKDemoAppRedirectURI];
            
            [VdiskSession setSharedSession:session];
            [VdiskComplexRequest setNetworkRequestDelegate:self];
        }
         */
        
        if ([[VdiskSession sharedSession] isLinked] && ![[VdiskSession sharedSession] isExpired]) {
            
            MainViewControllerVdisk *mainViewControllerVdisk = [[[MainViewControllerVdisk alloc] init] autorelease];
            [self.navigationController pushViewController:mainViewControllerVdisk animated:YES];
            
        }else {
            
            [[VdiskSession sharedSession] linkWithSessionType:kVdiskSessionTypeDefault];
        }
        
    }else if (((UIButton *)sender).tag == tagBtnBdisk) {
        
        if (_bdConnect == nil) {
            
            self.bdConnect = [[[Baidu alloc] initWithAPIKey:kBaiduApiKey appId:kBaiduAppId] autorelease];
        }
        
        if ([self.bdConnect isUserSessionValid]) {
            MainViewControllerBdisk *mainViewControllerBdisk = [[[MainViewControllerBdisk alloc] init] autorelease];
            mainViewControllerBdisk.bdConnect = self.bdConnect;
            [self.navigationController pushViewController:mainViewControllerBdisk animated:YES];
            
        } else {
            
            [self.bdConnect authorizeWithScope:@"basic,netdisk" andDelegate:self];
        }
        
    }else {
        
        MainViewControllerKdisk *mainViewControllerKdisk = [[[MainViewControllerKdisk alloc] init] autorelease];
        [self.navigationController pushViewController:mainViewControllerKdisk animated:YES];
    }
}

#pragma mark -
#pragma mark VdiskNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    
	outstandingRequests++;
	
    if (outstandingRequests == 1) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	
    outstandingRequests--;
	
    if (outstandingRequests == 0) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

#pragma mark -
#pragma mark VdiskSessionDelegate methods

- (void)sessionAlreadyLinked:(VdiskSession *)session {
    
    NSLog(@"sessionAlreadyLinked");
}

// Log in successfully.
- (void)sessionLinkedSuccess:(VdiskSession *)session {
    
    /*
     VdiskRestClient *restClient = [[VdiskRestClient alloc] initWithSession:[VdiskSession sharedSession]];
     [restClient loadAccountInfo];
     */
    
    NSLog(@"sessionLinkedSuccess");
    
    
    @try {
        
//        MainViewControllerVdisk *mainViewControllerVdisk = [[[MainViewControllerVdisk alloc] init] autorelease];
//        [self.navigationController pushViewController:mainViewControllerVdisk animated:YES];
        
        [self.bdConnect authorizeWithScope:@"basic,netdisk" andDelegate:self];
        
    } @catch (NSException *exception) {
        
        NSLog(@"%@", exception);
        
    } @finally {
        
        
    }
    
    
}

//log fail
- (void)session:(VdiskSession *)session didFailToLinkWithError:(NSError *)error {
    
    NSLog(@"didFailToLinkWithError:%@", error);
}

// Log out successfully.
- (void)sessionUnlinkedSuccess:(VdiskSession *)session {
    
    NSLog(@"sessionUnlinkedSuccess");
    [self.navigationController popViewControllerAnimated:YES];
}

// When you use the VdiskSession's request methods,
// you may receive the following four callbacks.
- (void)sessionNotLink:(VdiskSession *)session {
    
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"sessionNotLink");
}


- (void)sessionExpired:(VdiskSession *)session {
    
    [[VdiskSession sharedSession] refreshLink];
    
    NSLog(@"sessionExpired");
}

#pragma mark -
#pragma mark BaiduAuthorizeDelegate methods

- (void)loginDidSuccess
{
//    MainViewControllerBdisk *mainViewControllerBdisk = [[[MainViewControllerBdisk alloc] init] autorelease];
//    mainViewControllerBdisk.bdConnect = self.bdConnect;
//    [self.navigationController pushViewController:mainViewControllerBdisk animated:YES];
    
    TaskListViewController *taskListViewController = [[[TaskListViewController alloc] init] autorelease];
    taskListViewController.bdConnect = self.bdConnect;
    taskListViewController.numTaskToDo = self.numTaskToDo;
    [self.navigationController pushViewController:taskListViewController animated:YES];
}

- (void)loginDidCancel
{
    [[VdiskSession sharedSession] unlink];
}

- (void)loginFailedWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 110 - (self.view.frame.size.height - 240);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    if (offset == 160) {
        offset = 110;
    }
    
    if(offset > 0) {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard:(id)sender{
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
    [_textFieldName resignFirstResponder];
    [_textFieldPhone resignFirstResponder];
}

@end
