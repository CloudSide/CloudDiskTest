//
//  MainViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "MainViewControllerBdisk.h"

#import "BdiskReaderViewController.h"

@interface MainViewControllerBdisk ()

@end

@implementation MainViewControllerBdisk


@synthesize bdConnect = _bdConnect;
@synthesize path = _path;
@synthesize bDiskDirectoryInfo = _bDiskDirectoryInfo;
@synthesize imagePickerController = _imagePickerController;
@synthesize hud = _hud;
@synthesize currentPath = _currentPath;
@synthesize deletePath = _deletePath;

@synthesize request = _request;

- (UIImagePickerController *)imagePickerController {
    
    if (_imagePickerController == nil) {
        
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    return _imagePickerController;
}

- (void)dealloc {
    
    if (_request != nil && ![_request isFinished]) {
        
        [_request cancel];
        [_request setDelegate:nil];
        [_request setDownloadProgressDelegate:nil];
    }
    [_request release];
    
    [_bdConnect release];
    [_path release];
    [_bDiskDirectoryInfo release];
    
    [_imagePickerController release];
    
    _hud.delegate = nil;
    [_hud release], _hud = nil;
    
    [_currentPath release];
    [_deletePath release];
    
    [_clog release], _clog = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        _clog = [[CLog alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil] autorelease];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"注销"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(onSignOutButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBtn];
    [rightBtn release];
    
    [self.navigationItem setTitle:@"百度云"];
    
    // 工具条按钮
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    UIBarButtonItem *upLoadBtn = [[[UIBarButtonItem alloc] initWithTitle:@"上传"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(onUploadButtonPressed:)] autorelease];
    
    UIBarButtonItem *spaceHolder = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:self
                                                                                  action:nil] autorelease];
    
    // 工具条
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn, spaceHolder, upLoadBtn, nil];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self onRefreshButtonPressed:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [super viewWillAppear:animated];
}

#pragma mark - Toolbar and Navigationbar buttons

- (void)onSignOutButtonPressed:(id)sender {
    
    [_bdConnect currentUserLogout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onRefreshButtonPressed:(id)sender {
    
    if (_path == nil) {
        
        _path = @"/apps/CloudDisk";
    }
    
    // Clog
    
    [self getDirectoryInfo:_path];
    
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activityView startAnimating];
    
    UIBarButtonItem *loadingView = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:loadingView,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:NO];
}

- (void)getDirectoryInfo:(NSString *)path {
    
    NSString *access_token = [BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken;
    
    NSString *requestText = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/file?method=list&access_token=%@&path=%@", access_token, path];
    
    NSString *httpMethodText = @"GET";
    
    [self.bdConnect apiRequestWithUrl:requestText httpMethod:httpMethodText params:nil andDelegate:self];
    
    [_clog startRecordTime];
}

- (void)onUploadButtonPressed:(id)sender {
    
    [self.navigationController presentModalViewController:self.imagePickerController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_bDiskDirectoryInfo.files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MetadataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    BdiskFileInfo *metadata = [_bDiskDirectoryInfo.files objectAtIndex:indexPath.row];
    
    cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.text = metadata.fileName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-MM-dd HH:mm:ss"];
    NSString *lastDateString = [formatter stringFromDate:metadata.modifyTime];
    [formatter release];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", lastDateString, [VdiskRestClient humanReadableSize:metadata.fileSize]];
    
    if (metadata.isDirectory) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setUserInteractionEnabled:YES];
        cell.detailTextLabel.text = lastDateString;
        
    } else {
        
        [cell setUserInteractionEnabled:YES];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle;
    
    switch (section) {
            
        case 0:
        {
            sectionTitle = _bDiskDirectoryInfo.root;
            self.currentPath = _bDiskDirectoryInfo.root;
            break;
        }
        default:
            sectionTitle = @"";
            break;
    }
    
    return sectionTitle;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BdiskFileInfo *metadata = (BdiskFileInfo *)[_bDiskDirectoryInfo.files objectAtIndex:indexPath.row];
    
    if (metadata.isDirectory) {
        
        MainViewControllerBdisk *mainViewController = [[[MainViewControllerBdisk alloc] initWithStyle:UITableViewStylePlain] autorelease];
        mainViewController.path = metadata.filePath;
        mainViewController.bdConnect = self.bdConnect;
        [self.navigationController pushViewController:mainViewController animated:YES];
        
    } else {
        
        BdiskReaderViewController *readerViewController = [[[BdiskReaderViewController alloc] init] autorelease];
        
        readerViewController.metadata = metadata;
        readerViewController.bdConnect = self.bdConnect;
        
        [self.navigationController pushViewController:readerViewController animated:YES];
    }

}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *theAsset) {
        
        NSString *fileName = [[theAsset defaultRepresentation] filename];
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        [emptyData release];
        
        NSFileHandle *theFileHandle = [NSFileHandle fileHandleForWritingAtPath:tmpPath];
        
        unsigned long long offset = 0;
        unsigned long long length;
        
        long long theItemSize = [[theAsset defaultRepresentation] size];
        
        long long bufferLength = 16384;
        
        if (theItemSize > 262144) {
            
            bufferLength = 262144;
            
        } else if (theItemSize > 65536) {
            
            bufferLength = 65536;
        }
        
        NSError *err = nil;
        uint8_t *buffer = (uint8_t *)malloc(bufferLength);
        
        while ((length = [[theAsset defaultRepresentation] getBytes:buffer fromOffset:offset length:bufferLength error:&err]) > 0 && err == nil) {
            
            NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
            [theFileHandle writeData:data];
            [data release];
            offset += length;
        }
        
        free(buffer);
        
        [theFileHandle closeFile];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            
            if (_request != nil && ![_request isFinished]) {
                [_request cancel];
            }
            
            self.deletePath = tmpPath;
            
            NSString *destPath = [NSString stringWithFormat:@"%@%@", _currentPath, fileName];
            NSString *access_token = [BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken;
            NSString *requestText = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/file?method=upload&path=%@&access_token=%@", destPath, access_token];
            requestText = [requestText stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
            
            NSString *httpMethodText = @"POST";
            
            NSURL *requestUrl = [NSURL URLWithString:requestText];
            _request = [[ASIFormDataRequest requestWithURL:requestUrl] retain];
            [_request setRequestMethod:httpMethodText];
            
            [_request setFile:tmpPath forKey:@"file"];
            [_request setDelegate:self];
            [_request setUploadProgressDelegate:self];
            
            [_request startAsynchronous];
            
            [_clog startRecordTime];
            
            
            // loading....
            self.hud = [[[MBProgressHUD alloc] initWithView:self.navigationController.view] autorelease];
            [self.navigationController.view addSubview:_hud];
            _hud.dimBackground = NO;
            _hud.delegate = self;
            _hud.labelText = @"上传中...";
            _hud.detailsLabelText = nil;
            _hud.mode = MBProgressHUDModeDeterminate;
            [_hud setAnimationType:MBProgressHUDAnimationFade];
            [_hud hide:NO];
            [_hud show:YES];
        }
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *theError) {
        
        NSLog(@"%@", [theError localizedDescription]);
    };
    
    
    NSURL *referenceURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:referenceURL resultBlock:resultblock failureBlock:failureblock];
    [assetslibrary release];
    
    [picker dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissModalViewControllerAnimated:YES];
}


#pragma mark - BaiduAPIRequestDelegate

- (void)apiRequestDidFinishLoadWithResult:(id)result
{
    [_clog stopRecordTime];
    DDLogInfo(@"%@", _clog);
    
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:YES];
    
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *resultDic = (NSDictionary *)result;
        _bDiskDirectoryInfo = [[BdiskDirectoryInfo alloc] initWithArray:resultDic];
    }
    
    [self.tableView reloadData];
}

- (void)apiRequestDidFailLoadWithError:(NSError*)error
{
    [_clog stopRecordTime];
    DDLogInfo(@"%@", _clog);
    
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:YES];
    
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"授权提示" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
    [alertView show];
    
    return;
}



#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [_clog stopRecordTime];
    DDLogInfo(@"%@", _clog);
    
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = @"上传成功！";
    _hud.detailsLabelText = nil;
    
    [_hud hide:YES afterDelay:1];
    [_hud show:NO];
    
    [self onRefreshButtonPressed:nil];
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:_deletePath error:nil];

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_clog stopRecordTime];
    DDLogInfo(@"%@", _clog);
    
    NSError *error = [request error];
    NSLog(@"%@", error);
    
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = @"上传失败...";
    _hud.detailsLabelText = nil;
    
    [_hud hide:YES afterDelay:1];
    [_hud show:NO];
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:_deletePath error:nil];
}

- (void)setProgress:(float)newProgress {

    _hud.progress = newProgress;
}


@end
