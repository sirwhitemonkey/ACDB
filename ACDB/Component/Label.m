//
//  Label.m
//  ACDB
//
//  Created by Rommel on 5/06/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "Label.h"

@implementation Label

@synthesize topInset, leftInset, bottomInset, rightInset;

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {self.topInset, self.leftInset,
        self.bottomInset, self.rightInset};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
