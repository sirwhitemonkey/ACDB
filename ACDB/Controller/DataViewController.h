//
//  DataViewController.h
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//



#define MANAGEOBJECT @"ManageObject"

#import <UIKit/UIKit.h>
#import "ACDBAppDelegate.h"
#import "CellAddEditView.h"
#import "CellTemplate2View.h"
#import "ACDBMasterViewController.h"
#import "AccountsViewController.h"
#import "SegmentedControl.h"

@interface DataViewController : UITableViewController
@property(nonatomic,strong) IBOutlet CellAddEditView *cellAddEdit;
@property(nonatomic,strong) IBOutlet CellTemplate2View *cellTemplate2;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *toggleItem;


-(IBAction)toggle:(id)sender;

@end
