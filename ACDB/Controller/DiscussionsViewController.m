//
//  DiscussionsViewController.m
//  ACDB
//
//  Created by Rommel on 18/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "DiscussionsViewController.h"

@interface DiscussionsViewController()<UITextFieldDelegate,UITextViewDelegate,DatePickerDelegate>
@property BOOL scroll;

@property(nonatomic,strong)DatePicker *datePicker;
@property(nonatomic,assign)PageRequest pageRequest;
@property(nonatomic,strong)Discussion *discussion;
@property(nonatomic,strong)UIBarButtonItem *infoBtn;
@property(nonatomic,strong)UIBarButtonItem *doneBtn;
@property(nonatomic,strong) NSDateFormatter *dateFormat;
@end

@implementation DiscussionsViewController

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
    
    _infoBtn = [[UIBarButtonItem alloc] initWithCustomView:info];
    
    _doneBtn = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                    target:self action:@selector(done:)];
    
    _datePicker=[[DatePicker alloc]init];
    _datePicker.delegate=self;

    self.navigationItem.rightBarButtonItem=_infoBtn;
    
    _discussion_notes.placeholder=@"Notes";
    
    _pageRequest=[appDelegate pageRequest];
    
    _dateFormat =[[NSDateFormatter alloc]init];
    [_dateFormat setDateFormat:@"EEE dd MMM yyyy"];
    
    if (![appDelegate pageObject]) {
        _discussion = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_DISCUSSION inManagedObjectContext:[persistenceManager managedObjectContext]];
        _discussion.uuid=[persistenceManager  newUUID];
        _discussion.sync_modifier = [persistenceManager newUUID];
        
         _discussion_contactdate.text=[_dateFormat stringFromDate:[NSDate date]];
        _discussion_bringupdate.text=[_dateFormat stringFromDate:[NSDate date]];
        //_discussion_bringupdate.text=[dateFormat stringFromDate:[ [NSDate date] dateByAddingTimeInterval:(60*60*24*2)]];
        [_discussion setValue:[NSDate date] forKey:@"discussion_contactdate"];
        [_discussion setValue:[NSDate date] forKey:@"discussion_bringupdate"];
        //[_discussion setValue:[ [NSDate date] dateByAddingTimeInterval:(60*60*24*2)] forKey:@"discussion_bringupdate"];
        
    } else {
        _discussion=(Discussion*)[appDelegate pageObject];
     
        if (_discussion.discussion_contacttype) {
            _discussion_contacttype.text=_discussion.discussion_contacttype.contacttype_name;
        }
        if (_discussion.discussion_contactperson) {
            NSString *firstname=@"",*lastname=@"";
            if (![appDelegate isEmptyString:_discussion. discussion_contactperson.contact_nickname]) {
                firstname=_discussion.discussion_contactperson.contact_nickname;
            } else {
                if (![appDelegate isEmptyString:_discussion. discussion_contactperson.contact_firstname]) {
                    firstname=_discussion.discussion_contactperson.contact_firstname;
                }
            }
            if (![appDelegate isEmptyString:_discussion.discussion_contactperson.contact_lastname]) {
                lastname=_discussion.discussion_contactperson.contact_lastname;
            }
            _discussion_contactperson.text=[NSString stringWithFormat:@"%@ %@",firstname,lastname];
        }
        _discussion_contactheader.text=[appDelegate trim:_discussion.discussion_contactheader];
        
        if (_discussion.discussion_contactdate) {
            _discussion_contactdate.text=[_dateFormat stringFromDate:_discussion.discussion_contactdate];
        }
        if (_discussion.discussion_bringupdate) {
            
            _discussion_bringupdate.text=[_dateFormat stringFromDate:_discussion.discussion_bringupdate];
        }
        _discussion_notes.text=_discussion.discussion_notes;
    }
    
    if (IS_IOS_7)
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.title=@"Discussion";
    NSIndexPath *indexPath;
    
    _scroll=true;
    if (![appDelegate pageObject]) {
        _discussion=(Discussion*)[persistenceManager  entityObject:ENTITY_DISCUSSION uuid:_discussion.uuid];
    }

    switch((int)[appDelegate pageRequest]) {
        case PageRequest_Discussion_ContactPerson:
            
            if (![appDelegate pageObject]) {
                [appDelegate setPageObject:(NSManagedObject*)_discussion.discussion_contactperson];
                _discussion_contactperson.text=@"";
                _scroll=false;
            }
  
            if ([appDelegate pageObject]!=nil && [[appDelegate pageObject] isKindOfClass:[Contact class]]) {
                Contact *contact = (Contact*)[appDelegate pageObject];
                NSString *firstname=@"",*lastname=@"";
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
                _discussion_contactperson.text=[NSString stringWithFormat:@"%@ %@",firstname,lastname];
                _discussion.discussion_contactperson=contact;
                [contact addContact_discussioncontactpersonObject:_discussion];
              
                if(_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
              }
            break;
        case PageRequest_Discussion_ContactType:
            if (![appDelegate pageObject]) {
                [appDelegate setPageObject:(NSManagedObject*)_discussion.discussion_contacttype];
                _discussion_contacttype.text=@"";
                _scroll=false;
            }
            if ([appDelegate pageObject] && [[appDelegate pageObject] isKindOfClass:[ContactType class]]) {
                ContactType *contacttype=(ContactType*)[appDelegate pageObject];
                
                _discussion_contacttype.text=contacttype.contacttype_name;
                _discussion.discussion_contacttype=contacttype;
                [contacttype addContacttypeObject:_discussion];
                
                if (_scroll) {
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
                }
            }
            
            break;
    }
    [appDelegate setPageObject:nil];
    self.navigationController.navigationBar.translucent=NO;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [appDelegate setPageRequest:_pageRequest];
    }
    if (_datePicker)
        [_datePicker dismissDatePicker];
    
    [self contextAccountAllDiscussions];
    [persistenceManager saveContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


- (void) setFields
{
    self.discussion_contacttype.accessibilityIdentifier = @"discussion_contacttype";
    self.discussion_contactperson.accessibilityIdentifier = @"discussion_contactperson";
    self.discussion_bringupdate.accessibilityIdentifier = @"discussion_bringupdate";
    self.discussion_contactdate.accessibilityIdentifier = @"discussion_contactdate";
    self.discussion_contactheader.accessibilityIdentifier = @"discussion_contactheader";
    self.discussion_notes.accessibilityIdentifier = @"discussion_notes";
}

-(void)contextAccountAllDiscussions
{
    if (_discussion.uuid) {
        NSSet *discussions=[appDelegate acdbAccount].account_discussions;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", _discussion.uuid];
        NSSet *discussion = [discussions filteredSetUsingPredicate:predicate];
        if (discussion.count <= 0) {
            [[appDelegate acdbAccount] addAccount_discussionsObject:_discussion];
        } 
    }
}


-(IBAction)helpText:(id)sender {
    [self performSegueWithIdentifier:@"HelpTextViewSegue" sender:self];
}


-(void)showBirthDates:(id)source date:(NSString*)date bringup:(NSString*)bringupdate
{
    date=[appDelegate trim:date];
    bringupdate=[appDelegate trim:bringupdate];
    [_datePicker presentDatePickerInView:[UIApplication sharedApplication].keyWindow date:date value:bringupdate source:source];
}

#pragma mark - DatePicker

-(void)selectedDatePicker:(NSDate *)date bringups:(NSDate *)bringupsDate
{
    self.discussion_contactdate.text = [_dateFormat stringFromDate:date];
    self.discussion_bringupdate.text = [_dateFormat stringFromDate:bringupsDate];
    [_discussion setValue:date forKey:self.discussion_contactdate.accessibilityIdentifier];
    [_discussion setValue:bringupsDate forKey:self.discussion_bringupdate.accessibilityIdentifier];
}

-(void)selectedDatePicker:(NSDate*)date
{
    switch((int)[appDelegate pageRequest]) {
        case PageRequest_Discussion_ContactDate:
            self.discussion_contactdate.text = [_dateFormat stringFromDate:date];
            [_discussion setValue:date forKey:self.discussion_contactdate.accessibilityIdentifier];
            break;
        case PageRequest_Discussion_BringupDate:
            
            self.discussion_bringupdate.text = [_dateFormat stringFromDate:date];
            [_discussion setValue:date forKey:self.discussion_bringupdate.accessibilityIdentifier];
            break;
    }

}

-(void)initializedDatePicker
{
    
}

-(void)completedDatePicker
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    NSIndexPath *indexPath;
    switch((int)[appDelegate pageRequest]) {
        case PageRequest_Discussion_ContactDate:
            indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
            
            break;
        case PageRequest_Discussion_BringupDate:
             indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
            break;
    }
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
}

-(void)error:(NSString *)error
{
    [appDelegate alert:error];
}



#pragma mark - UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //if ([text isEqualToString:@"\n"]) {
    //    [textView resignFirstResponder];
    //}
    if (_datePicker) {
        [_datePicker dismissDatePicker];
    }
    [_discussion setValue:[appDelegate trim:textView.text] forKey:textView.accessibilityIdentifier];
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (textView == _discussion_notes) {
        _discussion.discussion_notes=textView.text;
    }
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    [self performSelector:@selector(positionDiscussionNotes) withObject:nil afterDelay:1.0];
    
}

- (void)positionDiscussionNotes {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - UITextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_datePicker) {
        [_datePicker dismissDatePicker];
     }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UITextFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:textField];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _discussion_contactheader)
        textField.text=[appDelegate trim:[appDelegate capitalizeAllWords:textField.text]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:textField];
    
}

- (void) UITextFieldTextDidChange:(NSNotification*)notification
{
    UITextField * textField = (UITextField*)notification.object;
    [_discussion setValue:[appDelegate trim: [appDelegate capitalizeAllWords:textField.text]] forKey:textField.accessibilityIdentifier];
    
}

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
    
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _discussion_contacttype ||
        textField == _discussion_contactperson ||
        textField == _discussion_contactdate ||
        textField == _discussion_bringupdate) {
        
        [self.view endEditing:YES];
        
        if (textField == _discussion_contactdate) {
            [appDelegate setPageRequest:PageRequest_Discussion_ContactDate];
            [self showBirthDates:textField date:textField.text bringup:_discussion_bringupdate.text];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];

        } else if (textField == _discussion_bringupdate) {
            [appDelegate setPageRequest:PageRequest_Discussion_BringupDate];
            [self showBirthDates:textField date:textField.text bringup:_discussion_contactdate.text];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            
        } else if (textField == _discussion_contacttype) {
            [appDelegate setPageController:PageContactType];
            [appDelegate setPageRequest:PageRequest_Discussion_ContactType];
            [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            
        } else if (textField == _discussion_contactperson) {
            self.navigationItem.title=@"Discussion";
            if (_discussion.discussion_contactperson) {
          
                if (![_discussion.discussion_contactperson.disposal boolValue]) {
                    [appDelegate setPageObject:_discussion.discussion_contactperson];
                    [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
                } else {
                    [appDelegate alert:[SOURCE_REMOVED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Contact"]];
                }
             
             } else {
                 
                 [appDelegate setPageRequest:PageRequest_Discussion_ContactPerson];
                 [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
             }
            //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            
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
    self.navigationItem.title=@"Discussion";
    if (indexPath.section == 0 && indexPath.row == 3) {//Contact Date
        [appDelegate setPageRequest:PageRequest_Discussion_ContactDate];
        [self showBirthDates:_discussion_contactdate date:_discussion_contactdate.text bringup:_discussion_bringupdate.text];
        
    } else if (indexPath.section == 0 && indexPath.row == 4) {//Bringup Date
        [appDelegate setPageRequest:PageRequest_Discussion_BringupDate];
        [self showBirthDates:_discussion_bringupdate date:_discussion_bringupdate.text bringup:_discussion_contactdate.text];
        
    }else if (indexPath.section == 0 && indexPath.row == 0) { //Contact Type
        [appDelegate setPageObject:nil];
        [appDelegate setPageController:PageContactType];
        [appDelegate setPageRequest:PageRequest_Discussion_ContactType];
        [self performSegueWithIdentifier:@"DataViewSegue" sender:self];
        
    } else if (indexPath.section == 0 && indexPath.row == 1) { //Contact Person
        
        NSSortDescriptor *name = nil;
        NSArray *results = nil;
        NSPredicate *predicate = nil;
        
        name = [[NSSortDescriptor alloc] initWithKey:@"uuid" ascending:YES];
        results = [[appDelegate acdbAccount].account_contacts sortedArrayUsingDescriptors:[NSArray arrayWithObjects:name, nil]];
        predicate = [NSPredicate predicateWithFormat:@"disposal == %@",[NSNumber numberWithBool:NO]];
        results = [results filteredArrayUsingPredicate:predicate];
        
        if (results.count > 0) {
            [appDelegate setPageObject:nil];
            [appDelegate setPageRequest:PageRequest_Discussion_ContactPerson];
            [self performSegueWithIdentifier:@"ContactsDataViewSegue" sender:self];
            
        } else {
           [appDelegate alert:[SOURCE_NOT_AVAILABLE stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Contact"]];
        }
       
    }
}


#pragma Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HelpTextViewSegue"]) {
        [segue.destinationViewController helpTextInfo:DISCUSSIONS_HELPTEXT];
    } else if ([segue.identifier isEqualToString:@"ContactsDataViewSegue"]) {
    }
}



@end
