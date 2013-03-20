//
//  MainViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "MainViewControllerVdisk.h"

@interface MainViewControllerVdisk ()

@end

@implementation MainViewControllerVdisk

@synthesize path = _path;
@synthesize imagePickerController = _imagePickerController;
@synthesize hud = _hud;
@synthesize currentPath = _currentPath;

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
    
    [_vdiskRestClient cancelAllRequests];
    [_vdiskRestClient setDelegate:nil];
    [_vdiskRestClient release];
    
    [_metadata release];
    [_path release];
    
    [_imagePickerController release];
    
    _hud.delegate = nil;
    [_hud release], _hud = nil;
    
    [_currentPath release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        _vdiskRestClient = [[VdiskRestClient alloc] initWithSession:[VdiskSession sharedSession]];
        [_vdiskRestClient setDelegate:self];
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
    
    [self.navigationItem setTitle:@"微盘"];
    
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
    
    [[VdiskSession sharedSession] unlink];
}

- (void)onRefreshButtonPressed:(id)sender {
    
    if (_path == nil) {
        
        _path = @"/";
    }
    
    if ([[VdiskSession sharedSession] isLinked] && ![[VdiskSession sharedSession] isExpired]) {
        
        if (_metadata && _metadata.hash) {
            
            [_vdiskRestClient loadMetadata:_path withHash:_metadata.hash];
            
        } else {
         
            [_vdiskRestClient loadMetadata:_path];
        }
        
        UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [activityView startAnimating];
        
        UIBarButtonItem *loadingView = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
        
        self.toolbarItems = [NSArray arrayWithObjects:loadingView,
                             [self.toolbarItems objectAtIndex:1],
                             [self.toolbarItems objectAtIndex:2], nil];
        
        [[self.toolbarItems objectAtIndex:0] setEnabled:NO];
    
    } else {
        
        [[VdiskSession sharedSession] linkWithSessionType:kVdiskSessionTypeDefault];
    }
}

- (void)onUploadButtonPressed:(id)sender {
    
    [self.navigationController presentModalViewController:self.imagePickerController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_metadata.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MetadataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    VdiskMetadata *metadata = (VdiskMetadata *)[_metadata.contents objectAtIndex:indexPath.row];
    
    cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-MM-dd HH:mm:ss"];
    NSString *lastDateString = [formatter stringFromDate:metadata.lastModifiedDate];
    [formatter release];
    
    cell.textLabel.text = metadata.filename;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", lastDateString, metadata.humanReadableSize];
    
    if ([metadata isDirectory]) {
        
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
            sectionTitle = _metadata.path;
            self.currentPath = _metadata.path;
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
    
    VdiskMetadata *metadata = (VdiskMetadata *)[_metadata.contents objectAtIndex:indexPath.row];
    
    if ([metadata isDirectory]) {
        
        MainViewControllerVdisk *mainViewController = [[[MainViewControllerVdisk alloc] initWithStyle:UITableViewStylePlain] autorelease];
        mainViewController.path = metadata.path;
        [self.navigationController pushViewController:mainViewController animated:YES];
        
    } else {
        
        VdiskReaderViewController *readerViewController = [[[VdiskReaderViewController alloc] init] autorelease];
        
        readerViewController.metadata = metadata;
        
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
            
            NSString *destPath = [NSString stringWithFormat:@"%@/", _currentPath];
            [_vdiskRestClient uploadFile:fileName toPath:destPath withParentRev:nil fromPath:tmpPath];
            
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


#pragma mark - VdiskRestClientDelegate

- (void)restClient:(VdiskRestClient *)client loadedMetadata:(VdiskMetadata *)metadata {
    
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:YES];
    
    if (_metadata != nil) {
        
        [_metadata release], _metadata = nil;
    }
    
    _metadata = [metadata retain];
    
    [self.tableView reloadData];
}

- (void)restClient:(VdiskRestClient *)client metadataUnchangedAtPath:(NSString *)path {
    
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:YES];
    
    [self.tableView reloadData];
}

- (void)restClient:(VdiskRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    
    UIBarButtonItem *refreshBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshButtonPressed:)] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,
                         [self.toolbarItems objectAtIndex:1],
                         [self.toolbarItems objectAtIndex:2], nil];
    
    [[self.toolbarItems objectAtIndex:0] setEnabled:YES];
    
    
    //Littlebox-XXOO 这部分以后注释掉
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR!!" message:[NSString stringWithFormat:@"Error!\n----------------\nerrno:%d\n%@\%@\n----------------", error.code, error.localizedDescription, [error userInfo]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
    
    if (error.code==1) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:[NSString stringWithFormat:@"请检查您的网络连接"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

- (void)restClient:(VdiskRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(VdiskMetadata *)metadata {
    
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = @"上传成功！";
    _hud.detailsLabelText = nil;
    
    [_hud hide:YES afterDelay:1];
    [_hud show:NO];
    
    [self onRefreshButtonPressed:nil];
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
}

- (void)restClient:(VdiskRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath {
    
    _hud.progress = progress;
}

- (void)restClient:(VdiskRestClient *)client uploadFileFailedWithError:(NSError *)error {
    
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = @"上传失败...";
    _hud.detailsLabelText = nil;
    
    [_hud hide:YES afterDelay:1];
    [_hud show:NO];
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:[error.userInfo objectForKey:@"sourcePath"] error:nil];
}



@end
