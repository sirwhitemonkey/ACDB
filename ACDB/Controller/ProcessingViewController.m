//
//  ProcessingViewController.m
//  ACDB
//
//  Created by Rommel Sumpo on 13/09/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//

#import "ProcessingViewController.h"

@interface ProcessingViewController ()
@property (nonatomic,strong) NSString *message;

@end

@implementation ProcessingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.50]];
    [self.indicatorView startAnimating];
    self.label.text = _message;
    self.label.textColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerNotifications];
    
}

- (BOOL)shouldAutorotate{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterFaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
}
#endif

#pragma mark - Notifications

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void) willEnterForegroundNotification {
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
}

- (void) didEnterBackgroundNotification {
    
}

#pragma mark - Methods
- (void)initialise:(NSString *)message
{
    _message = message;
    
}

@end
