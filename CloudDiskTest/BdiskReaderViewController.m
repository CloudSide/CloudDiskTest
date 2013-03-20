//
//  BdiskReaderViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-12.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "BdiskReaderViewController.h"

@interface BdiskReaderViewController ()

@end

@implementation BdiskReaderViewController

@synthesize bdConnect = _bdConnect;
@synthesize metadata = _metadata;
@synthesize progressLabel = _progressLabel;
@synthesize progressView = _progressView;
@synthesize request = _request;

- (void)dealloc {
    
    if (_request != nil && ![_request isFinished]) {
        
        [_request cancel];
        [_request setDelegate:nil];
        [_request setDownloadProgressDelegate:nil];
    }
    [_request release];
    
    [_bdConnect release];
    [_metadata release];
    
    [_progressView release];
    [_progressLabel release];
    
    [_clog release], _clog = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _isExecuting = NO;
        _progress = 0.0f;
        
        _clog = [[CLog alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10,
                                                                     self.view.frame.size.height/2-70,
                                                                     self.view.frame.size.width-20,
                                                                     10)];
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20,
                                                               self.view.frame.size.height/2+10-60,
                                                               100,
                                                               25)];
    
    [self.view addSubview:_progressView];
    [self.view addSubview:_progressLabel];
    
    [_progressLabel setHidden:YES];
    [_progressView setHidden:YES];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(onCancelFileLoad:)];
    [self.navigationItem setRightBarButtonItem:rightBtn];
    [rightBtn release];

    [self.navigationController setToolbarHidden:YES];
    
    [self downloadFile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancelFileLoad:(id)sender {
    
    if (_request != nil && ![_request isFinished]) {
        
        [_request cancel];
        [_request setDelegate:nil];
        [_request setDownloadProgressDelegate:nil];
    }

    
    //Littlebox-XXOO 这里要改，去掉md5那一级，把整个download清掉
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk/0/download/%@", documentsDirectoryPath, _metadata.fileMd5];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager removeItemAtPath:tmpDirectory error:NULL]) {
        
        [_progressLabel setHidden:YES];
        [_progressView setHidden:YES];
        
        [_progressView setProgress:0.0f];
        [_progressLabel setText:@"0.0%"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"缓存清理成功！"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

- (void)downloadFile {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk/0/download/%@", documentsDirectoryPath, _metadata.fileMd5];
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, _metadata.fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:tmpPath]) {
        
        if ([fileManager createDirectoryAtPath:tmpDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            NSString *access_token = [BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken;
            
            NSString *requestText = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/file?method=download&access_token=%@&path=%@", access_token, _metadata.filePath];
            
            NSString *httpMethodText = @"GET";
            
            if (_request != nil && ![_request isFinished]) {
                [_request cancel];
            }
            
            requestText = [requestText stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
            NSURL *requestUrl = [NSURL URLWithString:requestText];
            
            _request = [[ASIHTTPRequest requestWithURL:requestUrl] retain];
            
            [_request setDownloadDestinationPath:tmpPath];
            [_request setRequestMethod:httpMethodText];
            
            [_request setDelegate:self];
            [_request setDownloadProgressDelegate:self];
            [_request startAsynchronous];
            
            [_clog startRecordTime];
            
            [_progressView setHidden:NO];
            [_progressLabel setHidden:NO];
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件下载失败！"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
        }
        
    } else {
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        webView.delegate = self;
        webView.scalesPageToFit = YES;
        
        NSURL *targetURL = [NSURL fileURLWithPath:tmpPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        
        [webView loadRequest:request];
        
        [self.view addSubview:webView];
        [webView release];
        
        [self.view setNeedsDisplay];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
     
    //NSLog(@"%@", error);
    //NSLog(@"%@", error.userInfo);
    
    if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Frame load interrupted"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件格式不支持！"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];

    }
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    [_clog stopRecordTime];
    DDLogInfo(@"%@", _clog);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/bdisk/0/download/%@", documentsDirectoryPath, _metadata.fileMd5];
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, _metadata.fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:tmpPath]) {

        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        webView.delegate = self;
        webView.scalesPageToFit = YES;
        
        NSURL *targetURL = [NSURL fileURLWithPath:tmpPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        
        [webView loadRequest:request];
        
        [self.view addSubview:webView];
        [webView release];
        
        [self.view setNeedsDisplay];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_clog stopRecordTime];
    DDLogInfo(@"%@", _clog);
    
    NSError *error = [request error];
    NSLog(@"%@", error);
}

- (void)setProgress:(float)newProgress {
    
    _progressView.progress = newProgress;
    _progressLabel.text = [NSString stringWithFormat:@"%.1f%%", newProgress*100.0f];

}

@end
