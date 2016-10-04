//
//  CellGeneralView.m
//  ACDB
//
//  Created by Rommel on 11/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "CellTemplate1View.h"

@implementation CellTemplate1View
@synthesize template_info1,template_info2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
