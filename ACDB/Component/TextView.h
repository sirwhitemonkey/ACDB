//
//  TextView.h
//  ACDB
//
//  Created by Rommel on 28/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"
#import <QuartzCore/QuartzCore.h>

@interface TextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end