//
//  KPAuthViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-8.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "KPAuthViewController.h"

#import "MainViewControllerKdisk.h"

@interface KPAuthViewController ()

@end

@implementation KPAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSArray *subViewArray = [self.view subviews];
    NSInteger numSubViews = [subViewArray count];
    
    for ( int i=0; i<numSubViews; i++) {
        
        if ([[subViewArray objectAtIndex:i] isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)[subViewArray objectAtIndex:i];
            
            if ([[[button titleLabel] text] isEqualToString:@"登陆并授权"]) {
                
                [button setTitle:@"登录" forState:UIControlStateHighlighted];
                [button setTitle:@"登录" forState:UIControlStateNormal];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (!self.isAlreadAuth) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } else {
        
        MainViewControllerKdisk *mainViewControllerKdisk = [[[MainViewControllerKdisk alloc] init] autorelease];
        [self.navigationController pushViewController:mainViewControllerKdisk animated:YES];
    }
    
    [super viewWillDisappear:animated];
}

@end
