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

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize currentPressedButton = _currentPressedButton;

@synthesize vDiskBtn = _vDiskBtn;
@synthesize bDiskBtn = _bDiskBtn;
@synthesize kDiskBtn = _kDiskBtn;

- (void)dealloc
{
    [_currentPressedButton release];
    
    [_vDiskBtn release];
    [_bDiskBtn release];
    [_kDiskBtn release];
    
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationController.navigationBar setHidden:YES];
	
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:239/255.0f alpha:1];
    
    [self createButton:_vDiskBtn withName:nameVDiskBtn atView:view];
    [self createButton:_bDiskBtn withName:nameBDiskBtn atView:view];
    [self createButton:_kDiskBtn withName:nameKDiskBtn atView:view];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        MainViewControllerVdisk *mainViewControllerVdisk = [[[MainViewControllerVdisk alloc] init] autorelease];
        [self.navigationController pushViewController:mainViewControllerVdisk animated:YES];
        
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
    MainViewControllerBdisk *mainViewControllerBdisk = [[[MainViewControllerBdisk alloc] init] autorelease];
    mainViewControllerBdisk.bdConnect = self.bdConnect;
    [self.navigationController pushViewController:mainViewControllerBdisk animated:YES];
}

- (void)loginDidCancel
{
    
}

- (void)loginFailedWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
