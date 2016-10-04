//
//  DataViewController.h
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CellAddEditView.h"
#import "CellTemplate1View.h"
#import "ACDBMasterViewController.h"
#import "AccountsViewController.h"
#import "ACDBHelpTextViewController.h"
#import "SegmentedControl.h"
#import "PagingView.h"

@interface ContactsDataViewController : UITableViewController
@property(nonatomic,strong) IBOutlet CellAddEditView *cellAddEdit;
@property(nonatomic,strong) IBOutlet CellTemplate1View *cellTemplate1;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *toggleItem;


-(IBAction)toggle:(id)sender;

@end
