//
//  DataViewController.m
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "ContactsDataViewController.h"

@interface ContactsDataViewController ()<PagingViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property BOOL reloadingState;

@property(nonatomic,strong) NSArray *entityObjects;

@property(nonatomic,strong) NSMutableDictionary *accessories;
@property(nonatomic,strong) PagingView *pagingView;
@property(nonatomic,strong)NSMutableArray *filteredListItems;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
-(void)syncEntityObjects:(BOOL)reload;

@end

@implementation ContactsDataViewController

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
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
	searchBar.delegate = self;
	[searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[searchBar sizeToFit];
	self.tableView.tableHeaderView = searchBar;
	
	_searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	[self setSearchDisplayController:_searchDisplayController];
	[_searchDisplayController setDelegate:self];
	[_searchDisplayController setSearchResultsDataSource:self];
    _filteredListItems=[[NSMutableArray alloc]init];

    
    _accessories=[[NSMutableDictionary alloc]init];
    PagingView *pagingView = [[PagingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    pagingView.delegate = self;
    [self.tableView addSubview:_pagingView];
    _pagingView = pagingView;
    
    if (IS_IOS_7)
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self syncEntityObjects:YES];
    self.navigationItem.title=@"Contacts";
    
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
     
    UIButton *info = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 24)];
    [info setImage:[UIImage imageNamed:@"info_24"] forState:UIControlStateNormal];
    info.tag=HELPTEXT;
    [self.navigationController.navigationBar addSubview:info];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [info setFrame:CGRectMake(220, 10, 44, 24)];
    } else {
        [info setFrame:CGRectMake(660, 10, 44, 24)];
    }
    [info addTarget:self action:@selector(helpText:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.navigationBar.translucent=NO;
    [self edit];
    
    NSSortDescriptor *name = nil;
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    name = [[NSSortDescriptor alloc] initWithKey:@"uuid" ascending:YES];
    results = [[appDelegate acdbAccount].account_contacts sortedArrayUsingDescriptors:[NSArray arrayWithObjects:name, nil]];
    predicate = [NSPredicate predicateWithFormat:@"disposal == %@",[NSNumber numberWithBool:NO]];
    results = [results filteredArrayUsingPredicate:predicate];
    
    if (results.count == 0) {
        [appDelegate alert:[SOURCE_NOT_AVAILABLE stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Contact"]];
        [self.navigationController popViewControllerAnimated:NO];
    }

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notificationLoadedFile:)
     name:@"notificationLoadedFile"
     object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
-(void)notificationLoadedFile:(NSNotification*)notification {
    [self syncEntityObjects:YES];
}

-(void) removeUnusedContact
{
    [self syncEntityObjects:NO];
    for (Contact *contact in _entityObjects) {
        BOOL dump=true;
        
        if (![appDelegate isEmptyString:contact.contact_firstname])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_nickname])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_lastname])
            dump=false;
       
        if (![appDelegate isEmptyString:contact.contact_salutation])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_jobtitle])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_workphone1])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_workphone2])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_mobilephone])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_homephone])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_email1])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_email2])
            dump=false;
        
        if (!contact.contact_birthday)
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_partner])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_chn_b_days])
            dump=false;
        
        
        if (![appDelegate isEmptyString:contact.contact_hobbies])
            dump=false;
        
        if (contact.contact_buyingpower)
            dump=false;
        
        if (contact.contact_supportlevel)
            dump=false;
        
        
        if (![appDelegate isEmptyString:contact.contact_conuserdef1_data])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_conuserdef2_data])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_conuserdef3_data])
            dump=false;
        
        if (![appDelegate isEmptyString:contact.contact_conuserdef4_data])
            dump=false;
        
        if (dump) {
            [[appDelegate acdbAccount] removeAccount_contactsObject:contact];
        }
    }
    [persistenceManager saveContext];
}

-(IBAction)deleteEntity:(id)sender
{
    NSManagedObject *managedObject = ((SegmentedControl*)sender).managedObject;
    //[managedObject setValue:[NSNumber numberWithInteger:YES] forKey:@"disposal"];
    [[persistenceManager managedObjectContext] deleteObject:managedObject];
    [persistenceManager saveContext];
    [appDelegate setPageObject:nil];
    
    [self syncEntityObjects:YES];
    [_searchDisplayController setActive:NO];
    
}

-(IBAction)helpText:(id)sender
{
    [self performSegueWithIdentifier:@"HelpTextViewSegue" sender:self];
}

-(void)syncEntityObjects:(BOOL)reload
{
    if ([appDelegate acdbAccount].account_contacts.count <=0) {
        _entityObjects=nil;
        [self.tableView reloadData];
        return;
    }
    
    NSSortDescriptor *name = [[NSSortDescriptor alloc] initWithKey:@"contact_name" ascending:YES];
    
    NSArray *results = [[appDelegate acdbAccount].account_contacts sortedArrayUsingDescriptors:[NSArray arrayWithObjects:name, nil]];
  
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"disposal == %@",[NSNumber numberWithBool:NO]];
    _entityObjects = [results filteredArrayUsingPredicate:predicate];
    
    if (reload)
        [self.tableView reloadData];
}

-(NSInteger) indexOfEntityObjectStartsWith:(UITableView*)tableView startsWith:(NSString*) startswith
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.contact_nickname beginswith[c] %@ OR SELF.contact_firstname beginswith[c] %@ OR SELF.contact_lastname beginswith[c] %@", startswith,startswith,startswith];
    NSArray *indexes;
    if (tableView == _searchDisplayController.searchResultsTableView) {
        indexes = [NSMutableArray arrayWithArray:[_filteredListItems filteredArrayUsingPredicate:predicate]];
    } else {
        indexes= [NSMutableArray arrayWithArray:[_entityObjects filteredArrayUsingPredicate:predicate]];
    }
    
    
    if ([indexes count] == 0)
        return -1;
    
    if (tableView == _searchDisplayController.searchResultsTableView)
        return [_filteredListItems indexOfObject:[indexes objectAtIndex:0]];
    
    return [_entityObjects indexOfObject:[indexes objectAtIndex:0]];
    
}

-(void)accessoryView:(BOOL)hidden
{
    for(id key in _accessories) {
        ((UIView*)[_accessories objectForKey:key]).hidden=hidden;
    }
    self.navigationItem.rightBarButtonItem=self.toggleItem;
}


-(void) edit
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                             target:self action:@selector(toggle:)];
    item.tag=ManagedSections_Edit;
    self.toggleItem=item;
    [self accessoryView:YES];
}

-(void) done
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self action:@selector(toggle:)];
    done.tag=ManagedSections_Done;
    self.toggleItem=done;
    [self accessoryView:NO];
}


- (IBAction) toggle:(id)sender
{
    if (_entityObjects.count == 0) {
        [self edit];
        return;
    }
    
    if (((UIBarButtonItem*)sender).tag == ManagedSections_Edit ) {
        [self done];
        
    } else {
        [self edit];
    }
}


-(NSInteger)sections
{
    NSInteger section=0;
    switch((int)[appDelegate pageRequest]) {
        case PageRequest_Account_BillingContact:
        case PageRequest_Account_PrimaryContact:
        case PageRequest_Account_SecondaryContact:
        case PageRequest_Account_AccountsContact:
        case PageRequest_Discussion_ContactPerson:
            section=1;
            break;
        default:
            section=ManagedSections_Sections;
            
    }
    return section;
}

-(UITableViewCell*) fetchObject:(UITableView*)tableView cell:(UITableViewCell*)cell section:(NSInteger)section row:(NSInteger)row
{
    if (cell == nil)
        return nil;
    
    if (section == ManagedSections_Data) { //SectionData
        NSString *uuid=@"";
        Contact *contact;
        NSString *group;
        if (tableView == _searchDisplayController.searchResultsTableView) {
            contact=[_filteredListItems objectAtIndex:row];
            group=GROUP_FILTERED;
         } else {
            contact=[_entityObjects objectAtIndex:row];
             group=GROUP_NORMAL;
        }
        if ([appDelegate isEmptyString:contact.contact_firstname] &&[appDelegate isEmptyString:contact.contact_nickname] &&
            [appDelegate isEmptyString:contact.contact_lastname]){
            ((CellTemplate1View*)cell).template_info1.text=@".. ..";
            //((CellTemplate1View*)cell).template_info1.textColor=[UIColor redColor];
        } else {
            NSString *firstname=@"..";
            NSString *lastname=@"..";
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
            ((CellTemplate1View*)cell).template_info1.text=[NSString stringWithFormat:@"%@ %@",firstname,lastname];
            //((CellTemplate1View*)cell).template_info1.textColor=[UIColor blackColor];
        }
      
        ((CellTemplate1View*)cell).template_info2.text=contact.contact_jobtitle;
        ((CellTemplate1View*)cell).template_info2.textColor=[UIColor lightGrayColor];
        /*
        if ([appDelegate isEmptyString:contact.contact_jobtitle]) {
            ((CellTemplate1View*)cell).template_info2.text=@"Job title required";
            ((CellTemplate1View*)cell).template_info2.textColor=[UIColor redColor];
        } else {
            ((CellTemplate1View*)cell).template_info2.text=contact.contact_jobtitle;
            ((CellTemplate1View*)cell).template_info2.textColor=[UIColor lightGrayColor];
        }
         */
        
        ((CellTemplate1View*)cell).template_info1.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        ((CellTemplate1View*)cell).template_info2.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        uuid=contact.uuid;
        uuid=[NSString stringWithFormat:@"%@_%@",group,uuid];
        
        if([_accessories objectForKey:uuid]!=nil) {
            ((CellTemplate1View*)cell).accessoryView=[_accessories objectForKey:uuid];
        } else {
            SegmentedControl *delete = [[SegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Delete", nil]];
            delete.momentary = YES;
            delete.tintColor = UIColorFromRGB(0xC84131);
            delete.managedObject =[_entityObjects objectAtIndex:row];
            [delete addTarget:self action:@selector(deleteEntity:) forControlEvents:UIControlEventValueChanged];
            
            ((CellTemplate1View*)cell).accessoryView=delete;
            
            if (self.toggleItem.tag == 0)
                ((CellTemplate1View*)cell).accessoryView.hidden=YES;
            
            UIView *view = ((CellTemplate1View*)cell).accessoryView;
            [_accessories setObject:view forKey:uuid];
      
        }
      
    }
    return cell;
    
}



-(CGFloat)heightSectionRow:(NSInteger)section
{
    CGFloat height=0;
    if (section == ManagedSections_Data) {
        height=30;
    } else {
        height=26;
    }
    return height;
}


-(UITableViewCell*)cell:(UITableView *)tableView section:(NSInteger)section
{
    UITableViewCell *cell;
    NSString *cellType;
    if (section == ManagedSections_Data) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellTemplate1"];
        if (cell == nil) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                cellType=@"CellTemplate1View-iphone";
            } else {
                cellType=@"CellTemplate1View-ipad";
            }
            [[NSBundle mainBundle] loadNibNamed:cellType owner:self options:nil];
            cell=self.cellTemplate1;
        }
    } else if (section == ManagedSections_AddEdit) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellAddEdit"];
        if (cell == nil) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                cellType=@"CellAddEditView-iphone";
            } else {
                cellType=@"CellAddEditView-ipad";
            }
            [[NSBundle mainBundle] loadNibNamed:cellType owner:self options:nil];
            cell=self.cellAddEdit;
        }
        
    }
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _searchDisplayController.searchResultsTableView)
        return 1;
    
    return [self sections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row=0;
    if (tableView == _searchDisplayController.searchResultsTableView){
        row=[_filteredListItems count];
    } else {
        if (section == ManagedSections_Data) {
            row=[_entityObjects count];
        } else if (section == ManagedSections_AddEdit) {
            row=1;
        }
    }

    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[self cell:tableView section:indexPath.section];
    cell=[self fetchObject:tableView cell:cell section:indexPath.section row:indexPath.row];
    if (indexPath.section == ManagedSections_AddEdit)
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightSectionRow:indexPath.section];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchDisplayController.searchResultsTableView) {
        if (self.toggleItem.tag == ManagedSections_Edit)
            [self edit];
    } else {
        if ([_entityObjects count] > 0)
            if (self.toggleItem.tag == ManagedSections_Edit)
                [self edit];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [appDelegate setPageObject:nil];
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
    if (indexPath.section == ManagedSections_Data) {
        if(tableView == _searchDisplayController.searchResultsTableView) {
           [appDelegate setPageObject:[_filteredListItems objectAtIndex:[indexPath row]]];
        } else {
            [appDelegate setPageObject:[_entityObjects objectAtIndex:[indexPath row]]];
        }
        if ([appDelegate pageRequest] == PageRequest_Account_AllContacts) {
            self.navigationItem.title=@"Contacts";
            [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
        }  else if ([appDelegate pageRequest] == PageRequest_Discussion_ContactPerson) {
            self.navigationItem.title=@"Discussion";
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            self.navigationItem.title=@"Accounts";
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        self.navigationItem.title=@"Contacts";
        if ([appDelegate pageRequest] == PageRequest_Discussion_ContactPerson)
            self.navigationItem.title=@"Discussion";
        
        [self performSegueWithIdentifier:@"ContactsViewSegue" sender:self];
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return[NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E",@"F", @"G", @"H", @"I", @"J",@"K", @"L", @"M", @"N", @"O",
           @"P", @"Q", @"R", @"S", @"T",@"U", @"V", @"W", @"X", @"Y",@"Z",nil];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    NSInteger idx=[self indexOfEntityObjectStartsWith:tableView startsWith:title];
    if (idx != -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:ManagedSections_Data];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:NO];
        [tableView selectRowAtIndexPath:indexPath animated:NO
                         scrollPosition:UITableViewScrollPositionTop];
    } else {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
    return -1;
}


#pragma Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DebugLog(@"prepareForSegue: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"ContactsViewSegue"]) {
    
    } else if ([segue.identifier isEqualToString:@"HelpTextViewSegue"]) {
        [segue.destinationViewController helpTextInfo:CONTACTS_HELPTEXT];
        
    }
    [self edit];
}


#pragma PagingView

- (void)doneLoadingTableViewData
{
    [self removeUnusedContact];
    [self syncEntityObjects:YES];
    
    _reloadingState = NO;
	[_pagingView pagingScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_pagingView pagingScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
  	[_pagingView pagingScrollViewDidEndDragging:scrollView];
}


- (void)pagingDidTriggerRefresh:(PagingView*)view
{
    _reloadingState=YES;
    
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

- (BOOL)pagingDataSourceIsLoading:(PagingView*)view
{
	return _reloadingState;
}

- (NSDate*)pagingDataSourceLastUpdated:(PagingView*)view
{
	return [NSDate date];
}

#pragma  UISeachBar
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //searchBar.showsScopeBar = YES;
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText {
    
    [_filteredListItems removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.contact_nickname beginswith[c] %@ OR SELF.contact_firstname beginswith[c] %@ OR SELF.contact_lastname beginswith[c] %@", searchText, searchText, searchText];
    
    _filteredListItems = [NSMutableArray arrayWithArray:[_entityObjects filteredArrayUsingPredicate:predicate]];
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView insertSubview:_searchDisplayController.searchBar aboveSubview:self.tableView];
    }
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.backgroundView.backgroundColor=[UIColor darkGrayColor];
    //controller.searchResultsTableView.rowHeight = self.tableView.rowHeight;
    controller.searchResultsTableView.separatorStyle =  self.tableView.separatorStyle;
    controller.searchResultsTableView.delegate=self;
	//controller.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    controller.searchResultsTableView.bounces=FALSE;
    controller.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString];
    return YES;
}


@end
