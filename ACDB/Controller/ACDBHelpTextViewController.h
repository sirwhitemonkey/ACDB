//
//  ACDBHelpTextViewController.h
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"

@interface ACDBHelpTextViewController : UIViewController
@property(nonatomic,strong) IBOutlet UIWebView *helpTextView;

-(void)helpTextInfo:(NSString*)text;

@end
