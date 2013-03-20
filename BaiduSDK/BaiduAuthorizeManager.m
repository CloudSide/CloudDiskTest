//
//  BaiduAuthorizeManager.m
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#import "BaiduAuthorizeManager.h"
#import "BaiduDelegate.h"

static BaiduAuthorizeManager* authorizeManager = nil;

@interface BaiduAuthorizeManager()
@property (nonatomic,assign)id<BaiduAuthorizeDelegate> delegate;
@end

@implementation BaiduAuthorizeManager
@synthesize delegate = _delegate;

+ (BaiduAuthorizeManager*)shareAuthorizeManager
{
    if (authorizeManager == nil) {
        authorizeManager = [[BaiduAuthorizeManager alloc] init];
    }
    
    return authorizeManager;
}

+ (void)destroyAuthorizeManager
{
    if (authorizeManager != nil) {
        [authorizeManager release];
        authorizeManager = nil;
    }
}

- (void)authorizeToOpenWebPageWithScope:(NSString*)scope andDelegate:(id<BaiduAuthorizeDelegate>)delegate
{
    if (scope == nil) {
        scope = [NSString stringWithFormat:@""];
    }
    
    self.delegate = delegate;
    
    BaiduAuthorizeViewController *controller = [[BaiduAuthorizeViewController alloc] init];
    controller.delegate = self;
    controller.scope = scope;
    [controller show];
}

- (void)authorizeToProcessSSOWithScope:(NSString*)scope andDelegate:(id<BaiduAuthorizeDelegate>)delegate
{
    
}

- (BOOL)canProcessSSO
{
    return NO;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginDidSuccess)]) {
        [self.delegate loginDidSuccess];
    }
    return YES;
}

-(void)userDidCancel
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginDidCancel)]) {
        [self.delegate loginDidCancel];
    }
}

-(void)userDidFinishSuccess
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginDidSuccess)]) {
        [self.delegate loginDidSuccess];
    }
}

-(void)userDidFailWithError:(NSError *)error
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginFailedWithError:)]) {
        [self.delegate loginFailedWithError:error];
    }
}

@end
