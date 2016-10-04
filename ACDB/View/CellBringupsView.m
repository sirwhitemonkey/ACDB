//
//  CellBringupsView.m
//  ACDB
//
//  Created by Rommel on 11/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "CellBringupsView.h"

@implementation CellBringupsView
@synthesize bringups_contactdate,bringups_header, bringups_subheader,bringups_bringupdate,bringups_bringupdateEnControl;


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
