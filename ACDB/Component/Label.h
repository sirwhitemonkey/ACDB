//
//  Label.h
//  ACDB
//
//  Created by Rommel on 5/06/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Label : UILabel
{
    CGFloat topInset;
    CGFloat leftInset;
    CGFloat bottomInset;
    CGFloat rightInset;
}

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) CGFloat rightInset;

@end