//
//  DataViewController.h
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CellAddEditView.h"
#import "CellBringupsView.h"
#import "AccountsViewController.h"
#import "SegmentedControl.h"
#import "Button.h"
#import <QuartzCore/QuartzCore.h>

@interface DiscussionsDataViewController : UITableViewController
@property(nonatomic,strong) IBOutlet CellAddEditView *cellAddEdit;
@property(nonatomic,strong) IBOutlet CellBringupsView *cellBringups;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *toggleItem;


-(IBAction)toggle:(id)sender;
-(IBAction)controlsEntity:(id)sender;

@end
