//
//  KdiskReaderViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-12.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "KdiskReaderViewController.h"

@interface KdiskReaderViewController ()

@end

@implementation KdiskReaderViewController

@synthesize metadata = _metadata;
@synthesize progressLabel = _progressLabel;
@synthesize progressView = _progressView;
@synthesize root = _root;
@synthesize userInfo = _userInfo;

- (void)dealloc {
    
    if (_downloadFileOp != nil) {
        
        [_downloadFileOp cancelOperation];
        [_downloadFileOp release];
        _downloadFileOp = nil;
    }
    
    [_metadata release];
    [_userInfo release];
    [_root release];
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
    CGFloat progress = 0.0f;
    _progressLabel.text = [NSString stringWithFormat:@"%.1f%%", progress*100.0f];
    
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
    
    if (_downloadFileOp != nil) {
        
        [_downloadFileOp cancelOperation];
        [_downloadFileOp release];
        _downloadFileOp = nil;
    }
    
    //Littlebox-XXOO 这里要改，去掉md5那一级，把整个download清掉
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/kdisk/%d/download/%@", documentsDirectoryPath,
                         _userInfo.userID,
                         _metadata.fileID];
    
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
    NSString *tmpDirectory = [NSString stringWithFormat:@"%@/kdisk/%d/download/%@", documentsDirectoryPath,
                                                                                    _userInfo.userID,
                                                                                    _metadata.fileID];
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, _metadata.name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:tmpPath]) {
        
        if ([fileManager createDirectoryAtPath:tmpDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            if (_downloadFileOp != nil) {
                
                [_downloadFileOp cancelOperation];
                [_downloadFileOp release];
                _downloadFileOp = nil;
            }
            
            KPFolderOperationItem *item = [[KPFolderOperationItem alloc] init];
            
            item.root = @"app_folder";
            NSArray *chunks = [_root componentsSeparatedByString: @"app_folder/"];
            item.path = [NSString stringWithFormat:@"%@/%@", (NSString *)[chunks objectAtIndex:([chunks count]-1)], _metadata.name];
            
            _downloadFileOp = [[KPDownloadFileOperation alloc] initWithDelegate:self operationItem:item];
            [_downloadFileOp executeOperation];
            
            [_clog startRecordTime];
            
            [item release];
            
            [_progressLabel setHidden:NO];
            [_progressView setHidden:NO];
            
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

#pragma mark - KPOperationDelegate

- (void)operation:(KPOperation *)operation success:(id)data
{
    if (_downloadFileOp == operation) {
        
        [_clog stopRecordTime];
        DDLogInfo(@"%@", _clog);
        
        //下载的文件临时存储路径，最后使用Move方法将该文件移走即操作快速又避免临时文件占用硬盘空间。
        NSString *localFilePath = data;
        NSLog(@"%@", [NSString stringWithFormat:@"download file success,local path:%@",localFilePath]);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *tmpDirectory = [NSString stringWithFormat:@"%@/kdisk/%d/download/%@", documentsDirectoryPath,
                                  _userInfo.userID,
                                  _metadata.fileID];
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, _metadata.name];
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager moveItemAtPath:localFilePath toPath:tmpPath error:nil]) {
            
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
        
        [_downloadFileOp release];
        _downloadFileOp = nil;
    }
}

- (void)operation:(KPOperation *)operation fail:(NSString *)errorMessage
{
    [_clog stopRecordTime];
    DDLogInfo(@"%@", _clog);
    
    NSLog(@"fail Message:%@",errorMessage);
    
    if ([errorMessage isEqualToString:@"The Internet connection appears to be offline."]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:[NSString stringWithFormat:@"请检查您的网络连接"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

- (void)operation:(KPOperation *)operation
    totalBytesWritten:(long long)totalBytesWritten
    totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    
    CGFloat progress = (totalBytesWritten*1.0) / totalBytesExpectedToWrite;
    _progressView.progress = progress;
    _progressLabel.text = [NSString stringWithFormat:@"%.1f%%", progress*100.0f];
}


@end
