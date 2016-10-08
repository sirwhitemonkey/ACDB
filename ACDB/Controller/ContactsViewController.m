//
//  ContactsViewController.m
//  ACDB
//
//  Created by Rommel on 16/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "ContactsViewController.h"

#define textViewFont [UIFont systemFontOfSize:14.0f]

@interface ContactsViewController ()<UITextFieldDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,DatePickerDelegate>

@property BOOL scroll;

@property(nonatomic,strong)DatePicker *datePicker;
@property(nonatomic,strong)UIBarButtonItem *infoBtn;
@property(nonatomic,strong)UIBarButtonItem *doneBtn;
@property(nonatomic,strong)Contact *contact;
@end

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFields];
   
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIButton *info = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 24)];
    [info addTarget:self action:@selector(helpText:) forControlEvents:UIControlEventTouchUpInside];
    [info setImage:[UIImage imageNamed:@"info_24"] forState:UIControlStateNormal];
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 24)];
    [infoView addSubview:info];
    
    _infoBtn = [[UIBarButtonItem alloc] initWithCustomView:infoView];
    
    _doneBtn = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                    target:self action:@selector(done:)];
    
    
    self.navigationItem.rightBarButtonItem=_infoBtn;

    
    self.contact_chn_b_days.placeholder=@"Chn & B/days";
    self.contact_hobbies.placeholder=@"Hobbies";
    self.contact_notes.placeholder=@"Notes";
    
    //self.contact_chn_b_days.contentInset = UIEdgeInsetsMake(2, (IS_IOS_7 ? -3 : -8),0,0);
    //self.contact_hobbies.contentInset = UIEdgeInsetsMake(2,(IS_IOS_7 ? -3 : -8),0,0);
    
    _datePicker=[[DatePicker alloc]init];
    _datePicker.delegate=self;
  
    [self.view endEditing:YES];
    
    [self syncSoftLabels];
    
    if (![appDelegate pageObject]){
        _contact = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_CONTACT inManagedObjectContext:[persistenceManager managedObjectContext]];
        _contact.uuid=[persistenceManager  newUUID];
        _contact.sync_modifier = [persistenceManager newUUID];
        
    } else {
        _contact = (Contact*)[appDelegate pageObject];
        
        NSString * contactbirthday=@"";
        
        if (_contact) {
          if (_contact.contact_birthday) {
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
            contactbirthday=[dateFormat stringFromDate:_contact.contact_birthday];
            }
        }
        self.contact_birthday.text=contactbirthday;
        
        self.contact_conuserdef1_data.text=_contact.contact_conuserdef1_data;
        self.contact_conuserdef2_data.text=_contact.contact_conuserdef2_data;
        self.contact_conuserdef3_data.text=_contact.contact_conuserdef3_data;
        self.contact_conuserdef4_data.text=_contact.contact_conuserdef4_data;
        
        self.contact_email1.text=_contact.contact_email1;
        self.contact_email2.text=_contact.contact_email2;
        
        if (![appDelegate isEmptyString:_contact.contact_firstname]) {
            self.contact_firstname.text=_contact.contact_firstname;
        } else {
            self.contact_firstname.placeholder=@"..";
        }
        
        [self resizingTextView];
        
        self.contact_homephone.text=_contact.contact_homephone;
        self.contact_jobtitle.text=_contact.contact_jobtitle;
        
        
        if (![appDelegate isEmptyString:_contact.contact_lastname]) {
            self.contact_lastname.text=_contact.contact_lastname;
        } else {
            self.contact_lastname.placeholder=@"..";
        }
        
        self.contact_mobilephone.text=_contact.contact_mobilephone;
        self.contact_nickname.text=_contact.contact_nickname;
        //self.contact_notes.text=_contact.contact_notes;
        self.contact_partner.text=_contact.contact_partner;
        self.contact_salutation.text=_contact.contact_salutation;
        self.contact_workphone1.text=_contact.contact_workphone1;
        self.contact_workphone2.text=_contact.contact_workphone2;
        self.contact_workphoneextension1.text=_contact.contact_workphoneextension1;
        self.contact_workphoneextension2.text=_contact.contact_workphoneextension2;
        if (_contact.contact_buyingpower) {
            self.contact_buyingpower.text=_contact.contact_buyingpower.buyingpower_name;
        }
        if (_contact.contact_supportlevel) {
            self.contact_supportlevel.text=_contact.contact_supportlevel.supportlevel_name;
        }
        
        if ([_contact.contact_currentemployee intValue] == 1 ) { //Yes
            self.contact_currentemployee.text=@"Yes";
        } else {
            self.contact_currentemployee.text=@"No";
        }

        NSString *firstname=@"";
        NSString *lastname=@"";
        if (![appDelegate isEmptyString:_contact.contact_nickname]) {
            firstname=_contact.contact_nickname;
        } else {
            if (![appDelegate isEmptyString:_contact.contact_firstname]) {
                firstname=_contact.contact_firstname;
            }
        }
        if (![appDelegate isEmptyString:_contact.contact_lastname]) {
            lastname=_contact.contact_lastname;
        }
        self.contact_renotes.text=[NSString stringWithFormat:@"Notes re %@ %@",firstname , lastname];
   }

    if (IS_IOS_7) {
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
        self.conuserdef1Option.alpha=0.40f;
        self.conuserdef2Option.alpha=0.40f;
        self.conuserdef3Option.alpha=0.40f;
        self.conuserdef4Option.alpha=0.40f;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
    [self syncSoftLabels];
    
    // re-size contact_renotes
    CGSize mainScreen = [[UIScreen mainScreen]bounds].size;
    self.contact_notes.frame = CGRectMake(0.0f, self.contact_notes.frame.origin.y, mainScreen.width, self.contact_notes.frame.size.height);
    

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.title=@"Contact";
    NSIndexPath *indexPath;
    
    _scroll=true;
    
    SoftLabels *softlabels=(SoftLabels*)[persistenceManager entityObject:ENTITY_SOFTLABELS];
   
    if (![appDelegate pageObject]) {
        _contact = (Contact*)[persistenceManager  entityObject:ENTITY_CONTACT uuid:_contact.uuid];
    }
    
    switch((int)[appDelegate pageRequest]) {
        case PageRequest_Contact_BuyingPower:
            if (![appDelegate pageObject]) {
                [appDelegate setPageObject:(NSManagedObject*)_contact.contact_buyingpower];
                self.contact_buyingpower.text=@"";
                _scroll=false;
            }

            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[BuyingPower class]]) {
                BuyingPower *buyingPower=(BuyingPower*)[appDelegate pageObject];
                self.contact_buyingpower.text=buyingPower.buyingpower_name;
                
                if (_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:13 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                _contact.contact_buyingpower=buyingPower;
                [buyingPower addBuyingpowerObject:self.contact];
            }
            break;
        case PageRequest_Contact_SupportLevel:
            if (![appDelegate pageObject]) {
                [appDelegate setPageObject:(NSManagedObject*)_contact.contact_supportlevel];
                self.contact_supportlevel.text=@"";
                _scroll=false;
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[SupportLevel class]]) {
                SupportLevel *supportlevel=(SupportLevel*)[appDelegate pageObject];
                self.contact_supportlevel.text=supportlevel.supportlevel_name;
                
                if (_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:14 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                _contact.contact_supportlevel=supportlevel;
                [supportlevel addRelationshipObject:self.contact];
            } 
            break;
        case PageRequest_Contact_ConUserDef1:
            if (![appDelegate pageObject]) {
                _scroll=false;
                if (!softlabels.conuserdef1) {
                    self.info_contact_conuserdef1.text=@"";
                    self.contact_conuserdef1_data.placeholder=@"";
                }
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[ConUserDef1 class]]) {
                ConUserDef1 *conuserdef1=(ConUserDef1*)[appDelegate pageObject];
                self.info_contact_conuserdef1.text=conuserdef1.conuserdef_name;
                self.contact_conuserdef1_data.placeholder=conuserdef1.conuserdef_name;
                
                if (_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.conuserdef1=conuserdef1;
                [conuserdef1 addConuserdef1Object:softlabels];
            };
            break;
        case PageRequest_Contact_ConUserDef2:
            if (![appDelegate pageObject]) {
                _scroll=false;
                if (!softlabels.conuserdef2) {
                    self.info_contact_conuserdef2.text=@"";
                    self.contact_conuserdef2_data.placeholder=@"";
                }
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[ConUserDef2 class]]) {
                ConUserDef2 *conuserdef2=(ConUserDef2*)[appDelegate pageObject];
                self.info_contact_conuserdef2.text=conuserdef2.conuserdef_name;
                self.contact_conuserdef2_data.placeholder=conuserdef2.conuserdef_name;
                
                if (_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.conuserdef2=conuserdef2;
                [conuserdef2 addConuserdef2Object:softlabels];
            }
            break;
        case PageRequest_Contact_ConUserDef3:
            if (![appDelegate pageObject]) {
                _scroll=false;
                if (!softlabels.conuserdef3) {
                    self.info_contact_conuserdef3.text=@"";
                    self.contact_conuserdef3_data.placeholder=@"";
                }
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[ConUserDef3 class]]) {
                ConUserDef3 *conuserdef3=(ConUserDef3*)[appDelegate pageObject];
                self.info_contact_conuserdef3.text=conuserdef3.conuserdef_name;
                self.contact_conuserdef3_data.placeholder=conuserdef3.conuserdef_name;
                
                if (_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.conuserdef3=conuserdef3;
                [conuserdef3 addConuserdef3Object:softlabels];
            }
            break;
        case PageRequest_Contact_ConUserDef4:
            if (![appDelegate pageObject]) {
                _scroll=false;
                if (!softlabels.conuserdef4) {
                    self.info_contact_conuserdef4.text=@"";
                    self.contact_conuserdef4_data.placeholder=@"";
                }
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[ConUserDef4 class]]) {
                ConUserDef4 *conuserdef4=(ConUserDef4*)[appDelegate pageObject];
                self.info_contact_conuserdef4.text=conuserdef4.conuserdef_name;
                self.contact_conuserdef4_data.placeholder=conuserdef4.conuserdef_name;
                
                if (_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.conuserdef4=conuserdef4;
                [conuserdef4 addConuserdef4Object:softlabels];
             }
            break;



    }
    [appDelegate setPageObject:nil];
    self.navigationController.navigationBar.translucent=NO;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_datePicker)
        [_datePicker dismissDatePicker];
    
    [self contextAccountAllContacts];
    [persistenceManager saveContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) resizingTextView
{
    float height;
    CGRect textViewRect;
    
    if (![appDelegate isEmptyString:_contact.contact_hobbies]) {
        self.contact_hobbies.text=_contact.contact_hobbies;
        height = [self heightForTextView:self.contact_hobbies containingString:_contact.contact_hobbies];
        textViewRect = CGRectMake(self.contact_hobbies.frame.origin.x, self.contact_hobbies.frame.origin.y,
                                  self.contact_hobbies.frame.size.width,height);
        
        self.contact_hobbies.frame = textViewRect;
        self.contact_hobbies.contentSize = CGSizeMake(self.contact_hobbies.frame.size.width,
                                                      [self heightForTextView:self.contact_hobbies containingString:_contact.contact_hobbies]);
    }
    
    if (![appDelegate isEmptyString:_contact.contact_chn_b_days]) {
        self.contact_chn_b_days.text=_contact.contact_chn_b_days;
        height = [self heightForTextView:self.contact_chn_b_days containingString:_contact.contact_chn_b_days];
        textViewRect = CGRectMake(self.contact_chn_b_days.frame.origin.x, self.contact_chn_b_days.frame.origin.y,
                                  self.contact_chn_b_days.frame.size.width,height);
        
        self.contact_chn_b_days.frame = textViewRect;
        self.contact_chn_b_days.contentSize = CGSizeMake(self.contact_chn_b_days.frame.size.width,
                                                         [self heightForTextView:self.contact_chn_b_days
                                                                containingString:_contact.contact_chn_b_days]);
    }

    if (![appDelegate isEmptyString:_contact.contact_notes]) {
        self.contact_notes.text=_contact.contact_notes;
        height = [self heightForTextView:self.contact_notes containingString:_contact.contact_notes];
        textViewRect = CGRectMake(self.contact_notes.frame.origin.x, self.contact_notes.frame.origin.y,
                                  self.contact_notes.frame.size.width,height);
        
        self.contact_notes.frame = textViewRect;
        self.contact_notes.contentSize = CGSizeMake(self.contact_notes.frame.size.width,
                                                         [self heightForTextView:self.contact_notes
                                                                containingString:_contact.contact_notes]);
    }

}

-(void)contextAccountAllContacts
{
    if (_contact.uuid) {
        NSSet *contacts=[appDelegate acdbAccount].account_contacts;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", _contact.uuid];
        NSSet *contact = [contacts filteredSetUsingPredicate:predicate];
        if (contact.count <= 0) {
            [[appDelegate acdbAccount] addAccount_contactsObject:_contact];
        }
    }
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    self.navigationItem.rightBarButtonItem=_doneBtn;
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    self.navigationItem.rightBarButtonItem=_infoBtn;
}

-(IBAction)done:(id)sender
{
    [self.view endEditing:YES];
    [self resizingTextView];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void) setFields
{
    self.contact_birthday.accessibilityIdentifier = @"contact_birthday";
    self.contact_chn_b_days.accessibilityIdentifier = @"contact_chn_b_days";
    self.contact_conuserdef1_data.accessibilityIdentifier = @"contact_conuserdef1_data";
    self.contact_conuserdef2_data.accessibilityIdentifier = @"contact_conuserdef2_data";
    self.contact_conuserdef3_data.accessibilityIdentifier = @"contact_conuserdef3_data";
    self.contact_conuserdef4_data.accessibilityIdentifier = @"contact_conuserdef4_data";
    self.contact_email1.accessibilityIdentifier = @"contact_email1";
    self.contact_email2.accessibilityIdentifier = @"contact_email2";
    self.contact_firstname.accessibilityIdentifier = @"contact_firstname";
    self.contact_hobbies.accessibilityIdentifier = @"contact_hobbies";
    self.contact_homephone.accessibilityIdentifier = @"contact_homephone";
    self.contact_jobtitle.accessibilityIdentifier = @"contact_jobtitle";
    self.contact_lastname.accessibilityIdentifier = @"contact_lastname";
    self.contact_mobilephone.accessibilityIdentifier = @"contact_mobilephone";
    self.contact_nickname.accessibilityIdentifier = @"contact_nickname";
    self.contact_notes.accessibilityIdentifier = @"contact_notes";
    self.contact_partner.accessibilityIdentifier = @"contact_partner";
    self.contact_salutation.accessibilityIdentifier = @"contact_salutation";
    self.contact_workphone1.accessibilityIdentifier = @"contact_workphone1";
    self.contact_workphone2.accessibilityIdentifier = @"contact_workphone2";
    self.contact_workphoneextension1.accessibilityIdentifier = @"contact_workphoneextension1";
    self.contact_workphoneextension2.accessibilityIdentifier = @"contact_workphoneextension2";
    self.contact_buyingpower.accessibilityIdentifier = @"contact_buyingpower";
    self.contact_supportlevel.accessibilityIdentifier = @"contact_supportlevel";
    self.contact_currentemployee.accessibilityIdentifier = @"contact_currentemployee";
}

-(IBAction)helpText:(id)sender {
    [self performSegueWithIdentifier:@"HelpTextViewSegue" sender:self];
}

-(IBAction)phoneCall:(id)sender
{
    
    [_datePicker dismissDatePicker];
    NSString *phonenumber = nil;
    UITextField *textField = nil;
    switch(((UIButton*)sender).tag) {
        case WORKPHONE1:
            phonenumber = self.contact_workphone1.text;
            textField = self.contact_workphone1;
            break;
        case WORKPHONE2:
            phonenumber = self.contact_workphone2.text;
            textField = self.contact_workphone2;
            break;
        case MOBILEPHONE:
            phonenumber = self.contact_mobilephone.text;
            textField = self.contact_mobilephone;
            break;
        case HOMEPHONE:
            phonenumber = self.contact_homephone.text;
            textField = self.contact_homephone;
            break;
    }
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@" " withString:@""];

    [textField resignFirstResponder];
    if ( [appDelegate isEmptyString:phonenumber]) {
        [appDelegate alert:[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Phone number"]];
        [textField becomeFirstResponder];
        
     } else {
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
             
             BOOL installed = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"skype:"]];
             if(installed){
                 phonenumber=[NSString stringWithFormat:@"skype:%@?call",phonenumber];
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenumber]];
             } else{
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/skype-for-ipad/id442012681?mt=8"]];
             }
             
         } else {
             
             phonenumber = [NSString stringWithFormat:@"tel:%@",
                            [phonenumber stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
             
             if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenumber]]) {
                 [appDelegate alert:DEVICE_NOT_SUPPORT_FEATURE];
                 
             }
         }

    }
    
    

    
}

-(IBAction)sms:(id)sender
{
     [self.contact_mobilephone resignFirstResponder];
    [_datePicker dismissDatePicker];
    
    NSString *phonenumber=self.contact_mobilephone.text;
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@" " withString:@""];

    
    if ( [appDelegate isEmptyString:phonenumber]) {
        [appDelegate alert:[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Phone number"]];
        [self.contact_mobilephone becomeFirstResponder];
        
    } else {
        if([MFMessageComposeViewController canSendText]){
            MFMessageComposeViewController *smsComposer =[[MFMessageComposeViewController alloc] init];
            
            smsComposer.recipients = [NSArray arrayWithObject:phonenumber];
            smsComposer.body = @"";
            smsComposer.messageComposeDelegate = self;
            [self presentViewController:smsComposer animated:NO completion:nil];
        }
        else{
            [appDelegate alert:DEVICE_NOT_SUPPORT_FEATURE];
            [self.contact_mobilephone resignFirstResponder];
        }
        
    }
   
    

}

-(IBAction)email:(id)sender;
{
    [_datePicker dismissDatePicker];
    
    NSString *email = nil;
    UITextField *textField = nil;
    
    switch(((UIButton*)sender).tag) {
        case EMAIL1:
            email = self.contact_email1.text;
            textField = self.contact_email1;
            break;
        case EMAIL2:
            email = self.contact_email2.text;
            textField = self.contact_email2;
            break;
            
    }
    
    [textField resignFirstResponder];
    if ([appDelegate isEmptyString:email]) {
        [appDelegate alert:[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Email"]];
        [textField becomeFirstResponder];
        
    } else {
        if (![appDelegate emailValid:email]) {
            [appDelegate alert:INVALID_EMAIL_ADDRESS];
            [textField becomeFirstResponder];
        }
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@""];
            [controller setMessageBody:@"" isHTML:NO];
            [controller setToRecipients:[NSArray arrayWithObject:email]];
            [self.navigationController presentViewController:controller animated:NO completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }];
        } else {
            [appDelegate alert:DEVICE_NOT_SUPPORT_FEATURE];
        }
  }
   
    
}

-(IBAction)conuserdefs:(id)sender
{
    NSIndexPath *indexPath;
    switch(((UIButton*)sender).tag) {
        case 0:
            [appDelegate setPageController:PageConUserDef1];
            [appDelegate setPageRequest:PageRequest_Contact_ConUserDef1];
            indexPath=[NSIndexPath indexPathForRow:0 inSection:1];
            break;
        case 1:
            [appDelegate setPageController:PageConUserDef2];
            [appDelegate setPageRequest:PageRequest_Contact_ConUserDef2];
            indexPath=[NSIndexPath indexPathForRow:1 inSection:1];
            break;
        case 2:
            [appDelegate setPageController:PageConUserDef3];
            [appDelegate setPageRequest:PageRequest_Contact_ConUserDef3];
            indexPath=[NSIndexPath indexPathForRow:2 inSection:1];
            break;
        case 3:
            [appDelegate setPageController:PageConUserDef4];
            [appDelegate setPageRequest:PageRequest_Contact_ConUserDef4];
            indexPath=[NSIndexPath indexPathForRow:3 inSection:1];
            break;
    }
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
    
    
}

-(void)showBirthDates
{
    [appDelegate setPageRequest:PageRequest_Contact_Birthday];
    NSString *firstname=@"";
    NSString *lastname=@"";
    if (![appDelegate isEmptyString:self.contact_nickname.text]) {
        firstname = self.contact_nickname.text;
    } else {
        if (![appDelegate isEmptyString:self.contact_firstname.text]) {
            firstname = self.contact_firstname.text;
        }
    }
    if (![appDelegate isEmptyString:self.contact_lastname.text]) {
        lastname = self.contact_lastname.text;
    }
    
    [_datePicker presentDatePickerInView:[UIApplication sharedApplication].keyWindow date:self.contact_birthday.text value:[NSString stringWithFormat:@"%@ %@",firstname,lastname] source:self.contact_birthday];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        
    }

}

#pragma  mark - DatePicker

-(void)selectedDatePicker:(NSDate*)date
{
    switch((int)[appDelegate pageRequest]) {
        case PageRequest_Contact_Birthday: {
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
            self.contact_birthday.text=[dateFormat stringFromDate:date];
            [_contact setValue:date forKey:self.contact_birthday.accessibilityIdentifier];
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:9 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionMiddle
                                          animated:YES];

            
            
        }
            break;
    }
    
}

-(void)initializedDatePicker
{
    
}

-(void)completedDatePicker
{
     switch((int)[appDelegate pageRequest]) {
        case PageRequest_Contact_Birthday:
           
            break;
            
    }
    if (_datePicker) {
        [_datePicker dismissDatePicker];
    }
    

}

-(void)eventDatePickerStart
{
}

-(void)eventDatePickerEnd:(NSString *)result
{
    if (_datePicker)
        [_datePicker dismissDatePicker];
    
    [appDelegate alert:result];
}

#pragma MFMessage / MFMail
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        [appDelegate alert:EMAIL_SENT];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if (_datePicker) {
        [_datePicker dismissDatePicker];
     }
    [_contact setValue:[appDelegate trim:textView.text] forKey:textView.accessibilityIdentifier];
    
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView
{
    if ([textView.accessibilityIdentifier isEqualToString:@"contact_hobbies"]) {
        _contact.contact_hobbies=textView.text;
    } else if ([textView.accessibilityIdentifier isEqualToString:@"contact_chn_b_days"]) {
        _contact.contact_chn_b_days=textView.text;
    } else if ([textView.accessibilityIdentifier isEqualToString:@"contact_notes"]) {
        _contact.contact_notes=textView.text;
    }
    
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.accessibilityIdentifier isEqualToString:@"contact_hobbies"]) {
        _contact.contact_hobbies=textView.text;
    } else if ([textView.accessibilityIdentifier isEqualToString:@"contact_chn_b_days"]) {
        _contact.contact_chn_b_days=textView.text;
    }else if ([textView.accessibilityIdentifier isEqualToString:@"contact_notes"]) {
        _contact.contact_notes=textView.text;
    }
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.accessibilityIdentifier isEqualToString:@"contact_notes"]) {
        [self performSelector:@selector(positionContactNotes) withObject:nil afterDelay:1.0];
    }
    
    
}

- (void)positionContactNotes {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]
                                animated:YES scrollPosition:UITableViewScrollPositionTop];
}


-(CGFloat)numberOfLinesForTextView:(UITextView*)textView containingString:(NSString*)string
{
    CGSize size = [string boundingRectWithSize:textView.frame.size
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: textViewFont}
                                                context:nil].size;
    
    return (size.height/textViewFont.lineHeight);
    
}

- (CGFloat)heightForTextView:(UITextView*)textView containingString:(NSString*)string
{
    float horizontalPadding = 24;
    float verticalPadding =16;
    float widthOfTextView = textView.contentSize.width - horizontalPadding;
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(widthOfTextView, 999999.0f)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}
                                       context:nil].size;

    return size.height + verticalPadding;
}

#pragma mark - UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    // Prevent crashing
    if(range.length + range.location > textField.text.length){
        return NO;
    }
   
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > MAX_TEXT_FIELDS) {
        return NO;
    }
    
    NSString *newString,*expression;
    NSRegularExpression *regex;
    NSUInteger numberOfMatches;
    
    
    if ([textField.accessibilityIdentifier isEqualToString:@"contact_workphoneextension1"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_workphoneextension2"]){
        
        if (range.location==4)
            return NO;
        
        newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        expression = @"^([0-9]+)??$";
        regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
        
    } else if ([textField.accessibilityIdentifier isEqualToString:@"contact_workphone1"] ||
               [textField.accessibilityIdentifier isEqualToString:@"contact_workphone2"] ||
               [textField.accessibilityIdentifier isEqualToString:@"contact_homephone"] ||
               [textField.accessibilityIdentifier isEqualToString:@"contact_mobilephone"]) {
        
        if ([string isEqualToString:@"("] ||
            [string isEqualToString:@")"] ||
            [string isEqualToString:@"-"] ||
            [string isEqualToString:@" "] ||
            [string isEqualToString:@"+"])
            return YES;
        
        expression = @"^([0-9]+)??$";
        regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
        numberOfMatches = [regex numberOfMatchesInString:string
                                                 options:0
                                                   range:NSMakeRange(0, [string length])];
        if (numberOfMatches == 0)
            return NO;
        
    }
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (_datePicker) {
        [_datePicker dismissDatePicker];
    }
    [self textFieldEditing:textField];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.accessibilityIdentifier isEqualToString:@"contact_email1"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_email2"]) {
        textField.text = [textField.text lowercaseString];
        
        if (![appDelegate isEmptyString:textField.text]) {
            if (![appDelegate emailValid:textField.text]) {
                [appDelegate alert:INVALID_EMAIL_ADDRESS];
                return;
            }
        }
        [_contact setValue:[appDelegate trim:textField.text] forKey:textField.accessibilityIdentifier];
        
    }
    
    if ([textField.accessibilityIdentifier isEqualToString:@"contact_firstname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_lastname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_nickname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_salutation"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_jobtitle"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_partner"]) {
        textField.text=[appDelegate trim:[appDelegate capitalizeAllWords:textField.text]];
    }

    [self textFieldEditing:textField];
}

- (void) textFieldEditing:(UITextField*)textField
{
    NSString *value=textField.text;
    
    if ([textField.accessibilityIdentifier isEqualToString:@"contact_firstname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_lastname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_nickname"]) {
        NSString *firstname=@"";
        NSString *lastname=@"";
        if (![appDelegate isEmptyString:self.contact_nickname.text]) {
            firstname = self.contact_nickname.text;
        } else {
            if (![appDelegate isEmptyString:self.contact_firstname.text]) {
                firstname = self.contact_firstname.text;
            }
        }
        if (![appDelegate isEmptyString:self.contact_lastname.text]) {
            lastname = self.contact_lastname.text;
        }
        _contact.contact_name = [NSString stringWithFormat:@"%@ %@",firstname,lastname];
        _contact_renotes.text = [NSString stringWithFormat:@"Notes re %@ %@", [appDelegate capitalizeAllWords:firstname] ,
                                   [appDelegate capitalizeAllWords: lastname]];
    }
    if ([textField.accessibilityIdentifier isEqualToString:@"contact_firstname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_lastname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_nickname"] |
        [textField.accessibilityIdentifier isEqualToString:@"contact_salutation"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_jobtitle"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_partner"]) {
        value = [appDelegate capitalizeAllWords:value];
    }
    [_contact setValue:[appDelegate trim:value] forKey:textField.accessibilityIdentifier];
  
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.accessibilityIdentifier isEqualToString:@"contact_firstname"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_lastname"]) {
        NSString *placeholder;
        if ([textField.accessibilityIdentifier isEqualToString:@"contact_firstname"]) {
            placeholder = textField.placeholder;
            if ([placeholder isEqualToString:@".."]) {
                textField.placeholder=@"First Name";
            }
        }
        
        if ([textField.accessibilityIdentifier isEqualToString:@"contact_lastname"]) {
            placeholder = textField.placeholder;
            if ([placeholder isEqualToString:@".."]) {
                textField.placeholder=@"Last Name";
            }
        }
    }
  
    if ([textField.accessibilityIdentifier isEqualToString:@"contact_birthday"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_supportlevel"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_buyingpower"] ||
        [textField.accessibilityIdentifier isEqualToString:@"contact_currentemployee"]) {
        
        [self.view endEditing:YES];
        
        if ([textField.accessibilityIdentifier isEqualToString:@"contact_birthday"]) {
            [self showBirthDates];
   
        } else if ([textField.accessibilityIdentifier isEqualToString:@"contact_supportlevel"]) {
            [appDelegate setPageObject:nil];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:14 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            [appDelegate setPageController:PageSupportLevel];
            [appDelegate setPageRequest:PageRequest_Contact_SupportLevel];
            [self performSegueWithIdentifier:@"DataViewSegue" sender:self];

        } else if ([textField.accessibilityIdentifier isEqualToString:@"contact_buyingpower"]) {
            [appDelegate setPageObject:nil];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:13 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            [appDelegate setPageController:PageBuyingPower];
            [appDelegate setPageRequest:PageRequest_Contact_BuyingPower];
            [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
            
        } else if ([textField.accessibilityIdentifier isEqualToString:@"contact_currentemployee"]) {
            if ([appDelegate isEmptyString:self.contact_currentemployee.text]) {
                [_contact setValue:[NSNumber numberWithBool:YES] forKey:self.contact_currentemployee.accessibilityIdentifier];
                self.contact_currentemployee.text=@"Yes";
     
            } else {
                if ([self.contact_currentemployee.text isEqualToString:@"Yes"]) {
                    [_contact setValue:[NSNumber numberWithBool:NO] forKey:self.contact_currentemployee.accessibilityIdentifier];
                    self.contact_currentemployee.text=@"No";
                    
                } else {
                    [_contact setValue:[NSNumber numberWithBool:YES] forKey:self.contact_currentemployee.accessibilityIdentifier];
                    self.contact_currentemployee.text=@"Yes";
                }
            }
        }
            
        return NO;
    }
    return YES;
}


#pragma mark - UITableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
     DebugLog(@"section %ld , row %ld",(long)indexPath.section,(long)indexPath.row);
    self.navigationItem.title=@"Contact";
    if (indexPath.section == 0 && indexPath.row == 9) {//Birthday
        [self showBirthDates];
        
    } else if (indexPath.section == 0 && indexPath.row == 13) { //Buying power
        [appDelegate setPageController:PageBuyingPower];
        [appDelegate setPageRequest:PageRequest_Contact_BuyingPower];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];

    } else if (indexPath.section == 0 && indexPath.row == 14) { //Support Level
        [appDelegate setPageController:PageSupportLevel];
        [appDelegate setPageRequest:PageRequest_Contact_SupportLevel];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 0 && indexPath.row == 15) { //Current Employee
     
        if ([appDelegate isEmptyString:self.contact_currentemployee.text]) {
             [_contact setValue:[NSNumber numberWithBool:YES] forKey:self.contact_currentemployee.accessibilityIdentifier];
            self.contact_currentemployee.text=@"Yes";
            
        } else {
            if ([self.contact_currentemployee.text isEqualToString:@"Yes"]) {
                [_contact setValue:[NSNumber numberWithBool:NO] forKey:self.contact_currentemployee.accessibilityIdentifier];
                self.contact_currentemployee.text=@"No";
                
            } else {
                [_contact setValue:[NSNumber numberWithBool:YES] forKey:self.contact_currentemployee.accessibilityIdentifier];
                 self.contact_currentemployee.text=@"Yes";
            }
        }
    }else if (indexPath.section == 1 && indexPath.row == 0) {//ConUserDef1
        [appDelegate setPageController:PageConUserDef1];
        [appDelegate setPageRequest:PageRequest_Contact_ConUserDef1];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 1 && indexPath.row == 1) {//ConUserDef2
        [appDelegate setPageController:PageConUserDef2];
        [appDelegate setPageRequest:PageRequest_Contact_ConUserDef2];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 1 && indexPath.row == 2) {//ConUserDef3
        [appDelegate setPageController:PageConUserDef3];
        [appDelegate setPageRequest:PageRequest_Contact_ConUserDef3];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 1 && indexPath.row == 3) {//ConUserDef4
        [appDelegate setPageController:PageConUserDef4];
        [appDelegate setPageRequest:PageRequest_Contact_ConUserDef4];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 35;
    if (indexPath.section == 0 && indexPath.row == 11) {
        
        if (![appDelegate isEmptyString:self.contact_chn_b_days.text]) {
        
            if ([self numberOfLinesForTextView:self.contact_chn_b_days containingString:_contact.contact_chn_b_days] > 1) {
                if (self.contact_chn_b_days.contentSize.height > rowHeight) {
                    rowHeight=[self heightForTextView:self.contact_chn_b_days containingString:_contact.contact_chn_b_days] + 8;
                }
            }
        }
        self.contact_chn_b_days.frame=CGRectMake(self.contact_chn_b_days.frame.origin.x,
                                              self.contact_chn_b_days.frame.origin.y,
                                              self.contact_chn_b_days.frame.size.width, rowHeight);
        
    } else  if (indexPath.section == 0 && indexPath.row == 12) {
        if (![appDelegate isEmptyString:self.contact_hobbies.text]) {
            
            if ([self numberOfLinesForTextView:self.contact_hobbies containingString:_contact.contact_hobbies] > 1) {
                if (self.contact_hobbies.contentSize.height > rowHeight ) {
                    rowHeight=[self heightForTextView:self.contact_hobbies containingString:_contact.contact_hobbies] + 8;
                }
            }
        }
        self.contact_hobbies.frame=CGRectMake(self.contact_hobbies.frame.origin.x,
                                              self.contact_hobbies.frame.origin.y,
                                              self.contact_hobbies.frame.size.width, rowHeight);
        
    }else  if (indexPath.section == 1 && indexPath.row == 5) {
         rowHeight = 200;
        if (![appDelegate isEmptyString:self.contact_notes.text]) {
            
            if ([self numberOfLinesForTextView:self.contact_notes containingString:_contact.contact_notes] > 1) {
                if (self.contact_notes.contentSize.height > rowHeight) {
                    rowHeight=[self heightForTextView:self.contact_notes containingString:_contact.contact_notes] + 8;
                }
            }

        }
    }
    return rowHeight;
}

#pragma Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HelpTextViewSegue"]) {
        [segue.destinationViewController helpTextInfo:CONTACTS_HELPTEXT];
    }
}

#pragma mark - Methods
- (void) syncSoftLabels {
    SoftLabels *softlabels=(SoftLabels*)[persistenceManager entityObject:ENTITY_SOFTLABELS];
    self.info_contact_conuserdef1.text=@"";
    self.contact_conuserdef1_data.placeholder=@"";
    self.info_contact_conuserdef2.text=@"";
    self.contact_conuserdef2_data.placeholder=@"";
    self.info_contact_conuserdef3.text=@"";
    self.contact_conuserdef3_data.placeholder=@"";
    self.info_contact_conuserdef4.text=@"";
    self.contact_conuserdef4_data.placeholder=@"";
    
    if (softlabels.conuserdef1) {
        if (![softlabels.conuserdef1.disposal boolValue]) {
            self.info_contact_conuserdef1.text=softlabels.conuserdef1.conuserdef_name;
            self.contact_conuserdef1_data.placeholder=softlabels.conuserdef1.conuserdef_name;
        }
        
    }
    if (softlabels.conuserdef2) {
        if (![softlabels.conuserdef2.disposal boolValue]) {
            self.info_contact_conuserdef2.text=softlabels.conuserdef2.conuserdef_name;
            self.contact_conuserdef2_data.placeholder=softlabels.conuserdef2.conuserdef_name;
        }
        
    }
    if (softlabels.conuserdef3) {
        if (![softlabels.conuserdef3.disposal boolValue]) {
            self.info_contact_conuserdef3.text=softlabels.conuserdef3.conuserdef_name;
            self.contact_conuserdef3_data.placeholder=softlabels.conuserdef3.conuserdef_name;
        }
        
    }
    if (softlabels.conuserdef4) {
        if (![softlabels.conuserdef4.disposal boolValue]) {
            self.info_contact_conuserdef4.text=softlabels.conuserdef4.conuserdef_name;
            self.contact_conuserdef4_data.placeholder=softlabels.conuserdef4.conuserdef_name;
        }
    }
}




@end
