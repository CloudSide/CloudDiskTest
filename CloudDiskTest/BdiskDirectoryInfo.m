//
//  BdiskDirectoryInfo.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-15.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "BdiskDirectoryInfo.h"

@implementation BdiskDirectoryInfo

@synthesize root = _root;
@synthesize fileInfo = _fileInfo;
@synthesize files = _files;

- (void)dealloc {
    
    [_root release];
    [_fileInfo release];
    [_files release];
    
    [super dealloc];
}

- (id)initWithArray:(NSDictionary *)resultDict {
    
    if ((self = [super init])) {
        
        _files = [[NSMutableArray alloc] init];

        NSArray *dictArray = [resultDict objectForKey:@"list"];
        
        for (int i=0; i<[dictArray count]; i++) {
            
            NSDictionary *dict = [dictArray objectAtIndex:i];
            BdiskFileInfo *fileInfo = [[[BdiskFileInfo alloc] init] autorelease];
            
            fileInfo.isDirectory = [[dict objectForKey:@"isdir"] boolValue];
            fileInfo.fileMd5 = (NSString *)[dict objectForKey:@"md5"];
            fileInfo.filePath = (NSString *)[dict objectForKey:@"path"];
            fileInfo.fileSize = [[dict objectForKey:@"size"] longLongValue];
            fileInfo.modifyTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"mtime"] floatValue]];
            
            NSArray *chunks = [fileInfo.filePath componentsSeparatedByString: @"/"];
            fileInfo.fileName = (NSString *)[chunks objectAtIndex:([chunks count]-1)];
            
            chunks = [fileInfo.filePath componentsSeparatedByString:fileInfo.fileName];
            self.root = (NSString *)[chunks objectAtIndex:0];
            
            [self.files insertObject:fileInfo atIndex:i];
            
//                NSLog(@"%d\n%@\n%@\n%d\n%@", fileInfo.isDirectory, fileInfo.fileMd5, fileInfo.filePath, fileInfo.fileSize, fileInfo.fileName);
        }
    }

    return self;
}

@end
