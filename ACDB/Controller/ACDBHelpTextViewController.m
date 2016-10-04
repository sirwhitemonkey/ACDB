//
//  ACDBHelpTextViewController.m
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "ACDBHelpTextViewController.h"

@interface ACDBHelpTextViewController ()
@property(nonatomic,strong)NSString *helpTexts;
@end

@implementation ACDBHelpTextViewController

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
    self.navigationItem.title=@"Help";
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:_helpTexts ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.helpTextView loadHTMLString:htmlString baseURL:nil];
    self.helpTextView.scrollView.bounces=NO;
   
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
    if (IS_IOS_7)
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)helpTextInfo:(NSString*)text
{
   _helpTexts=text;
}

@end
