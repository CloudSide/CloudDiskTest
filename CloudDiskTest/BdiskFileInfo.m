//
//  BdiskFileInfo.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-15.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "BdiskFileInfo.h"

@implementation BdiskFileInfo

@synthesize fileMd5 = _fileMd5;
@synthesize filePath = _filePath;
@synthesize fileName = _fileName;
@synthesize fileSize = _fileSize;
@synthesize isDirectory = _isDirectory;
@synthesize modifyTime = _modifyTime;

- (void)dealloc {
    
    [_fileMd5 release];
    [_filePath release];
    [_fileName release];
    [_modifyTime release];
    
    [super dealloc];
}

- (id)init {
    
    if (self = [super init]) {
        
        return self;
    }
    
    return nil;
}

@end
