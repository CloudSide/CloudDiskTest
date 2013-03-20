//
//  MainViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "MainViewControllerKdisk.h"

@interface MainViewControllerKdisk ()

@end

@implementation MainViewControllerKdisk

@synthesize authController = _authController;
@synthesize consumer = _consumer;
@synthesize path = _path;
@synthesize directoryInfo = _directoryInfo;
@synthesize userInfo = _userInfo;
@synthesize imagePickerController = _imagePickerController;
@synthesize hud = _hud;
@synthesize currentPath = _currentPath;
@synthesize deletePath = _deletePath;

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
    
    if (_getDirectoryOp != nil) {
        
        [_getDirectoryOp cancelOperation];
        [_getDirectoryOp release];
        _getDirectoryOp = nil;
    }
    
    if (_getUserInfoOp != nil) {
        
        [_getUserInfoOp cancelOperation];
        [_getUserInfoOp release];
        _getUserInfoOp = nil;
    }
    
    _hud.delegate = nil;
    [_hud release], _hud = nil;
    
    [_imagePickerController release];
    [_currentPath release];
    [_deletePath release];
    [_userInfo release];
    [_authController release];
    [_consumer release];
    [_directoryInfo release];
    
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
    
    [self.navigationItem setTitle:@"快盘"];
    
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
    
    if (_consumer == nil) {
        _consumer = [[KPConsumer alloc] initWithKey:kKPAppKey secret:kKPAppSecret];
    }
    
    _authController = [[KPAuthViewController alloc] initWithConsumer:_consumer];
    
    if (!_authController.isAlreadAuth) {

        [self.navigationController pushViewController:_authController animated:YES];
    
    } else {
    
        if (_getUserInfoOp != nil) {
            
            [_getUserInfoOp cancelOperation];
            [_getUserInfoOp release];
            _getUserInfoOp = nil;
        }
        
        _getUserInfoOp = [[KPGetUserInfoOperation alloc] initWithDelegate:self operationItem:nil];
        [_getUserInfoOp executeOperation];
        
        UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [activityView startAnimating];
        
        UIBarButtonItem *loadingView = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
        
        self.toolbarItems = [NSArray arrayWithObjects:loadingView,
                             [self.toolbarItems objectAtIndex:1],
                             [self.toolbarItems objectAtIndex:2], nil];
        
        [[self.toolbarItems objectAtIndex:0] setEnabled:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

#pragma mark - Toolbar and Navigationbar buttons

- (void)onSignOutButtonPressed:(id)sender {
    
    [_authController clearAuthInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onRefreshButtonPressed:(id)sender {
    
    if (_getDirectoryOp != nil) {
        
        [_getDirectoryOp cancelOperation];
        [_getDirectoryOp release];
        _getDirectoryOp = nil;
    }
    
    KPGetDirectoryOperationItem *item = [[KPGetDirectoryOperationItem alloc] init];
    
    if (_path == nil) {
        
        _path = @"";
        
    } else {
        
        NSArray *chunks = [_path componentsSeparatedByString: @"app_folder/"];
        item.path = (NSString *)[chunks objectAtIndex:([chunks count]-1)];
    }
    
    item.root = @"app_folder";
    
    _getDirectoryOp = [[KPGetDirectoryOperation alloc] initWithDelegate:self operationItem:item];
    [_getDirectoryOp executeOperation];
    
    [_clog startRecordTime];
    
    [item release];
    
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activityView startAnimating];
    
    UIBarButtonItem *loadingView = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:loadingView,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:NO];
}

- (void)onUploadButtonPressed:(id)sender {
    
    [self.navigationController presentModalViewController:self.imagePickerController animated:YES];
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
            
            self.deletePath = tmpPath;
            
            KPUploadFileOperationItem *item = [[KPUploadFileOperationItem alloc] init];
            
            item.root = @"app_folder";
            
            //要上传到的文件夹必须已经创建，即hejinbo123文件夹必须已经存在,并且必须携带文件名
            
            NSArray *chunks = [_path componentsSeparatedByString: @"app_folder/"];
            item.path = [NSString stringWithFormat:@"%@/%@",(NSString *)[chunks objectAtIndex:([chunks count]-1)], fileName];
            item.fileName = fileName;
            item.fileData = [NSData dataWithContentsOfFile:tmpPath];
            item.isOverwrite = YES;
            
            _uploadFileOp = [[KPUploadFileOperation alloc] initWithDelegate:self operationItem:item];
            [_uploadFileOp executeOperation];
            
            [_clog startRecordTime];
            
            [item release];
            
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


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[_directoryInfo files] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"MetadataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    KPFileInfo *metadata = [[_directoryInfo files] objectAtIndex:indexPath.row];
    
    cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.text = metadata.name;
    
    NSString *lastDateString = metadata.modifyTime;
    float fileSize = 0.0;
    if (metadata.size / 1024.0 / 1024.0 > 1) {
        
        fileSize = metadata.size / 1024.0 / 1024.0;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %.2fMB", lastDateString, fileSize];
        
    } else {
        fileSize = metadata.size / 1024.0;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %.2fKB", lastDateString, fileSize];
    }
    
    if ([metadata type] == kTypeFolder) {
        
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
            sectionTitle = _directoryInfo.path;
            self.currentPath = _directoryInfo.path;
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
    
    KPFileInfo *metadata = [[_directoryInfo files] objectAtIndex:indexPath.row];
    
    if ([metadata type] == kTypeFolder) {
        
        MainViewControllerKdisk *mainViewController = [[[MainViewControllerKdisk alloc] initWithStyle:UITableViewStylePlain] autorelease];
        mainViewController.path = [[[NSString alloc] initWithFormat:@"%@/%@", _path, metadata.name] autorelease];
        
        [self.navigationController pushViewController:mainViewController animated:YES];
        
    } else {
        
        KdiskReaderViewController *readerViewController = [[[KdiskReaderViewController alloc] init] autorelease];
        
        readerViewController.metadata = metadata;
        readerViewController.root = _path;
        readerViewController.userInfo = _userInfo;
        
        [self.navigationController pushViewController:readerViewController animated:YES];
    }
}

#pragma mark - KPOperationDelegate

- (void)operation:(KPOperation *)operation success:(id)data
{
    if (_getDirectoryOp == operation) {
        
        [_clog stopRecordTime];
        DDLogInfo(@"%@", _clog);
        
        _directoryInfo = data;
        [_directoryInfo retain];
        
        [_getDirectoryOp release];
        _getDirectoryOp = nil;
    }
    else if (_uploadFileOp == operation) {
        
        [_clog stopRecordTime];
        DDLogInfo(@"%@", _clog);
        
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"上传成功！";
        _hud.detailsLabelText = nil;
        
        [_hud hide:YES afterDelay:1];
        [_hud show:NO];
        
        [self onRefreshButtonPressed:nil];
        
        [_uploadFileOp release];
        _uploadFileOp = nil;
        
        //delete tmp file
        [[NSFileManager defaultManager] removeItemAtPath:_deletePath error:nil];
        
        
    }
    else if (_getUserInfoOp == operation) {
        
        _userInfo = data;
        [_userInfo retain];
        
        [_getUserInfoOp release];
        _getUserInfoOp = nil;
        
        [self onRefreshButtonPressed:nil];
    }
    
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:YES];
    
    [self.tableView reloadData];
}

- (void)operation:(KPOperation *)operation fail:(NSString *)errorMessage
{
    if (_uploadFileOp == operation) {
        
        [_clog stopRecordTime];
        DDLogInfo(@"%@", _clog);
        
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"上传失败...";
        _hud.detailsLabelText = nil;
        
        [_hud hide:YES afterDelay:1];
        [_hud show:NO];
        
        //delete tmp file
        [[NSFileManager defaultManager] removeItemAtPath:_deletePath error:nil];
        
    } else if (_getDirectoryOp == operation) {
        
        [_clog stopRecordTime];
        DDLogInfo(@"%@", _clog);
    }
    
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
    
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:YES];
}

- (void)operation:(KPOperation *)operation
totalBytesWritten:(long long)totalBytesWritten
totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    
    CGFloat progress = (totalBytesWritten*1.0) / totalBytesExpectedToWrite;
    
    _hud.progress = progress;
}

@end
