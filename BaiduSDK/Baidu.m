//
//  BDConnect.m
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#import "Baidu.h"
#import "BaiduConfig.h"
#import "BaiduAuthorizeManager.h"
#import "BaiduUserSessionManager.h"
#import "BaiduAPIRequest.h"

@interface Baidu()

@property (nonatomic,retain)BaiduAPIRequest *request;

@end

@implementation Baidu
@synthesize request = _request;

- (id)initWithAPIKey:(NSString *)apiKey appId:(NSString *)appId
{
    if (self = [super init]) {
        [[BaiduConfig shareConfig] setApiKey:apiKey];
        [[BaiduConfig shareConfig] setAppId:appId];
        self.request = [[[BaiduAPIRequest alloc] init] autorelease];
    }
    
    return self;
}

- (BOOL)isUserSessionValid
{
    return [[BaiduUserSessionManager shareUserSessionManager].currentUserSession isUserSessionValid];
}

- (void)authorizeWithScope:(NSString*)scope andDelegate:(id<BaiduAuthorizeDelegate>)delegate
{
    if ([[BaiduUserSessionManager shareUserSessionManager].currentUserSession isUserSessionValid]) {
        return;
    }
    
    if ([[BaiduAuthorizeManager shareAuthorizeManager] canProcessSSO]){
        [[BaiduAuthorizeManager shareAuthorizeManager] authorizeToProcessSSOWithScope:scope andDelegate:delegate];
    } else {
        [[BaiduAuthorizeManager shareAuthorizeManager] authorizeToOpenWebPageWithScope:scope andDelegate:delegate];
    }
}

- (void)currentUserLogout
{
    [[BaiduUserSessionManager shareUserSessionManager].currentUserSession logout];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [[BaiduAuthorizeManager shareAuthorizeManager] handleOpenURL:url];
}

- (void)apiRequestWithUrl:(NSString *)requestUrl
               httpMethod:(NSString *)httpMethod
                   params:(NSDictionary *)params
              andDelegate:(id<BaiduAPIRequestDelegate>)delegate
{
    NSMutableDictionary *completeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if ( requestUrl != nil && [requestUrl rangeOfString:@"/public/"].location == NSNotFound) {
        [completeParams setObject:[BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken forKey:@"access_token"];
    }
    [completeParams setObject:@"json" forKey:@"format"];
    
    [self.request apiRequestWithUrl:requestUrl httpMethod:httpMethod params:completeParams andDelegate:delegate];
}

- (void)dealloc
{
    self.request = nil;
    [BaiduAuthorizeManager destroyAuthorizeManager];
    [BaiduUserSessionManager destroyUserSessionManager];
    [BaiduConfig destroyConfig];
    [super dealloc];
}

@end
