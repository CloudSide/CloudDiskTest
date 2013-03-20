//
//  VdiskReaderViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-12.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "VdiskReaderViewController.h"

@interface VdiskReaderViewController ()

@end

@implementation VdiskReaderViewController

@synthesize metadata = _metadata;
@synthesize progressLabel = _progressLabel;
@synthesize progressView = _progressView;

- (void)dealloc {
    
    [_metadata release];
    
    [_vdiskRestClient cancelAllRequests];
    [_vdiskRestClient setDelegate:nil];
    [_vdiskRestClient release];
    
    [_progressView release];
    [_progressLabel release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _vdiskRestClient = [[VdiskRestClient alloc] initWithSession:[VdiskSession sharedSession]];
        [_vdiskRestClient setDelegate:self];
        
        _isExecuting = NO;
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

    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self downloadFile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancelFileLoad:(id)sender {
    
    [_vdiskRestClient cancelFileLoad:_metadata.path];
    
    //Littlebox-XXOO 这里要改，去掉md5那一级，把整个download清掉
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/vdisk/%@/download/%@", documentsDirectoryPath,
                         [[VdiskSession sharedSession] userID],
                         _metadata.fileMd5];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager removeItemAtPath:tmpDirectory error:NULL]) {
        
        _isExecuting = NO;
        
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
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/vdisk/%@/download/%@", documentsDirectoryPath,
                                                                                    [[VdiskSession sharedSession] userID],
                                                                                    _metadata.fileMd5];
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, _metadata.filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:tmpPath]) {
        
        if ([fileManager createDirectoryAtPath:tmpDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            [_vdiskRestClient loadFile:_metadata.path intoPath:tmpPath];
            _isExecuting = YES;
            
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

#pragma mark - VdiskRestClientDelegate

- (void)restClient:(VdiskRestClient *)client loadedFile:(NSString *)destPath {
    
    _isExecuting = NO;
    
    [_progressLabel setHidden:YES];
    [_progressView setHidden:YES];
    
    //webview show
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    
    NSURL *targetURL = [NSURL fileURLWithPath:destPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    [self.view setNeedsDisplay];
}

- (void)restClient:(VdiskRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
    
    [_progressLabel setHidden:NO];
    [_progressView setHidden:NO];
    
    [_progressView setProgress:progress];
    _progressLabel.text = [NSString stringWithFormat:@"%.1f%%", progress*100.0f];
}


- (void)restClient:(VdiskRestClient *)client loadFileFailedWithError:(NSError *)error {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR!!" message:[NSString stringWithFormat:@"Error!\n----------------\nerrno:%d\n%@\%@\n----------------", error.code, error.localizedDescription, [error userInfo]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
    
    _isExecuting = NO;
}


- (BOOL)restClient:(VdiskRestClient *)client loadedFileRealDownloadURL:(NSURL *)realDownloadURL metadata:(VdiskMetadata *)metadata {
    
    return YES;
    
    _isExecuting = NO;
    
    //Get the real download url
    NSLog(@"%@\n%@", realDownloadURL, metadata);
    
    /*
     [[UIApplication sharedApplication] openURL:realDownloadURL];
     return NO;
     */
    
    //if return no, will cancel the download, only get the real download url and metadata
    return NO;
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

@end
