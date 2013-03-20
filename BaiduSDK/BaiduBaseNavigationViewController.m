//
//  BaiduBaseNavigationViewController.m
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#import "BaiduBaseNavigationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BaiduBaseNavigationViewController (Private) 

- (void)addObservers;
- (void)removeObservers;

- (CGRect)calcFrameBefore;
- (CGRect)calcFrameAfter;
- (CGAffineTransform)transformForOrientation;

@end

@implementation BaiduBaseNavigationViewController
@synthesize orientation = _orientation;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[self calcFrameBefore]] autorelease];
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.view.layer.shadowOffset = CGSizeMake(40, 40);
//        self.view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
//        self.view.layer.shadowOpacity = 0.8;
//        self.view.layer.borderWidth = 2;
//        self.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)change:(BaiduBaseNavigationViewController *)targetController
{
    self.orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    targetController.orientation = self.orientation;
    targetController.view.transform = [targetController transformForOrientation];
    targetController.view.frame = [targetController calcFrameAfter];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[UIApplication sharedApplication].keyWindow cache:YES];
    
    [[UIApplication sharedApplication].keyWindow addSubview:targetController.view];
    [UIView commitAnimations];
    
    [self performSelectorOnMainThread:@selector(selfChangeOption:) withObject:targetController waitUntilDone:YES];
}

- (void)viewAnimationShow
{
    self.view.transform = [self transformForOrientation];
    self.view.frame = [self calcFrameBefore];
        
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    self.view.frame = [self calcFrameAfter];
    [UIView commitAnimations];
}

- (void)viewAnimationHide
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSuperviewFrowWindow)];
    self.view.frame = [self calcFrameBefore];
	[UIView commitAnimations];
}

- (void)removeSuperviewFrowWindow
{
    [self.view removeFromSuperview];
}

- (void)addObservers 
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)close
{
    self.orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self removeObservers];
    [self viewAnimationHide];
    [self release];
}

- (void)show
{
    self.orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    
    [self addObservers];
    [self viewAnimationShow];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)selfChangeOption:(BaiduBaseNavigationViewController *)newController
{
    
}

- (void)otherChangeOption:(BaiduBaseNavigationViewController *)newController
{
    
}

- (CGAffineTransform)transformForOrientation
{
    if (self.orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (self.orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (self.orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (CGRect)calcFrameBefore
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect resultFrame = CGRectZero;
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {*/
        if (self.orientation == UIDeviceOrientationLandscapeLeft) {
            resultFrame.origin.x = -bounds.size.width;
            resultFrame.origin.y = 0.0f;
        } else if (self.orientation == UIDeviceOrientationLandscapeRight) {
            resultFrame.origin.x = bounds.size.width;
            resultFrame.origin.y = 0.0f;
        } else if (self.orientation == UIDeviceOrientationPortrait) {
            resultFrame.origin.x = 0.0f;
            resultFrame.origin.y = bounds.size.height;
        } else if (self.orientation == UIDeviceOrientationPortraitUpsideDown) {
            resultFrame.origin.x = 0.0f;
            resultFrame.origin.y = -bounds.size.height;
        } else {
            resultFrame.origin.x = 0.0f;
            resultFrame.origin.y = bounds.size.height;
        }
        resultFrame.size.width = bounds.size.width;
        resultFrame.size.height = bounds.size.height;
    /*} else {
        CGSize containerSize = CGSizeMake(420, 518);
        if (self.orientation == UIDeviceOrientationLandscapeLeft) {
            resultFrame.origin.x = -containerSize.width;
            resultFrame.origin.y = (bounds.size.height - containerSize.width)*0.5;
            resultFrame.size.width = containerSize.height;
            resultFrame.size.height = containerSize.width;
        } else if (self.orientation == UIDeviceOrientationLandscapeRight) {
            resultFrame.origin.x = bounds.size.width;
            resultFrame.origin.y = (bounds.size.height - containerSize.width)*0.5;
            resultFrame.size.width = containerSize.height;
            resultFrame.size.height = containerSize.width;
        } else if (self.orientation == UIDeviceOrientationPortrait) {
            resultFrame.origin.x = (bounds.size.width - containerSize.width)*0.5;
            resultFrame.origin.y = bounds.size.height;
            resultFrame.size.width = containerSize.width;
            resultFrame.size.height = containerSize.height;
        } else if (self.orientation == UIDeviceOrientationPortraitUpsideDown) {
            resultFrame.origin.x = (bounds.size.width - containerSize.width)*0.5;
            resultFrame.origin.y = -containerSize.height;
            resultFrame.size.width = containerSize.width;
            resultFrame.size.height = containerSize.height;
        } else {
            resultFrame.origin.x = (bounds.size.width - containerSize.width)*0.5;
            resultFrame.origin.y = bounds.size.height;
            resultFrame.size.width = containerSize.width;
            resultFrame.size.height = containerSize.height;
        }
    }*/
    return resultFrame;
}

- (CGRect)calcFrameAfter
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect resultFrame = CGRectZero;
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){*/
        resultFrame = bounds;
    /*} else {
        CGSize containerSize = CGSizeMake(420, 518);
        if (self.orientation == UIDeviceOrientationLandscapeLeft) {
            resultFrame.origin.x = (bounds.size.width - containerSize.height)*0.5;
            resultFrame.origin.y = (bounds.size.height - containerSize.width)*0.5;
            resultFrame.size.width = containerSize.height;
            resultFrame.size.height = containerSize.width;
        } else if (self.orientation == UIDeviceOrientationLandscapeRight) {
            resultFrame.origin.x = (bounds.size.width - containerSize.height)*0.5;
            resultFrame.origin.y = (bounds.size.height - containerSize.width)*0.5;
            resultFrame.size.width = containerSize.height;
            resultFrame.size.height = containerSize.width;
        } else if (self.orientation == UIDeviceOrientationPortrait) {
            resultFrame.origin.x = (bounds.size.width - containerSize.width)*0.5;
            resultFrame.origin.y = (bounds.size.height - containerSize.height)*0.5;
            resultFrame.size.width = containerSize.width;
            resultFrame.size.height = containerSize.height;
        } else if (self.orientation == UIDeviceOrientationPortraitUpsideDown) {
            resultFrame.origin.x = (bounds.size.width - containerSize.width)*0.5;
            resultFrame.origin.y = (bounds.size.height - containerSize.height)*0.5;
            resultFrame.size.width = containerSize.width;
            resultFrame.size.height = containerSize.height;
        } else {
            resultFrame.origin.x = (bounds.size.width - containerSize.width)*0.5;
            resultFrame.origin.y = (bounds.size.height - containerSize.height)*0.5;
            resultFrame.size.width = containerSize.width;
            resultFrame.size.height = containerSize.height;
        }
    }*/
    return resultFrame;
}

- (void)setSubViewOrientationChange
{
    return;
}

- (void)deviceOrientationDidChange:(id)object
{
    UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    if (orientation != self.orientation) {
        self.orientation = orientation;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.view.transform = [self transformForOrientation];
        self.view.frame = [self calcFrameAfter];
        [self setSubViewOrientationChange];
        [UIView commitAnimations];
    }
    [self.view setNeedsLayout];
}

- (void)dealloc
{
    [super dealloc];
}

@end
