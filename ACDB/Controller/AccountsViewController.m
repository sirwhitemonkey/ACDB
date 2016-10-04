//
//  AccountsViewController.m
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "AccountsViewController.h"

@interface AccountsViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property(nonatomic,strong)UIBarButtonItem *infoBtn;
@property(nonatomic,strong)UIBarButtonItem *doneBtn;

@end

@implementation AccountsViewController

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
    
    [self syncAccount];
    
    /*
    if (IS_IOS_7) {
        [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                                  NSForegroundColorAttributeName : [UIColor blackColor]
                                                                  } forState:UIControlStateNormal];
    } else {
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13], UITextAttributeFont,
                                    [UIColor blackColor], UITextAttributeTextColor,
                                    nil];
        [[UISegmentedControl appearance]  setTitleTextAttributes:attributes forState:UIControlStateNormal];
    } */
    
    [UISegmentedControl appearance].tintColor=self.navigationController.navigationBar.tintColor;
    
    UISegmentedControl *allContacts = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All Contacts", nil]];
    allContacts.momentary = YES;
    allContacts.tag=0;
    [allContacts addTarget:self action:@selector(options:) forControlEvents:UIControlEventValueChanged];
   
    UISegmentedControl *discussions = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Discussions", nil]];
    discussions.momentary = YES;
    discussions.tag=1;
    [discussions addTarget:self action:@selector(options:) forControlEvents:UIControlEventValueChanged];
   
    UISegmentedControl *newdiscussion = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"New Discussion", nil]];
    newdiscussion.momentary = YES;
    newdiscussion.tag=2;
    [newdiscussion addTarget:self action:@selector(options:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *allContactsbtn = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)allContacts];
     UIBarButtonItem *discussionsbtn = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)discussions];
     UIBarButtonItem *newdiscussionbtn = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)newdiscussion];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, allContactsbtn, flexibleSpace,discussionsbtn,flexibleSpace,newdiscussionbtn,
                         flexibleSpace, nil];
    
    [self.controlOptions setItems:barArray animated:YES];
    
    [self.controlOptions setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [self.controlOptions setShadowImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny];
   
    if (IS_IOS_7) {
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
        self.type.alpha=0.40f;
        self.accuserdef1Option.alpha=0.40f;
        self.accuserdef2Option.alpha=0.40f;
        self.accuserdef3Option.alpha=0.40f;
        self.accuserdef4Option.alpha=0.40f;
    }
    
    UITapGestureRecognizer*viewMapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewMap:)];
    [self.viewMap setUserInteractionEnabled:YES];
    [self.viewMap addGestureRecognizer:viewMapGesture];
    
    UITapGestureRecognizer*viewGoogleMapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewGoogleMap:)];
    [self.viewGoogleMap setUserInteractionEnabled:YES];
    [self.viewGoogleMap addGestureRecognizer:viewGoogleMapGesture];
    
 }

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
    [self syncSoftLabels];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [appDelegate setPageController:PageAccounts];
    }
    [persistenceManager saveContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.title=@"Account";
    NSIndexPath *indexPath;
    
    BOOL scroll=true;
    
    SoftLabels *softlabels=(SoftLabels*)[persistenceManager  entityObject:ENTITY_SOFTLABELS];
    
    if (![appDelegate pageObject]) {
        [appDelegate setAcdbAccount:(ACDBAccount*)[persistenceManager  entityObject:ENTITY_ACCOUNT
                                                                                       uuid:[appDelegate acdbAccount].uuid]];
    }
    
    switch((int)[appDelegate pageRequest]) {
        case PageRequest_Account_PrimaryContact:
        case PageRequest_Account_SecondaryContact:
        case PageRequest_Account_BillingContact:
        case PageRequest_Account_AccountsContact:
        {
            if (![appDelegate pageObject]) {
                if ([appDelegate pageRequest] == PageRequest_Account_AccountsContact) {
                    [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_accounts];
                    self.account_accounts.text=@"";
                }else if ([appDelegate pageRequest] == PageRequest_Account_BillingContact) {
                    [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_billing];
                    self.account_billing.text=@"";
                } else if ([appDelegate pageRequest] == PageRequest_Account_PrimaryContact) {
                    [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_primarycontact];
                    self.account_primarycontact.text=@"";
                } else if ([appDelegate pageRequest] == PageRequest_Account_SecondaryContact) {
                    [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_secondarycontact];
                    self.account_secondarycontact.text=@"";
                }
                scroll=false;
            }
            
            NSString *firstname=@"";
            NSString *lastname=@"";
            NSString *mycontact;
            Contact *contact;
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[Contact class]]) {
                contact=(Contact*)[appDelegate pageObject];
                if (![appDelegate isEmptyString:contact.contact_nickname]) {
                    firstname=contact.contact_nickname;
                } else {
                    if (![appDelegate isEmptyString:contact.contact_firstname]) {
                        firstname=contact.contact_firstname;
                    }
                }
                if (![appDelegate isEmptyString:contact.contact_lastname]) {
                    lastname=contact.contact_lastname;
                }
                mycontact=[NSString stringWithFormat:@"%@ %@",firstname , lastname];
            }
            
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[Contact class]]) {
                if ([appDelegate pageRequest] == PageRequest_Account_AccountsContact) {
                    self.account_accounts.text=mycontact;
                    [appDelegate acdbAccount].account_accounts=contact;
                    indexPath = [NSIndexPath indexPathForRow:3 inSection:2];
                }else if ([appDelegate pageRequest] == PageRequest_Account_BillingContact) {
                    self.account_billing.text=mycontact;
                    [appDelegate acdbAccount].account_billing=contact;
                    indexPath = [NSIndexPath indexPathForRow:2 inSection:2];
                } else if ([appDelegate pageRequest] == PageRequest_Account_PrimaryContact) {
                    self.account_primarycontact.text=mycontact;
                    [appDelegate acdbAccount].account_primarycontact=contact;
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
                    
                } else if ([appDelegate pageRequest] == PageRequest_Account_SecondaryContact) {
                    self.account_secondarycontact.text=mycontact;
                    [appDelegate acdbAccount].account_secondarycontact=contact;
                    indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
                }
                if (scroll) {
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
            }
        }
            break;
           
        case PageRequest_Account_MailingCountry:
            if (![appDelegate pageObject]) {
                [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_country];
                self.account_country.text=@"";
                self.info_account_streetaddr3.text=@"City";
                self.info_account_streetaddr4.text=@"State | Zip";
                self.account_streetaddr3.placeholder=@"City";
                self.account_streetaddr4.placeholder=@"State";
                self.account_streetaddr4_.placeholder=@"Zip";
                scroll=false;
            }
            
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[Country class]]) {
                Country *country = (Country*)[appDelegate pageObject];
                self.account_country.text=country.country_name;
                self.info_account_streetaddr3.text=country.country_mailingpostal1;
                self.info_account_streetaddr4.text=country.country_mailingpostal2;
                self.account_streetaddr3.placeholder=country.country_mailingpostal1;
                NSArray *streetaddr4=[country.country_mailingpostal2 componentsSeparatedByString:@"|"];
                self.account_streetaddr4.placeholder=[streetaddr4 objectAtIndex:0];
                self.account_streetaddr4_.placeholder=[streetaddr4 objectAtIndex:1];
                
                
                if (scroll) {
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                
                [appDelegate acdbAccount].account_country=country;
                [country addAccount_countryObject:[appDelegate acdbAccount]];
                
                if ([appDelegate isEmptyString:self.account_streetaddr1.text]) {
                    [self.account_streetaddr1 becomeFirstResponder];
                } else if ([appDelegate isEmptyString:self.account_streetaddr2.text]) {
                    [self.account_streetaddr2 becomeFirstResponder];
                } else if ([appDelegate isEmptyString:self.account_streetaddr3.text]) {
                    [self.account_streetaddr3 becomeFirstResponder];
                }else if ([appDelegate isEmptyString:self.account_streetaddr4.text]) {
                    [self.account_streetaddr4 becomeFirstResponder];
                }else if ([appDelegate isEmptyString:self.account_streetaddr4_.text]) {
                    [self.account_streetaddr4_ becomeFirstResponder];
                }
                
            }
             break;
            
        case PageRequest_Account_PostalCountry:
            if (![appDelegate pageObject])  {
                [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_postalcountry];
                self.account_postalcountry.text=@"";
                self.info_account_postaladdr3.text=@"City";
                self.info_account_postaladdr4.text=@"State | Zip";
                self.account_postaladdr3.placeholder=@"City";
                self.account_postaladdr4.placeholder=@"State";
                self.account_postaladdr4_.placeholder=@"Zip";
                scroll=false;
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[Country class]]) {
                Country *postalcountry = (Country*)[appDelegate pageObject];
                self.account_postalcountry.text=postalcountry.country_name;
                self.info_account_postaladdr3.text=postalcountry.country_mailingpostal1;
                self.info_account_postaladdr4.text=postalcountry.country_mailingpostal2;
                self.account_postaladdr3.placeholder=postalcountry.country_mailingpostal1;
                NSArray *postaladdr4=[postalcountry.country_mailingpostal2 componentsSeparatedByString:@"|"];
                self.account_postaladdr4.placeholder=[postaladdr4 objectAtIndex:0];
                self.account_postaladdr4_.placeholder=[postaladdr4 objectAtIndex:1];

                if (scroll) {
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                
                [appDelegate acdbAccount].account_postalcountry=postalcountry;
                [postalcountry addAccount_postalcountryObject:[appDelegate acdbAccount]];
                
                if ([appDelegate isEmptyString:self.account_postaladdr1.text]) {
                    [self.account_postaladdr1 becomeFirstResponder];
                } else if ([appDelegate isEmptyString:self.account_postaladdr2.text]) {
                    [self.account_postaladdr2 becomeFirstResponder];
                } else if ([appDelegate isEmptyString:self.account_postaladdr3.text]) {
                    [self.account_postaladdr3 becomeFirstResponder];
                }else if ([appDelegate isEmptyString:self.account_postaladdr4.text]) {
                    [self.account_postaladdr4 becomeFirstResponder];
                }else if ([appDelegate isEmptyString:self.account_postaladdr4_.text]) {
                    [self.account_postaladdr4_ becomeFirstResponder];
                }

            }
            
            break;
            
        case PageRequest_Account_Relationship:
            if (![appDelegate pageObject]) {
                [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_relationship];
                self.account_relationship.text=@"";
                scroll=false;
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[Relationship class]]) {
                Relationship *relationship=(Relationship*)[appDelegate pageObject];
                self.account_relationship.text=relationship.relationship_name;
                
                if (scroll) {
                    indexPath = [NSIndexPath indexPathForRow:2 inSection:5];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                
                [appDelegate acdbAccount].account_relationship=relationship;
                [relationship addRelationshipObject:[appDelegate acdbAccount]];
            }
           
            break;
            
        case PageRequest_Account_StdInClass:
            if (![appDelegate pageObject]) {
                [appDelegate setPageObject:(NSManagedObject*)[appDelegate acdbAccount].account_stdinclass];
                self.account_stdinclass.text=@"";
                scroll=false;
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[StdInClass class]]) {
                StdInClass *stdinclass=(StdInClass*)[appDelegate pageObject];
                self.account_stdinclass.text=stdinclass.stdinclass_name;
                
                if(scroll){
                    indexPath = [NSIndexPath indexPathForRow:3 inSection:5];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                 [appDelegate acdbAccount].account_stdinclass=stdinclass;
                [stdinclass addStdinclassObject:[appDelegate acdbAccount]];
            }
            break;
        case PageRequest_Account_AccountNames:
            if (![appDelegate pageObject]) {
                if (!softlabels.accountnames) {
                    self.info_account_accountnames.text=@"";
                    self.account_accountnames_data.placeholder=@"";
                }
            }
           
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[AccountNames class]]) {
                AccountNames *accountnames=(AccountNames*)[appDelegate pageObject];
                self.info_account_accountnames.text=accountnames.accountnames_name;
                self.account_accountnames_data.placeholder=accountnames.accountnames_name;
                softlabels.accountnames=accountnames;
                [accountnames addAccountnamesObject:softlabels];
            }
            break;
        case PageRequest_Account_AccUserDef1:
            if (![appDelegate pageObject]) {
                scroll=false;
                if (!softlabels.accuserdef1) {
                    self.info_account_accuserdef1.text=@"";
                    self.account_accuserdef1_data.placeholder=@"";
                }
             }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[AccUserDef1 class]]) {
                AccUserDef1 *accuserdef1=(AccUserDef1*)[appDelegate pageObject];
                self.info_account_accuserdef1.text=accuserdef1.accuserdef_name;
                self.account_accuserdef1_data.placeholder=accuserdef1.accuserdef_name;
                if(scroll){
                    indexPath = [NSIndexPath indexPathForRow:5 inSection:5];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.accuserdef1=accuserdef1;
                [accuserdef1 addAccuserdef1Object:softlabels];
            }
            break;
        case PageRequest_Account_AccUserDef2:
            if (![appDelegate pageObject]) {
                scroll=false;
                if (!softlabels.accuserdef2) {
                    self.info_account_accuserdef2.text=@"";
                    self.account_accuserdef2_data.placeholder=@"";
                }
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[AccUserDef2 class]]) {
                AccUserDef2 *accuserdef2=(AccUserDef2*)[appDelegate pageObject];
                self.info_account_accuserdef2.text=accuserdef2.accuserdef_name;
                self.account_accuserdef2_data.placeholder=accuserdef2.accuserdef_name;
                if(scroll){
                    indexPath = [NSIndexPath indexPathForRow:6 inSection:5];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.accuserdef2=accuserdef2;
                [accuserdef2 addAccuserdef2Object:softlabels];
            }
            break;
        case PageRequest_Account_AccUserDef3:
            if (![appDelegate pageObject]) {
                scroll=false;
                if (!softlabels.accuserdef3) {
                    self.info_account_accuserdef3.text=@"";
                    self.account_accuserdef3_data.placeholder=@"";
                }
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[AccUserDef3 class]]) {
                AccUserDef3 *accuserdef3=(AccUserDef3*)[appDelegate pageObject];
                self.info_account_accuserdef3.text=accuserdef3.accuserdef_name;
                self.account_accuserdef3_data.placeholder=accuserdef3.accuserdef_name;
                if(scroll){
                    indexPath = [NSIndexPath indexPathForRow:7 inSection:5];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.accuserdef3=accuserdef3;
                [accuserdef3 addAccuserdef3Object:softlabels];
            }
            break;
        case PageRequest_Account_AccUserDef4:
            if (![appDelegate pageObject]) {
                scroll=false;
                if (!softlabels.accuserdef4) {
                    self.info_account_accuserdef4.text=@"";
                    self.account_accuserdef4_data.placeholder=@"";
                }
            }
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[AccUserDef4 class]]) {
                AccUserDef4 *accuserdef4=(AccUserDef4*)[appDelegate pageObject];
                self.info_account_accuserdef4.text=accuserdef4.accuserdef_name;
                self.account_accuserdef4_data.placeholder=accuserdef4.accuserdef_name;
                if(scroll){
                    indexPath = [NSIndexPath indexPathForRow:8 inSection:5];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
                softlabels.accuserdef4=accuserdef4;
                [accuserdef4 addAccuserdef4Object:softlabels];
            }
            break;

    }
    self.navigationController.navigationBar.translucent=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

-(IBAction)options:(id)sender
{
    NSSortDescriptor *name = nil;
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    switch(((UISegmentedControl*)sender).tag) {
        case 0:
            name = [[NSSortDescriptor alloc] initWithKey:@"uuid" ascending:YES];
            results = [[appDelegate acdbAccount].account_contacts sortedArrayUsingDescriptors:[NSArray arrayWithObjects:name, nil]];
            predicate = [NSPredicate predicateWithFormat:@"disposal == %@",[NSNumber numberWithBool:NO]];
            results = [results filteredArrayUsingPredicate:predicate];
           
            [appDelegate setPageObject:nil];
            [appDelegate setPageRequest:PageRequest_Account_AllContacts];
            if (results.count > 0) {
                [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
            } else {
                [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
            }
            break;
            
        case 1:
            name = [[NSSortDescriptor alloc] initWithKey:@"uuid" ascending:YES];
            results = [[appDelegate acdbAccount].account_discussions sortedArrayUsingDescriptors:[NSArray arrayWithObjects:name, nil]];
            predicate = [NSPredicate predicateWithFormat:@"disposal == %@",[NSNumber numberWithBool:NO]];
            results = [results filteredArrayUsingPredicate:predicate];
          
            [appDelegate setPageObject:nil];
            if (results.count > 0) {
                [appDelegate setPageRequest:PageRequest_Account_Discussions];
                [self performSegueWithIdentifier:@"DiscussionsDataViewSegue" sender:self];
            } else {
                [appDelegate setPageObject:nil];
                [appDelegate setPageRequest:PageRequest_Account_NewDiscussion];
                [self performSegueWithIdentifier:@"DiscussionsViewSegue" sender:self];
            }
            break;
            
        case 2:
            [appDelegate setPageObject:nil];
            [appDelegate setPageRequest:PageRequest_Account_NewDiscussion];
            [self performSegueWithIdentifier:@"DiscussionsViewSegue" sender:self];
            break;
    }
    [self performSelector:@selector(removeSelection:) withObject:sender afterDelay:1.5];
}

-(void)removeSelection:(UISegmentedControl*)segmentedControl
{
    segmentedControl.selectedSegmentIndex=-1;
}

-(IBAction)phoneCall:(id)sender
{
    NSString *phonenumber=self.account_contactmainphone.text;
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    phonenumber=[phonenumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ( [appDelegate isEmptyString:phonenumber]) {
        [appDelegate alert:[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Phone number"]];
        
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

-(IBAction)helpText:(id)sender
{
    [self performSegueWithIdentifier:@"HelpTextViewSegue" sender:self];
}

-(IBAction)website:(id)sender
{
    if ([appDelegate isEmptyString:self.account_website.text]) {
        [appDelegate alert:[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Website"]];
        return;
    }
    
    BOOL http = [[self.account_website.text lowercaseString] rangeOfString:@"http"].length > 0;
    BOOL https = [[self.account_website.text lowercaseString] rangeOfString:@"https"].length > 0;
    
    NSString *website;
    if (!http && !https) {
        website=[NSString stringWithFormat:@"http://%@",self.account_website.text];
    }  else {
        website=self.account_website.text;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:website]];
}

-(IBAction)accountnames:(id)sender
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [appDelegate setPageController:PageAccountNames];
    [appDelegate setPageRequest:PageRequest_Account_AccountNames];
    [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
}

-(IBAction)accuserdefs:(id)sender
{
    NSIndexPath *indexPath;
    switch(((UIButton*)sender).tag) {
        case 0:
            [appDelegate setPageController:PageAccUserDef1];
            [appDelegate setPageRequest:PageRequest_Account_AccUserDef1];
            indexPath=[NSIndexPath indexPathForRow:5 inSection:5];
            break;
        case 1:
            [appDelegate setPageController:PageAccUserDef2];
            [appDelegate setPageRequest:PageRequest_Account_AccUserDef2];
             indexPath=[NSIndexPath indexPathForRow:6 inSection:5];
            break;
        case 2:
            [appDelegate setPageController:PageAccUserDef3];
            [appDelegate setPageRequest:PageRequest_Account_AccUserDef3];
             indexPath=[NSIndexPath indexPathForRow:7 inSection:5];
            break;
        case 3:
            [appDelegate setPageController:PageAccUserDef4];
            [appDelegate setPageRequest:PageRequest_Account_AccUserDef4];
             indexPath=[NSIndexPath indexPathForRow:8 inSection:5];
            break;
    }
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"DataViewSegue" sender:self];

    
}


-(void) setFields
{
    self.account_name.accessibilityIdentifier = @"account_name";
    self.account_accountnames_data.accessibilityIdentifier = @"account_accountnames_data";
    self.account_contactmainphone.accessibilityIdentifier = @"account_contactmainphone";
    self.account_primarycontact.accessibilityIdentifier = @"account_primarycontact";
    self.account_secondarycontact.accessibilityIdentifier = @"account_secondarycontact";
    self.account_billing.accessibilityIdentifier = @"account_billing";
    self.account_accounts.accessibilityIdentifier = @"account_accounts";
    self.account_streetaddr1.accessibilityIdentifier = @"account_streetaddr1";
    self.account_streetaddr2.accessibilityIdentifier = @"account_streetaddr2";
    self.account_streetaddr3.accessibilityIdentifier = @"account_streetaddr3";
    self.account_streetaddr4.accessibilityIdentifier = @"account_streetaddr4";
    self.account_streetaddr4_.accessibilityIdentifier = @"account_streetaddr4";
    self.account_country.accessibilityIdentifier = @"account_country";
    self.account_postaladdr1.accessibilityIdentifier = @"account_postaladdr1";
    self.account_postaladdr2.accessibilityIdentifier = @"account_postaladdr2";
    self.account_postaladdr3.accessibilityIdentifier = @"account_postaladdr3";
    self.account_postaladdr4.accessibilityIdentifier = @"account_postaladdr4";
    self.account_postaladdr4_.accessibilityIdentifier = @"account_postaladdr4";
    self.account_postalcountry.accessibilityIdentifier = @"account_postalcountry";
    self.account_employees.accessibilityIdentifier = @"account_employees";
    self.account_warning.accessibilityIdentifier = @"account_warning";
    self.account_website.accessibilityIdentifier = @"account_website";
    self.account_relationship.accessibilityIdentifier = @"account_relationship";
    self.account_stdinclass.accessibilityIdentifier = @"account_stdinclass";
    self.account_accuserdef1_data.accessibilityIdentifier = @"account_accuserdef1_data";
    self.account_accuserdef2_data.accessibilityIdentifier = @"account_accuserdef2_data";
    self.account_accuserdef3_data.accessibilityIdentifier = @"account_accuserdef3_data";
    self.account_accuserdef4_data.accessibilityIdentifier = @"account_accuserdef4_data";
    self.account_notes.accessibilityIdentifier = @"account_notes";
}

#pragma mark - UITableView

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    [appDelegate setPageObject:nil];
    
    DebugLog(@"section %ld , row %ld",(long)indexPath.section,(long)indexPath.row);
    self.navigationItem.title=@"Account";
    
    [self.view endEditing:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {//type
        [appDelegate setPageController:PageAccountNames];
        [appDelegate setPageRequest:PageRequest_Account_AccountNames];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }
    if (indexPath.section == 2 && indexPath.row == 0) {//Primary contact
        [appDelegate setPageController:PageContacts];
        [appDelegate setPageRequest:PageRequest_Account_PrimaryContact];
        [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {//Secondary contact
        [appDelegate setPageController:PageContacts];
        [appDelegate setPageRequest:PageRequest_Account_SecondaryContact];
        [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
        
    } else if (indexPath.section == 2 && indexPath.row == 2) {//Billing contact
        [appDelegate setPageController:PageContacts];
        [appDelegate setPageRequest:PageRequest_Account_BillingContact];
        [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
        
    } else if (indexPath.section == 2 && indexPath.row == 3) {//Accounts contact
        [appDelegate setPageController:PageContacts];
        [appDelegate setPageRequest:PageRequest_Account_AccountsContact];
        [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
        
    } else if (indexPath.section == 3 && indexPath.row == 4) {//Mailing country
        [appDelegate setPageController:PageCountry];
        [appDelegate setPageRequest:PageRequest_Account_MailingCountry];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 3 && indexPath.row == 5) {//Mailing map
        
        
    }else if (indexPath.section == 4 && indexPath.row == 4) {//Postal country
        [appDelegate setPageController:PageCountry];
        [appDelegate setPageRequest:PageRequest_Account_PostalCountry];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 5 && indexPath.row == 2) {//Relationship
        [appDelegate setPageController:PageRelationship];
        [appDelegate setPageRequest:PageRequest_Account_Relationship];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 5 && indexPath.row == 3) {//StdInClass
        [appDelegate setPageController:PageStdInClass];
        [appDelegate setPageRequest:PageRequest_Account_StdInClass];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 5 && indexPath.row == 5) {//AccUserDef1
        [appDelegate setPageController:PageAccUserDef1];
        [appDelegate setPageRequest:PageRequest_Account_AccUserDef1];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 5 && indexPath.row == 6) {//AccUserDef2
        [appDelegate setPageController:PageAccUserDef2];
        [appDelegate setPageRequest:PageRequest_Account_AccUserDef2];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 5 && indexPath.row == 7) {//AccUserDef3
        [appDelegate setPageController:PageAccUserDef3];
        [appDelegate setPageRequest:PageRequest_Account_AccUserDef3];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }else if (indexPath.section == 5 && indexPath.row == 8) {//AccUserDef4
        [appDelegate setPageController:PageAccUserDef4];
        [appDelegate setPageRequest:PageRequest_Account_AccUserDef4];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    }


    

    
}


#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HelpTextViewSegue"]) {
         [segue.destinationViewController helpTextInfo:ACCOUNTS_HELPTEXT];
    } else if ([segue.identifier isEqualToString:@"MapViewSegue"]) {
        [segue.destinationViewController setAddressString:[self getAddress]];
    } else if ([segue.identifier isEqualToString:@"ContactsDataViewSegue"]) {
        
    }else if ([segue.identifier isEqualToString:@"DiscussionsDataViewSegue"]) {
        
    }else if ([segue.identifier isEqualToString:@"DiscussionsViewSegue"]) {
    }
}

#pragma mark - UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //if ([text isEqualToString:@"\n"]) {
    //    [textView resignFirstResponder];
    //}
    [[appDelegate acdbAccount] setValue:[appDelegate trim:textView.text] forKey:textView.accessibilityIdentifier];
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView
{
    if ([textView.accessibilityIdentifier isEqualToString:@"account_notes"]) {
        [appDelegate acdbAccount].account_notes=textView.text;
    }
    
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.accessibilityIdentifier isEqualToString:@"account_notes"]) {
        [self performSelector:@selector(positionAccountNotes) withObject:nil afterDelay:1.0];
    }
    
    
}

- (void)positionAccountNotes {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:5]
                                animated:YES scrollPosition:UITableViewScrollPositionTop];
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
    
    if ([textField.accessibilityIdentifier isEqualToString:@"account_employees"]){
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
        
    } else if ([textField.accessibilityIdentifier isEqualToString:@"account_contactmainphone"]) {
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




- (void) textFieldEditing:(UITextField*)textField
{
    NSString *value = textField.text;
 
    if ([textField.accessibilityIdentifier isEqualToString:@"account_name"]) {
        self.account_renotes.text = [NSString stringWithFormat:@"Notes re %@", [appDelegate capitalizeAllWords:textField.text]];
    }
    
    if ([textField.accessibilityIdentifier isEqualToString:@"account_name"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_accountnames_data"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr1"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr2"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr3"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr1"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr2"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr3"] ) {
        value=[appDelegate capitalizeAllWords:textField.text];
    }
    
    
    if ([textField.accessibilityIdentifier isEqualToString:@"account_streetaddr4"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr4_"]) {
        value=[NSString stringWithFormat:@"%@ | %@", [appDelegate trim:[self.account_streetaddr4.text uppercaseString]],
               [appDelegate trim:[self.account_streetaddr4_.text uppercaseString]]];
    }
    
    if ([textField.accessibilityIdentifier isEqualToString:@"account_postaladdr4"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr4_"]) {
        value=[NSString stringWithFormat:@"%@ | %@", [appDelegate trim:[self.account_postaladdr4.text uppercaseString]],
               [appDelegate trim:[self.account_postaladdr4_.text uppercaseString]]];
    }
    [[appDelegate acdbAccount] setValue: [appDelegate trim:value] forKey:textField.accessibilityIdentifier];
}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if ([textField.accessibilityIdentifier isEqualToString:@"account_primarycontact"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_secondarycontact"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_billing"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_accounts"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_country"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postalcountry"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_relationship"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_stdinclass"]) {
        
        [self.view endEditing:YES];
        
        [appDelegate setPageObject:nil];
        
        if ([textField.accessibilityIdentifier isEqualToString:@"account_country"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:3] animated:YES scrollPosition:UITableViewScrollPositionNone];
            [appDelegate setPageController:PageCountry];
            [appDelegate setPageRequest:PageRequest_Account_MailingCountry];
            [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
            
        } else if ([textField.accessibilityIdentifier isEqualToString:@"account_postalcountry"]) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:4] animated:YES scrollPosition:UITableViewScrollPositionNone];
            [appDelegate setPageController:PageCountry];
            [appDelegate setPageRequest:PageRequest_Account_PostalCountry];
            [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
            
        } else if ([textField.accessibilityIdentifier isEqualToString:@"account_primarycontact"]) {
            self.navigationItem.title=@"Account";
            if ([appDelegate acdbAccount].account_primarycontact) {
                if (![[appDelegate acdbAccount].account_primarycontact.disposal boolValue]) {
                    [appDelegate setPageObject:[appDelegate acdbAccount].account_primarycontact];
                    [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
                    
                } else {
                    [appDelegate alert:[SOURCE_REMOVED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Contact"]];
                }
                
            } else {
                [appDelegate setPageController:PageContacts];
                [appDelegate setPageRequest:PageRequest_Account_PrimaryContact];
                [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
                
                
                
            }
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }else if ([textField.accessibilityIdentifier isEqualToString:@"account_secondarycontact"]) {
            self.navigationItem.title=@"Account";
            if ([appDelegate acdbAccount].account_secondarycontact) {
                if (![[appDelegate acdbAccount].account_secondarycontact.disposal boolValue]) {
                    [appDelegate setPageObject:[appDelegate acdbAccount].account_secondarycontact];
                    [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
                } else {
                    [appDelegate alert:[SOURCE_REMOVED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Contact"]];
                }
                
                
            } else {
                [appDelegate setPageController:PageContacts];
                [appDelegate setPageRequest:PageRequest_Account_SecondaryContact];
                [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
               
                
            }
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }else if ([textField.accessibilityIdentifier isEqualToString:@"account_billing"]) {
            self.navigationItem.title=@"Account";
            DebugLog(@"%@",[appDelegate acdbAccount].account_billing);
            
            if ([appDelegate acdbAccount].account_billing) {
                if (![[appDelegate acdbAccount].account_billing.disposal boolValue]) {
                    [appDelegate setPageObject:[appDelegate acdbAccount].account_billing];
                    [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
                } else {
                    [appDelegate alert:[SOURCE_REMOVED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Contact"]];
                }
                
                
            } else {
                [appDelegate setPageController:PageContacts];
                [appDelegate setPageRequest:PageRequest_Account_BillingContact];
                [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
                
            }
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }else if ([textField.accessibilityIdentifier isEqualToString:@"account_accounts"]) {
            self.navigationItem.title=@"Account";
            if ([appDelegate acdbAccount].account_accounts) {
                if (![[appDelegate acdbAccount].account_accounts.disposal boolValue]) {
                    [appDelegate setPageObject:[appDelegate acdbAccount].account_accounts];
                    [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
                } else {
                    [appDelegate alert:[SOURCE_REMOVED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Contact"]];
                }
                
            } else {
                [appDelegate setPageController:PageContacts];
                [appDelegate setPageRequest:PageRequest_Account_AccountsContact];
                [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
                
                
            }
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }else if ([textField.accessibilityIdentifier isEqualToString:@"account_relationship"]) {
           [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:5] animated:YES scrollPosition:UITableViewScrollPositionNone];
            [appDelegate setPageController:PageRelationship];
            [appDelegate setPageRequest:PageRequest_Account_Relationship];
            [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
            
        }else if ([textField.accessibilityIdentifier isEqualToString:@"account_stdinclass"]) {
           [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:5] animated:YES scrollPosition:UITableViewScrollPositionNone];
            [appDelegate setPageController:PageStdInClass];
            [appDelegate setPageRequest:PageRequest_Account_StdInClass];
            [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        }
    
        return NO;
        
    } else {
        if ([textField.accessibilityIdentifier isEqualToString:@"account_streetaddr1"] ||
            [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr2"] ||
            [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr3"] ||
            [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr4"] ||
            [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr4_"]) {
            
            if ([appDelegate isEmptyString:self.account_country.text]) {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:3] animated:YES scrollPosition:UITableViewScrollPositionNone];
                [appDelegate setPageObject:nil];
                [appDelegate setPageController:PageCountry];
                [appDelegate setPageRequest:PageRequest_Account_MailingCountry];
                [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
                return NO;
            }
        }
        
        if ([textField.accessibilityIdentifier isEqualToString:@"account_postaladdr1"] ||
            [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr2"] ||
            [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr3"] ||
            [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr4"]||
            [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr4_"]) {
            
            if ([appDelegate isEmptyString:self.account_postalcountry.text]) {
                [appDelegate setPageObject:nil];
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:4] animated:YES scrollPosition:UITableViewScrollPositionNone];
                [appDelegate setPageController:PageCountry];
                [appDelegate setPageRequest:PageRequest_Account_PostalCountry];
                [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
                return NO;
            }
        }
        
    }
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self textFieldEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.accessibilityIdentifier isEqualToString:@"account_website"]) {
        [[appDelegate acdbAccount] setValue:[appDelegate trim:textField.text] forKey:textField.accessibilityIdentifier];
    }
    
    if ([textField.accessibilityIdentifier isEqualToString:@"account_name"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_accountnames_data"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr1"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr2"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr3"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr1"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr2"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr3"] ) {
        textField.text = [appDelegate trim:[appDelegate capitalizeAllWords:textField.text]];
    }
    
   
    
    if ([textField.accessibilityIdentifier isEqualToString:@"account_streetaddr4"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_streetaddr4_"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr4"] ||
        [textField.accessibilityIdentifier isEqualToString:@"account_postaladdr4_"]) {
        textField.text = [appDelegate trim:[textField.text uppercaseString]];
    }
    [self textFieldEditing:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Methods
- (void) syncAccount {
    self.account_notes.placeholder=@"Notes";
    
    [self syncSoftLabels];
    
    if (![appDelegate pageObject]) {
        [appDelegate setAcdbAccount:[NSEntityDescription insertNewObjectForEntityForName:ENTITY_ACCOUNT inManagedObjectContext:[persistenceManager managedObjectContext]]];
        [appDelegate acdbAccount].uuid=[persistenceManager  newUUID];
        [appDelegate acdbAccount].sync_modifier = [persistenceManager newUUID];
        
        
    } else {
        [appDelegate setAcdbAccount:(ACDBAccount*)[appDelegate pageObject]];
        
        self.account_name.text=[appDelegate acdbAccount].account_name;
        self.account_accountnames_data.text=[appDelegate acdbAccount].account_accountnames_data;
        self.account_contactmainphone.text=[appDelegate acdbAccount].account_contactmainphone;
        
        NSString *firstname=@"";
        NSString *lastname=@"";
        NSString *mycontact;
        
        if ([appDelegate acdbAccount].account_primarycontact) {
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_primarycontact.contact_nickname]) {
                firstname=[appDelegate acdbAccount].account_primarycontact.contact_nickname;
            } else {
                if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_primarycontact.contact_firstname]) {
                    firstname=[appDelegate acdbAccount].account_primarycontact.contact_firstname;
                }
            }
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_primarycontact.contact_lastname]) {
                lastname=[appDelegate acdbAccount].account_primarycontact.contact_lastname;
            }
            mycontact=[NSString stringWithFormat:@"%@ %@",firstname , lastname];
            self.account_primarycontact.text=mycontact;
        }
        
        if ([appDelegate acdbAccount].account_secondarycontact) {
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_secondarycontact.contact_nickname]) {
                firstname=[appDelegate acdbAccount].account_secondarycontact.contact_nickname;
            } else {
                if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_secondarycontact.contact_firstname]) {
                    firstname=[appDelegate acdbAccount].account_secondarycontact.contact_firstname;
                }
            }
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_primarycontact.contact_lastname]) {
                lastname=[appDelegate acdbAccount].account_secondarycontact.contact_lastname;
            }
            mycontact=[NSString stringWithFormat:@"%@ %@",firstname , lastname];
            self.account_secondarycontact.text=mycontact;
        }
        
        if ([appDelegate acdbAccount].account_billing) {
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_billing.contact_nickname]) {
                firstname=[appDelegate acdbAccount].account_billing.contact_nickname;
            } else {
                if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_billing.contact_firstname]) {
                    firstname=[appDelegate acdbAccount].account_billing.contact_firstname;
                }
            }
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_billing.contact_lastname]) {
                lastname=[appDelegate acdbAccount].account_billing.contact_lastname;
            }
            mycontact=[NSString stringWithFormat:@"%@ %@",firstname , lastname];
            self.account_billing.text=mycontact;
        }
        
        if ([appDelegate acdbAccount].account_accounts) {
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_accounts.contact_nickname]) {
                firstname=[appDelegate acdbAccount].account_accounts.contact_nickname;
            } else {
                if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_accounts.contact_firstname]) {
                    firstname=[appDelegate acdbAccount].account_accounts.contact_firstname;
                }
            }
            if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_accounts.contact_lastname]) {
                lastname=[appDelegate acdbAccount].account_accounts.contact_lastname;
            }
            mycontact=[NSString stringWithFormat:@"%@ %@",firstname , lastname];
            self.account_accounts.text=mycontact;
        }
        
        
        self.account_streetaddr1.text=[appDelegate acdbAccount].account_streetaddr1;
        self.account_streetaddr2.text=[appDelegate acdbAccount].account_streetaddr2;
        self.account_streetaddr3.text=[appDelegate acdbAccount].account_streetaddr3;
        NSArray *streetaddr4;
        if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_streetaddr4]) {
            streetaddr4=[[appDelegate acdbAccount].account_streetaddr4 componentsSeparatedByString:@"|"];
            self.account_streetaddr4.text=[streetaddr4 objectAtIndex:0];
            self.account_streetaddr4_.text=[streetaddr4 objectAtIndex:1];
        }
        if ([appDelegate acdbAccount].account_country) {
            self.info_account_streetaddr3.text=[appDelegate acdbAccount].account_country.country_mailingpostal1;
            self.account_streetaddr3.placeholder=[appDelegate acdbAccount].account_country.country_mailingpostal1;
            self.info_account_streetaddr4.text=[appDelegate acdbAccount].account_country.country_mailingpostal2;
            self.account_country.text=[appDelegate acdbAccount].account_country.country_name;
            streetaddr4=[[appDelegate acdbAccount].account_country.country_mailingpostal2 componentsSeparatedByString:@"|"];
            self.account_streetaddr4.placeholder=[streetaddr4 objectAtIndex:0];
            self.account_streetaddr4_.placeholder=[streetaddr4 objectAtIndex:1];
        }
        self.account_postaladdr1.text=[appDelegate acdbAccount].account_postaladdr1;
        self.account_postaladdr2.text=[appDelegate acdbAccount].account_postaladdr2;
        self.account_postaladdr3.text=[appDelegate acdbAccount].account_postaladdr3;
        NSArray *postaladdr4;
        if (![appDelegate isEmptyString:[appDelegate acdbAccount].account_postaladdr4]) {
            postaladdr4=[[appDelegate acdbAccount].account_postaladdr4 componentsSeparatedByString:@"|"];
            self.account_postaladdr4.text=[postaladdr4 objectAtIndex:0];
            self.account_postaladdr4_.text=[postaladdr4 objectAtIndex:1];
        }
        if ([appDelegate acdbAccount].account_postalcountry) {
            self.info_account_postaladdr3.text=[appDelegate acdbAccount].account_postalcountry.country_mailingpostal1;
            self.account_postaladdr3.placeholder=[appDelegate acdbAccount].account_postalcountry.country_mailingpostal1;
            self.info_account_postaladdr4.text=[appDelegate acdbAccount].account_postalcountry.country_mailingpostal2;
            self.account_postalcountry.text=[appDelegate acdbAccount].account_postalcountry.country_name;
            postaladdr4=[[appDelegate acdbAccount].account_postalcountry.country_mailingpostal2 componentsSeparatedByString:@"|"];
            self.account_postaladdr4.placeholder=[postaladdr4 objectAtIndex:0];
            self.account_postaladdr4_.placeholder=[postaladdr4 objectAtIndex:1];
            
        }
        if ([[appDelegate acdbAccount].account_employees integerValue] > 0)
            self.account_employees.text=[NSString stringWithFormat:@"%ld",(long)[[appDelegate acdbAccount].account_employees integerValue]];
        
        self.account_warning.text=[appDelegate acdbAccount].account_warning;
        if ([appDelegate acdbAccount].account_relationship) {
            self.account_relationship.text=[appDelegate acdbAccount].account_relationship.relationship_name;
        }
        if ([appDelegate acdbAccount].account_stdinclass) {
            self.account_stdinclass.text=[appDelegate acdbAccount].account_stdinclass.stdinclass_name;
        }
        self.account_website.text=[appDelegate acdbAccount].account_website;
        self.account_renotes.text=[NSString stringWithFormat:@"Notes re %@",([appDelegate acdbAccount].account_name==nil ? @"" : [appDelegate acdbAccount].account_name)];
        self.account_accuserdef1_data.text=[appDelegate acdbAccount].account_accuserdef1_data;
        self.account_accuserdef2_data.text=[appDelegate acdbAccount].account_accuserdef2_data;
        self.account_accuserdef3_data.text=[appDelegate acdbAccount].account_accuserdef3_data;
        self.account_accuserdef4_data.text=[appDelegate acdbAccount].account_accuserdef4_data;
        self.account_notes.text=[appDelegate acdbAccount].account_notes;
        
    }
}

- (void) syncSoftLabels {
    SoftLabels *softlabels=(SoftLabels*)[persistenceManager  entityObject:ENTITY_SOFTLABELS];
    
    self.info_account_accountnames.text=@"";
    self.account_accountnames_data.placeholder=@"";
    self.info_account_accuserdef1.text=@"";
    self.account_accuserdef1_data.placeholder=@"";
    self.info_account_accuserdef2.text=@"";
    self.account_accuserdef2_data.placeholder=@"";
    self.info_account_accuserdef3.text=@"";
    self.account_accuserdef3_data.placeholder=@"";
    self.info_account_accuserdef4.text=@"";
    self.account_accuserdef4_data.placeholder=@"";
    
    
    if (softlabels.accountnames) {
        if (![softlabels.accountnames.disposal boolValue]) {
            self.info_account_accountnames.text=softlabels.accountnames.accountnames_name;
            self.account_accountnames_data.placeholder=softlabels.accountnames.accountnames_name;
        }
    }
    if (softlabels.accuserdef1) {
        if (![softlabels.accuserdef1.disposal boolValue]) {
            self.info_account_accuserdef1.text=softlabels.accuserdef1.accuserdef_name;
            self.account_accuserdef1_data.placeholder=softlabels.accuserdef1.accuserdef_name;
        }
    }
    if (softlabels.accuserdef2) {
        if (![softlabels.accuserdef2.disposal boolValue]) {
            self.info_account_accuserdef2.text=softlabels.accuserdef2.accuserdef_name;
            self.account_accuserdef2_data.placeholder=softlabels.accuserdef2.accuserdef_name;
        }
    }
    if (softlabels.accuserdef3) {
        if (![softlabels.accuserdef3.disposal boolValue]) {
            self.info_account_accuserdef3.text=softlabels.accuserdef3.accuserdef_name;
            self.account_accuserdef3_data.placeholder=softlabels.accuserdef3.accuserdef_name;
        }
        
    }
    if (softlabels.accuserdef4) {
        if (![softlabels.accuserdef4.disposal boolValue]) {
            self.info_account_accuserdef4.text=softlabels.accuserdef4.accuserdef_name;
            self.account_accuserdef4_data.placeholder=softlabels.accuserdef4.accuserdef_name;
        }
    }

}

#pragma mark - Gestures
- (void)viewMap:(UIGestureRecognizer*)gestureRecognizer {
    if ([appDelegate isEmptyString:self.account_country.text]) {
        [appDelegate alert:[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Country"]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:3];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    [appDelegate setPageRequest:PageRequest_Account_MailingMap];
    [self performSegueWithIdentifier:@"MapViewSegue" sender:self];
}

- (void)viewGoogleMap:(UIGestureRecognizer*)gestureRecognizer {
    if ([appDelegate isEmptyString:self.account_country.text]) {
        [appDelegate alert:[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Country"]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:3];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    [appDelegate setPageRequest:PageRequest_Account_MailingMap];
    
    BOOL canHandle = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]];
    
    if (canHandle) {
        NSString *address = [self getAddress];
        CLLocationCoordinate2D center = [self getLocationFromAddressString:address];
        GoogleMapDefinition *mapDefinition = [[GoogleMapDefinition alloc] init];
        mapDefinition.queryString = address;
        mapDefinition.center = center;
        mapDefinition.viewOptions |= kGoogleMapsViewOptionSatellite;
        mapDefinition.viewOptions |= kGoogleMapsViewOptionTraffic;
        mapDefinition.viewOptions |= kGoogleMapsViewOptionTransit;
        
        mapDefinition.zoomLevel = 18.5f;
        [[OpenInGoogleMapsController sharedInstance] openMap:mapDefinition];
    } else {
        [appDelegate alert:@"Google maps app not installed"];
    }
    
   
}

-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
    CLLocationCoordinate2D center;
    
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSError *error = nil;
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:&error];
    
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    center.latitude=latitude;
    center.longitude = longitude;
    DebugLog(@"Location Logitute : %f",center.latitude);
    DebugLog(@"Location Latitute : %f",center.longitude);
    return center;
    
}

- (NSString*) getAddress {
    NSString *s1,*s2,*s3,*s4,*s5,*s6;
    if ([appDelegate pageRequest] == PageRequest_Account_MailingMap) {
        
        s1=self.account_streetaddr1.text;
        s2=self.account_streetaddr2.text;
        s3=self.account_streetaddr3.text;
        s4=self.account_streetaddr4.text;
        s5=self.account_streetaddr4_.text;
        s6=self.account_country.text;
    }
    s1=[appDelegate trim:s1];
    s2=[appDelegate trim:s2];
    s3=[appDelegate trim:s3];
    s4=[appDelegate trim:s4];
    s5=[appDelegate trim:s5];
    s6=[appDelegate trim:s6];
    
    NSString *addressString=@"";
    if (![appDelegate isEmptyString:s1])
        addressString=[NSString stringWithFormat:@"%@ %@",addressString,s1];
    
    if (![appDelegate isEmptyString:s2])
        addressString=[NSString stringWithFormat:@"%@ %@",addressString,s2];
    
    if (![appDelegate isEmptyString:s3])
        addressString=[NSString stringWithFormat:@"%@ %@",addressString,s3];
    
    if (![appDelegate isEmptyString:s4])
        addressString=[NSString stringWithFormat:@"%@ %@",addressString,s4];
    
    if (![appDelegate isEmptyString:s5])
        addressString=[NSString stringWithFormat:@"%@ %@",addressString,s5];
    
    if (![appDelegate isEmptyString:s6])
        addressString=[NSString stringWithFormat:@"%@ %@",addressString,s6];
    
    return addressString;

}


@end
