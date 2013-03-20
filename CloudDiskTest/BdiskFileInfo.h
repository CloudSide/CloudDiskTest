//
//  BdiskFileInfo.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-15.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BdiskFileInfo : NSObject {
    
}

@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileMd5;
@property (nonatomic, retain) NSDate *modifyTime;

@property (nonatomic) UInt64 fileSize;
@property (nonatomic) BOOL isDirectory;

@end
