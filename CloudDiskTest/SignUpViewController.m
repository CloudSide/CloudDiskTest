//
//  SignUpViewController.m
//  CloudDiskTest
//
//  Created by Littlebox on 13-3-5.
//  Copyright (c) 2013年 Littlebox. All rights reserved.
//

#import "SignUpViewController.h"
#import "MainViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize diskName = _diskName;
@synthesize mainViewNavigationController = _mainViewNavigationController;
@synthesize bdConnect = _bdConnect;

- (void)dealloc {
    
    [super dealloc];
    
    [_diskName release];
    [_mainViewNavigationController release];
    [_bdConnect release];
}

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
    
    if ([_diskName isEqualToString:@"百度云"]) {
        
        ;
    }else {
        
        ;
    }
    
    
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
