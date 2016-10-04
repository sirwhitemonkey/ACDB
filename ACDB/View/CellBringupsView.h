//
//  CellBringupsView.h
//  ACDB
//
//  Created by Rommel on 11/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Button.h"
#import "Label.h"

@interface CellBringupsView : UITableViewCell

@property(nonatomic,strong)IBOutlet UILabel *bringups_contactdate;
@property(nonatomic,strong)IBOutlet UILabel *bringups_header;
@property(nonatomic,strong)IBOutlet UILabel *bringups_subheader;
@property(nonatomic,strong)IBOutlet Label *bringups_bringupdate;
@property(nonatomic,strong)IBOutlet Button *bringups_bringupdateEnControl;



@end
