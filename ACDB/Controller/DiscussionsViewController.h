//
//  DiscussionsViewController.h
//  ACDB
//
//  Created by Rommel on 18/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePicker.h"
#import "ACDBAppDelegate.h"
#import "ACDBHelpTextViewController.h"
#import "TextView.h"


@interface DiscussionsViewController : UITableViewController

@property(nonatomic,strong) IBOutlet UITextField *discussion_contacttype;
@property(nonatomic,strong) IBOutlet UITextField *discussion_contactperson;
@property(nonatomic,strong) IBOutlet UITextField *discussion_contactheader;
@property(nonatomic,strong) IBOutlet UITextField *discussion_contactdate;
@property(nonatomic,strong) IBOutlet UITextField *discussion_bringupdate;
@property(nonatomic,strong) IBOutlet TextView *discussion_notes;


-(IBAction)helpText:(id)sender;
@end