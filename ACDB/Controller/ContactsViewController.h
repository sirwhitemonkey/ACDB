//
//  ContactsViewController.h
//  ACDB
//
//  Created by Rommel on 16/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePicker.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "ACDBHelpTextViewController.h"
#import "TextView.h"


#define WORKPHONE1 0
#define WORKPHONE2 1
#define MOBILEPHONE 2
#define HOMEPHONE 3

#define EMAIL1 0
#define EMAIL2 1


@interface ContactsViewController : UITableViewController

@property(nonatomic,strong) IBOutlet UITextField *contact_birthday;
@property(nonatomic,strong) IBOutlet TextView *contact_chn_b_days;
@property(nonatomic,strong) IBOutlet UILabel *info_contact_conuserdef1;
@property(nonatomic,strong) IBOutlet UILabel *info_contact_conuserdef2;
@property(nonatomic,strong) IBOutlet UILabel *info_contact_conuserdef3;
@property(nonatomic,strong) IBOutlet UILabel *info_contact_conuserdef4;
@property(nonatomic,strong) IBOutlet UITextField *contact_conuserdef1_data;
@property(nonatomic,strong) IBOutlet UITextField *contact_conuserdef2_data;
@property(nonatomic,strong) IBOutlet UITextField *contact_conuserdef3_data;
@property(nonatomic,strong) IBOutlet UITextField *contact_conuserdef4_data;
@property(nonatomic,strong) IBOutlet UITextField *contact_email1;
@property(nonatomic,strong) IBOutlet UITextField *contact_email2;
@property(nonatomic,strong) IBOutlet UITextField *contact_firstname;
@property(nonatomic,strong) IBOutlet TextView *contact_hobbies;
@property(nonatomic,strong) IBOutlet UITextField *contact_homephone;
@property(nonatomic,strong) IBOutlet UITextField *contact_jobtitle;
@property(nonatomic,strong) IBOutlet UITextField *contact_lastname;
@property(nonatomic,strong) IBOutlet UITextField *contact_mobilephone;
@property(nonatomic,strong) IBOutlet UITextField *contact_nickname;
@property(nonatomic,strong) IBOutlet TextView *contact_notes;
@property(nonatomic,strong) IBOutlet UITextField *contact_partner;
@property(nonatomic,strong) IBOutlet UITextField *contact_salutation;
@property(nonatomic,strong) IBOutlet UITextField *contact_workphone1;
@property(nonatomic,strong) IBOutlet UITextField *contact_workphone2;
@property(nonatomic,strong) IBOutlet UITextField *contact_workphoneextension1;
@property(nonatomic,strong) IBOutlet UITextField *contact_workphoneextension2;
@property(nonatomic,strong) IBOutlet UITextField *contact_buyingpower;
@property(nonatomic,strong) IBOutlet UITextField *contact_supportlevel;
@property(nonatomic,strong) IBOutlet UITextField *contact_currentemployee;
@property(nonatomic,strong) IBOutlet UILabel *contact_renotes;
@property(nonatomic,strong) IBOutlet UIButton *conuserdef1Option;
@property(nonatomic,strong) IBOutlet UIButton *conuserdef2Option;
@property(nonatomic,strong) IBOutlet UIButton *conuserdef3Option;
@property(nonatomic,strong) IBOutlet UIButton *conuserdef4Option;




-(IBAction)phoneCall:(id)sender;
-(IBAction)sms:(id)sender;
-(IBAction)email:(id)sender;

-(IBAction)helpText:(id)sender;
-(IBAction)conuserdefs:(id)sender;


@end
