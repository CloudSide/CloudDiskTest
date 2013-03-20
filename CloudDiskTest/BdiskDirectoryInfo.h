//
//  BdiskDirectoryInfo.h
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-15.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BdiskFileInfo.h"

@interface BdiskDirectoryInfo : NSObject {
    
}

@property(nonatomic, retain) NSString       *root;
@property(nonatomic, retain) BdiskFileInfo  *fileInfo;
@property(nonatomic, retain) NSMutableArray *files;

- (id)initWithArray:(NSDictionary *)resultDict;

@end
