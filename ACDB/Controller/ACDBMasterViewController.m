//
//  ACDBMasterViewController.m
//  ACDB
//
//  Created by Rommel on 13/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "ACDBMasterViewController.h"

@interface ACDBMasterViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UIBarButtonItem *doneBtn;
@end

@implementation ACDBMasterViewController

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
   
     self.tableView.tableFooterView = [[UIView alloc] init];
    
    _doneBtn = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                    target:self action:@selector(done:)];
    

    self.navigationItem.title=@"Master";
    
    switch((int)[appDelegate pageController]) {
        case PageRelationship:
            if ([appDelegate pageObject]) {
                self.master_name.text=((Relationship*)([appDelegate pageObject])).relationship_name;
            }
            break;
        case PageSupportLevel:
            if ([appDelegate pageObject]) {
                self.master_name.text=((SupportLevel*)([appDelegate pageObject])).supportlevel_name;
            }
            break;
        case PageStdInClass:
            if ([appDelegate pageObject]) {
                self.master_name.text=((StdInClass*)([appDelegate pageObject])).stdinclass_name;
            }
            break;
        case PageContactType:
            if ([appDelegate pageObject]) {
                self.master_name.text=((ContactType*)([appDelegate pageObject])).contacttype_name;
            }
            break;
        case PageBuyingPower:
            if ([appDelegate pageObject]) {
                self.master_name.text=((BuyingPower*)([appDelegate pageObject])).buyingpower_name;
            }
            break;
        case PageCountry:
            if ([appDelegate pageObject]) {
                self.master_name.text=((Country*)([appDelegate pageObject])).country_name;
                self.master_info1.text=((Country*)([appDelegate pageObject])).country_mailingpostal1;
                NSArray *addr=[(((Country*)([appDelegate pageObject])).country_mailingpostal2) componentsSeparatedByString:@"|"];
                self.master_info2.text=[appDelegate trim:[addr objectAtIndex:0]];
                self.master_info3.text=[appDelegate trim:[addr objectAtIndex:1]];
            } else {
                self.master_info1.text=@"City";
                self.master_info2.text=@"State";
                self.master_info3.text=@"Zip";
                
            }
            break;
        case PageAccountNames:
            if ([appDelegate pageObject]) {
                self.master_name.text=((AccountNames*)([appDelegate pageObject])).accountnames_name;
            }
            break;
        case PageAccUserDef1:
            if ([appDelegate pageObject]) {
                self.master_name.text=((AccUserDef1*)([appDelegate pageObject])).accuserdef_name;
            }
            break;
        case PageAccUserDef2:
            if ([appDelegate pageObject]) {
                self.master_name.text=((AccUserDef2*)([appDelegate pageObject])).accuserdef_name;
            }
            break;
        case PageAccUserDef3:
            if ([appDelegate pageObject]) {
                self.master_name.text=((AccUserDef3*)([appDelegate pageObject])).accuserdef_name;
            }
            break;
        case PageAccUserDef4:
            if ([appDelegate pageObject]) {
                self.master_name.text=((AccUserDef4*)([appDelegate pageObject])).accuserdef_name;
            }
            break;
        case PageConUserDef1:
            if ([appDelegate pageObject]) {
                self.master_name.text=((ConUserDef1*)([appDelegate pageObject])).conuserdef_name;
            }
            break;
        case PageConUserDef2:
            if ([appDelegate pageObject]) {
                self.master_name.text=((ConUserDef2*)([appDelegate pageObject])).conuserdef_name;
            }
            break;
        case PageConUserDef3:
            if ([appDelegate pageObject]) {
                self.master_name.text=((ConUserDef3*)([appDelegate pageObject])).conuserdef_name;
            }
            break;
        case PageConUserDef4:
            if ([appDelegate pageObject]) {
                self.master_name.text=((ConUserDef4*)([appDelegate pageObject])).conuserdef_name;
            }
            break;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    if (IS_IOS_7)
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
    
    NSDictionary *source = [self getSources];
    [persistenceManager destroyCache:[source objectForKey:@"entity"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
     if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
         if (![appDelegate isEmptyString:self.master_name.text]) {
             NSDictionary *sources = [self getSources];
             
             NSString *entity = [sources objectForKey:@"entity"];
             NSString *field_name = [sources objectForKey:@"field_name"];
          
             [persistenceManager destroyCache:entity];
             
             NSString *param=[appDelegate capitalizeAllWords:self.master_name.text];
             if ([appDelegate pageController] == PageCountry)
                 param=[param uppercaseString];
             
             NSManagedObject *source;
             if (![appDelegate pageObject]) {
                 if (![persistenceManager  entitySearchObject:entity field_name:field_name param:param]) {
                     source = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:[persistenceManager managedObjectContext]];
                     [source setValue:param forKey:field_name];
                     [source setValue:[persistenceManager  newUUID] forKey:@"uuid"];
                     
                     if( [appDelegate pageController] == PageCountry) {
                         [source setValue:[appDelegate capitalizeAllWords:[appDelegate trim:self.master_info1.text]] forKey:@"country_mailingpostal1"];
                         [source setValue:[appDelegate capitalizeAllWords:[appDelegate trim:[NSString stringWithFormat:@"%@ | %@",self.master_info2.text,self.master_info3.text]]] forKey:@"country_mailingpostal2"];
                     }
                     
                 }
             } else {
                 source=[appDelegate pageObject];
                 [source setValue:param forKey:field_name];
                 if( [appDelegate pageController] == PageCountry) {
                     [source setValue:[appDelegate capitalizeAllWords:[appDelegate trim:self.master_info1.text]] forKey:@"country_mailingpostal1"];
                     [source setValue:[appDelegate capitalizeAllWords:[appDelegate trim:[NSString stringWithFormat:@"%@ | %@",self.master_info2.text,self.master_info3.text]]] forKey:@"country_mailingpostal2"];
                 }
             }
         }

    }
    [persistenceManager saveContext];
    [appDelegate setPageObject:nil];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent=NO;
    
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    self.navigationItem.rightBarButtonItem=_doneBtn;
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    self.navigationItem.rightBarButtonItem=nil;
}


-(IBAction)done:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // Prevent crashing
    if(range.length + range.location > textField.text.length){
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > MAX_TEXT_FIELDS) {
        return NO;
    }

    
    if (textField == self.master_info1 ||
        textField == self.master_info2 ||
        textField == self.master_info3) {
        NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++){
            unichar c = [string characterAtIndex:i];
            if (![charset characterIsMember:c]){
                return NO;
            } else {
                return YES;
            }
        }
    }
    
    return YES;
}

#pragma UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger  row = 0;
    switch((int)[appDelegate pageController]) {
        case PageCountry:
            row=3;
            break;
        default:
            row=1;
            break;
    }
    return row;
}

#pragma mark - Methods
-(NSDictionary*) getSources {
    NSString *field_name,*entity;
    switch((int)[appDelegate pageController]) {
        case PageRelationship:
            field_name=@"relationship_name";
            entity=ENTITY_RELATIONSHIP;
            break;
        case PageStdInClass:
            field_name=@"stdinclass_name";
            entity=ENTITY_STDINCLASS;
            break;
        case PageBuyingPower:
            field_name=@"buyingpower_name";
            entity=ENTITY_BUYINGPOWER;
            break;
        case PageSupportLevel:
            field_name=@"supportlevel_name";
            entity=ENTITY_SUPPORTLEVEL;
            break;
        case PageContactType:
            field_name=@"contacttype_name";
            entity=ENTITY_CONTACTTYPE;
            break;
        case PageCountry:
            field_name=@"country_name";
            entity=ENTITY_COUNTRY;
            break;
        case PageAccountNames:
            field_name=@"accountnames_name";
            entity=ENTITY_ACCOUNTNAMES;
            break;
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
            if ([appDelegate pageController] == PageAccUserDef1) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,1];
            }else if ([appDelegate pageController] == PageAccUserDef2) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,2];
            }else if ([appDelegate pageController] == PageAccUserDef3) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,3];
            }else if ([appDelegate pageController] == PageAccUserDef4) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,4];
            }
            field_name=@"accuserdef_name";
            break;
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
            if ([appDelegate pageController] == PageConUserDef1) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,1];
            }else if ([appDelegate pageController] == PageConUserDef2) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,2];
            }else if ([appDelegate pageController] == PageConUserDef3) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,3];
            }else if ([appDelegate pageController] == PageConUserDef4) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,4];
            }
            field_name=@"conuserdef_name";
            break;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys: entity, @"entity", field_name, @"field_name",nil];
    
}
@end
