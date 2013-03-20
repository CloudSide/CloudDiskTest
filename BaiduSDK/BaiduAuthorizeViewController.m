//
//  BaiduAuthorizeViewController.m
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//
#import "BaiduAuthorizeViewController.h"
#import "BaiduUtility.h"
#import "BaiduMacroDef.h"
#import "BaiduConfig.h"
#import "BaiduError.h"
#import "BaiduUserSessionManager.h"
#import <QuartzCore/QuartzCore.h>

#define ACTIVITYVIEW_TAG  101

@interface BaiduAuthorizeViewController()

@property (nonatomic,retain)UIWebView *webView;
@property (nonatomic,retain)UIView *indicatorView;

- (NSURL *)oauthRequestURLWithScope:(NSString *)scope;

@end

@implementation BaiduAuthorizeViewController
@synthesize webView = _webView;
@synthesize scope = _scope;
@synthesize delegate = _delegate;
@synthesize indicatorView = _indicatorView;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    // Custom initialization
    [super loadView];
    
    // add the panel view
    _panelView = [[UIView alloc] initWithFrame:CGRectZero];
    [_panelView setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0f]];
    //[_panelView setBackgroundColor:[UIColor clearColor]];
    [[_panelView layer] setMasksToBounds:NO]; // very important
    [[_panelView layer] setCornerRadius:4.0];
    CGPoint centerPanelView = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [_panelView setCenter:centerPanelView];
    [_panelView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_panelView];

    
    self.webView = [[[UIWebView alloc] init] autorelease];
    
    if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        self.webView.frame = CGRectMake(10, 30, self.view.frame.size.height-20, self.view.frame.size.width-20-20);
    } else{
        self.webView.frame = CGRectMake(10, 30, self.view.frame.size.width-20, self.view.frame.size.height-20-20);
    }
    
    for (id view in self.webView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView*)view;
            scrollView.scrollEnabled = YES;
        }
    }
    
    [self.view addSubview:self.webView];
    
    self.indicatorView = [[[UIView alloc] init] autorelease];
    self.indicatorView.backgroundColor = [UIColor blackColor];
    self.indicatorView.bounds = CGRectMake(0, 0, 100, 100);
    self.indicatorView.center = self.webView.center;
    self.indicatorView.layer.cornerRadius = 8;
    self.indicatorView.layer.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
    [self.webView addSubview:self.indicatorView];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(50, 40);
    activityView.tag = ACTIVITYVIEW_TAG;
    [self.indicatorView addSubview:activityView];
    [activityView release];
    
    UILabel *loadingLable = [[UILabel alloc] initWithFrame:CGRectMake(0,60,100,30)];
    loadingLable.text = [NSString stringWithFormat:@"加载中"];
    loadingLable.backgroundColor = [UIColor clearColor];
    loadingLable.textColor = [UIColor whiteColor];
    loadingLable.textAlignment = UITextAlignmentCenter;
    [self.indicatorView addSubview:loadingLable];
    [loadingLable release];
    
    self.indicatorView.hidden = YES;
    
    //
    UIImage *closeImage = [UIImage imageNamed:@"SinaWeibo.bundle/images/close.png"];
    UIColor *color = [UIColor colorWithRed:167.0/255 green:184.0/255 blue:216.0/255 alpha:1];
    _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_closeButton setImage:closeImage forState:UIControlStateNormal];
    [_closeButton setTitleColor:color forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(onCloseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _closeButton.showsTouchWhenHighlighted = YES;
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_closeButton sizeToFit];
    _closeButton.frame = CGRectMake(0, 20, 29, 29);
    [self.view addSubview:_closeButton];
    
    NSURL *url = [self oauthRequestURLWithScope:self.scope];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    [self.webView loadRequest:request];
    self.webView.delegate = self;
}

- (void)onCloseButtonTouched:(id)sender {
    
    [self hide:YES];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userDidCancel)]) {
        
        [self.delegate userDidCancel];
    }
}

- (void)hide:(BOOL)animated {
    
	if (animated) {
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideAndCleanUp)];
		[self.view setAlpha:0];
		[UIView commitAnimations];
	}
    
    [self.view removeFromSuperview];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
    self.indicatorView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)setSubViewOrientationChange
{
    if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
		self.webView.frame = CGRectMake(10, 30, self.view.frame.size.height-20, self.view.frame.size.width-20-20);
	} else{
        self.webView.frame = CGRectMake(10, 30, self.view.frame.size.width-20, self.view.frame.size.height-20-20);
    }
    self.indicatorView.center = self.webView.center;
}

#pragma mark - UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    BDLog(@"auth url:%@",url);
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [BaiduUtility parseURLParams:query];
    NSString *errorReason = [params objectForKey:@"error"];
    NSString *q = [url absoluteString];
    if( errorReason != nil && [q hasPrefix:BDAUTHORIZE_REDIRECTURI]) {
        if ([errorReason isEqualToString:@"access_denied"]) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userDidCancel)]) {
                [self.delegate userDidCancel];
            }
        } else {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userDidFailWithError:)]) {
                BaiduError *error = [BaiduError errorWithOAuthResult:params];
                [self.delegate userDidFailWithError:error];
            }
        }
        [self performSelector:@selector(close)];

        return NO;
    }
    
    NSString *accessToken = [params objectForKey:@"access_token"];
    if (nil != accessToken) {
        [[BaiduUserSessionManager shareUserSessionManager].currentUserSession saveUserSessionInfo:params];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userDidFinishSuccess)]) {
            [self.delegate userDidFinishSuccess];
        }
        [self performSelector:@selector(close)];
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)/*点击链接*/{
        NSString *q = [url absoluteString];
        if (![q hasPrefix:BDAUTHORIZE_HOSTURL]) {
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.indicatorView.hidden = NO;
    UIActivityIndicatorView *actView = (UIActivityIndicatorView *)[self.indicatorView viewWithTag:ACTIVITYVIEW_TAG];
    [actView startAnimating];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
                                                      \
                                                      var meta = document.getElementsByTagName('meta');                                                                              \
                                                      \
                                                      for(var i=0; i<meta.length; i++){                                                                                              \
                                                          \
                                                          if (meta[i].getAttribute('name') == 'viewport') {                                                                          \
                                                              \
                                                              meta[i].setAttribute('content', 'width=%@, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no');       \
                                                              break;                                                                                                                 \
                                                          }                                                                                                                          \
                                                          \
                                                      }", @"300"]];
    
    
    self.indicatorView.hidden = YES;
    UIActivityIndicatorView *actView = (UIActivityIndicatorView *)[self.indicatorView viewWithTag:ACTIVITYVIEW_TAG];
    [actView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userDidFailWithError:)]) {
            [self performSelector:@selector(close)];
            [self.delegate userDidFailWithError:error];
        }
    }
}

- (NSURL *)oauthRequestURLWithScope:(NSString *)scope
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[BaiduConfig shareConfig].apiKey,@"client_id",
                                   scope,@"scope",
                                   BDAUTHORIZE_REDIRECTURI,@"redirect_uri",
                                   @"token",@"response_type",
                                   @"mobile",@"display",nil];
    
    return [BaiduUtility generateURL:BDAUTHORIZE_HOSTURL params:params];
}

- (void)updateSubviewOrientation 
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_webView stringByEvaluatingJavaScriptFromString:
         @"document.body.setAttribute('orientation', 90);"];
    } else {
        [_webView stringByEvaluatingJavaScriptFromString:
         @"document.body.removeAttribute('orientation');"];
    }
}

- (void)dealloc
{
    [_closeButton release], _closeButton = nil;
    [_panelView release], _panelView = nil;
    
    self.scope = nil;
    [super dealloc];
}
@end
