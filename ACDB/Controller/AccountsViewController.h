//
//  AccountsViewController.h
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACDBAppDelegate.h"
#import "ACDBHelpTextViewController.h"
#import "MapViewController.h"
#import "TextView.h"
#import "OpenInGoogleMapsController.h"

@interface AccountsViewController : UITableViewController


@property(nonatomic,strong) IBOutlet UITextField *account_name;
@property(nonatomic,strong) IBOutlet UILabel *info_account_accountnames;
@property(nonatomic,strong) IBOutlet UITextField *account_accountnames_data;
@property(nonatomic,strong) IBOutlet UITextField *account_contactmainphone;
@property(nonatomic,strong) IBOutlet UITextField *account_primarycontact;
@property(nonatomic,strong) IBOutlet UITextField *account_secondarycontact;
@property(nonatomic,strong) IBOutlet UITextField *account_billing;
@property(nonatomic,strong) IBOutlet UITextField *account_accounts;
@property(nonatomic,strong) IBOutlet UITextField *account_streetaddr1;
@property(nonatomic,strong) IBOutlet UITextField *account_streetaddr2;
@property(nonatomic,strong) IBOutlet UITextField *account_streetaddr3;
@property(nonatomic,strong) IBOutlet UITextField *account_streetaddr4;
@property(nonatomic,strong) IBOutlet UITextField *account_streetaddr4_;

@property(nonatomic,strong) IBOutlet UILabel *info_account_streetaddr3;
@property(nonatomic,strong) IBOutlet UILabel *info_account_streetaddr4;

@property(nonatomic,strong) IBOutlet UITextField *account_country;
@property(nonatomic,strong) IBOutlet UITextField *account_postaladdr1;
@property(nonatomic,strong) IBOutlet UITextField *account_postaladdr2;
@property(nonatomic,strong) IBOutlet UITextField *account_postaladdr3;
@property(nonatomic,strong) IBOutlet UITextField *account_postaladdr4;
@property(nonatomic,strong) IBOutlet UITextField *account_postaladdr4_;
@property(nonatomic,strong) IBOutlet UILabel *info_account_postaladdr3;
@property(nonatomic,strong) IBOutlet UILabel *info_account_postaladdr4;
@property(nonatomic,strong) IBOutlet UITextField *account_postalcountry;
@property(nonatomic,strong) IBOutlet UITextField *account_employees;
@property(nonatomic,strong) IBOutlet UITextField *account_warning;
@property(nonatomic,strong) IBOutlet UITextField *account_relationship;
@property(nonatomic,strong) IBOutlet UITextField *account_stdinclass;
@property(nonatomic,strong) IBOutlet UITextField *account_website;
@property(nonatomic,strong) IBOutlet UILabel *account_renotes;
@property(nonatomic,strong) IBOutlet UILabel *info_account_accuserdef1;
@property(nonatomic,strong) IBOutlet UILabel *info_account_accuserdef2;
@property(nonatomic,strong) IBOutlet UILabel *info_account_accuserdef3;
@property(nonatomic,strong) IBOutlet UILabel *info_account_accuserdef4;
@property(nonatomic,strong) IBOutlet UITextField *account_accuserdef1_data;
@property(nonatomic,strong) IBOutlet UITextField *account_accuserdef2_data;
@property(nonatomic,strong) IBOutlet UITextField *account_accuserdef3_data;
@property(nonatomic,strong) IBOutlet UITextField *account_accuserdef4_data;
@property(nonatomic,strong) IBOutlet TextView *account_notes;
@property(nonatomic,strong) IBOutlet UIToolbar *controlOptions;
@property(nonatomic,strong) IBOutlet UIButton *type;
@property(nonatomic,strong) IBOutlet UIButton *accuserdef1Option;
@property(nonatomic,strong) IBOutlet UIButton *accuserdef2Option;
@property(nonatomic,strong) IBOutlet UIButton *accuserdef3Option;
@property(nonatomic,strong) IBOutlet UIButton *accuserdef4Option;
@property(nonatomic,strong) IBOutlet UILabel *viewMap;
@property(nonatomic,strong) IBOutlet UILabel *viewGoogleMap;





-(IBAction)phoneCall:(id)sender;
-(IBAction)helpText:(id)sender;

-(IBAction)options:(id)sender;
-(IBAction)website:(id)sender;
-(IBAction)accountnames:(id)sender;
-(IBAction)accuserdefs:(id)sender;



@end
