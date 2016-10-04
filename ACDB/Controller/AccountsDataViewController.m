//
//  DataViewController.m
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "AccountsDataViewController.h"

@interface AccountsDataViewController ()<PagingViewDelegate,UISearchBarDelegate>
@property BOOL reloadingState;
@property (nonatomic,strong) Reachability *reachability;

@property(nonatomic,strong) NSArray *entityObjects;
@property(nonatomic,strong)NSMutableDictionary *accessories;
@property(nonatomic,strong)PagingView *pagingView;
@property(nonatomic,strong)NSMutableArray *filteredListItems;
@property (nonatomic, strong) UISearchDisplayController	*searchDisplayController;

-(void)syncEntityObjects:(BOOL)reload;

@end


@implementation AccountsDataViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accessories=[[NSMutableDictionary alloc]init];
   
   
    
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
    
    
    self.filteredListItems=[[NSMutableArray alloc]init];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Bringups"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                        action:@selector(bringups:)]; 
    self.navigationItem.title=@"ACCOUNTS";
    
    [self removeUnusedAccount];
    
    PagingView *pagingView = [[PagingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    pagingView.delegate = self;
    [self.tableView addSubview:pagingView];
    _pagingView = pagingView;
    
    if (IS_IOS_7)
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
    
}

-(void) removeUnusedAccount
{
    [self syncEntityObjects:NO];
    for (ACDBAccount *account in self.entityObjects) {
        BOOL dump=true;
        
        if (![appDelegate isEmptyString:account.account_name])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_accountnames_data])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_contactmainphone])
            dump=false;
        
        if (account.account_primarycontact)
            dump=false;
        
        if (account.account_secondarycontact)
            dump=false;
        
        if (account.account_billing)
            dump=false;
        
        if (account.account_accounts)
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_streetaddr1])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_streetaddr2])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_streetaddr3])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_streetaddr4])
            dump=false;
        
        if (account.account_country)
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_postaladdr1])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_postaladdr2])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_postaladdr3])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_postaladdr4])
            dump=false;
        
        if (account.account_postalcountry)
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_employees])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_warning])
            dump=false;
        
        if (account.account_relationship)
            dump=false;
        
        if (account.account_stdinclass)
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_website])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_accuserdef1_data])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_accuserdef2_data])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_accuserdef3_data])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_accuserdef4_data])
            dump=false;
        
        if (![appDelegate isEmptyString:account.account_notes])
            dump=false;
        
        if (account.account_contacts.count > 0)
            dump=false;
        
        if (account.account_discussions.count > 0)
            dump=false;
        
        if (dump) {
            //[account setValue:[NSNumber numberWithBool:YES] forKey:@"disposal"];
            [[persistenceManager managedObjectContext] deleteObject:account];
        }
    }
    [persistenceManager saveContext];
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
    
  }



-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [appDelegate setPageController:PageAccounts];
    }
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

-(void)accessoryView:(BOOL)hidden
{
    for(id key in self.accessories) {
        ((UISegmentedControl*)[self.accessories objectForKey:key]).tintColor = UIColorFromRGB(0xC84131);
        ((UIView*)[self.accessories objectForKey:key]).hidden=hidden;
    }
    
    self.navigationItem.rightBarButtonItem=self.toggleItem;
}

-(IBAction)bringups:(id)sender
{
    [appDelegate setPageController:PageBringUps];
    [appDelegate setPageRequest:PageRequest_Bringups_Discussions];
    [self performSegueWithIdentifier:@"DiscussionsDataViewSegue" sender:self];
    
}

-(IBAction)helpText:(id)sender
{
    [self performSegueWithIdentifier:@"HelpTextViewSegue" sender:self];
}

-(void)syncEntityObjects:(BOOL)reload
{
    NSArray *results=[persistenceManager entityFetchObjects:ENTITY_ACCOUNT field_name:@"account_name" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"disposal == %@",[NSNumber numberWithBool:NO]];
    _entityObjects = [results filteredArrayUsingPredicate:predicate];
    
    if (reload)
        [self.tableView reloadData];
    
}

-(NSInteger) indexOfEntityObjectStartsWith:(UITableView*)tableView startsWith:(NSString*) startswith
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.account_name beginswith[c] %@", startswith];
    NSArray *indexes;
    if (tableView == _searchDisplayController.searchResultsTableView) {
        indexes = [NSMutableArray arrayWithArray:[self.filteredListItems filteredArrayUsingPredicate:predicate]];
    } else {
        indexes= [NSMutableArray arrayWithArray:[self.entityObjects filteredArrayUsingPredicate:predicate]];
    }

    
    if ([indexes count] == 0)
        return -1;
    
    if (tableView == _searchDisplayController.searchResultsTableView)
        return [self.filteredListItems indexOfObject:[indexes objectAtIndex:0]];
    
    return [self.entityObjects indexOfObject:[indexes objectAtIndex:0]];
    
}



-(IBAction)deleteEntity:(id)sender
{
    NSManagedObject *managedObject = ((SegmentedControl*)sender).managedObject;
    [managedObject setValue:[NSNumber numberWithInteger:YES] forKey:@"disposal"];
    [persistenceManager saveContext];
    [appDelegate setPageObject:nil];
    
    [self syncEntityObjects:YES];
    [_searchDisplayController setActive:NO];
    
}

-(void) edit
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                             target:self action:@selector(toggle:)];
    item.tag= ManagedSections_Edit;
    self.toggleItem=item;
    [self accessoryView:YES];
}

-(void) done
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self action:@selector(toggle:)];
    done.tag= ManagedSections_Done;
    self.toggleItem=done;
    [self accessoryView:NO];
}


- (IBAction) toggle:(id)sender
{
    if (self.entityObjects.count == 0) {
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
    return ManagedSections_Sections;
}

-(UITableViewCell*) fetchObject:(UITableView*)tableView cell:(UITableViewCell*)cell section:(NSInteger)section row:(NSInteger)row
{
 
    if (cell == nil)
        return nil;
    
    if (section == ManagedSections_Data) { //SectionData
        NSString *uuid=@"";
        ACDBAccount *account=nil;
        NSString *group;
        if (tableView == _searchDisplayController.searchResultsTableView){
            account=[self.filteredListItems objectAtIndex:row];
            group=GROUP_FILTERED;
        } else {
            account=[self.entityObjects objectAtIndex:row];
            group=GROUP_NORMAL;
        }
        if ([appDelegate isEmptyString:account.account_name]) {
             ((CellTemplate1View*)cell).template_info1.text=[SOURCE_REQUIRED stringByReplacingOccurrencesOfString:@"_SOURCE_" withString:@"Account name"];
            ((CellTemplate1View*)cell).template_info1.textColor=[UIColor redColor];
        } else {
            ((CellTemplate1View*)cell).template_info1.text=account.account_name;
            ((CellTemplate1View*)cell).template_info1.textColor=[UIColor blackColor];
        }
        ((CellTemplate1View*)cell).template_info2.text=account.account_accountnames_data;
        ((CellTemplate1View*)cell).template_info2.textColor=[UIColor lightGrayColor];
        
        ((CellTemplate1View*)cell).template_info1.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        ((CellTemplate1View*)cell).template_info2.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        uuid=account.uuid;
        uuid=[NSString stringWithFormat:@"%@_%@",group,uuid];
        
        if ([self.accessories objectForKey:uuid]!=nil) {
            ((CellTemplate1View*)cell).accessoryView=[self.accessories objectForKey:uuid];
        } else {
            SegmentedControl *delete = [[SegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Delete", nil]];
            delete.momentary = YES;
            delete.tintColor = UIColorFromRGB(0xC84131);
            delete.managedObject =[self.entityObjects objectAtIndex:row];
            [delete addTarget:self action:@selector(deleteEntity:) forControlEvents:UIControlEventValueChanged];
            
            ((CellTemplate1View*)cell).accessoryView=delete;
            
            if (self.toggleItem.tag == 0)
                ((CellTemplate1View*)cell).accessoryView.hidden=YES;
            
            UIView *view = ((CellTemplate1View*)cell).accessoryView;
            [self.accessories setObject:view forKey:uuid];
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
        row=[self.filteredListItems count];
        
    } else {
        if (section == ManagedSections_Data) {
            row=[self.entityObjects count];
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
        if ([self.entityObjects count] > 0)
            if (self.toggleItem.tag == ManagedSections_Edit)
                [self edit];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [appDelegate setPageObject:nil];
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
    self.navigationItem.title=@"ACCOUNTS";
    if (indexPath.section == ManagedSections_Data) {
        if (tableView == _searchDisplayController.searchResultsTableView){
            [appDelegate setPageObject:[self.filteredListItems objectAtIndex:[indexPath row]]];
        } else {
            [appDelegate setPageObject:[self.entityObjects objectAtIndex:[indexPath row]]];
        }
    }
    [self performSegueWithIdentifier:@"AccountsViewSegue" sender:self];
    [self edit];
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
    [self.filteredListItems removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.account_name beginswith[c] %@ OR SELF.account_accountnames_data beginswith[c] %@", searchText, searchText];
    
    self.filteredListItems=[NSMutableArray arrayWithArray:[self.entityObjects filteredArrayUsingPredicate:predicate]];
    
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
    controller.searchResultsTableView.bounces=NO;
    controller.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
   
    return YES;
}



#pragma Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DebugLog(@"prepareForSegue: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"HelpTextViewSegue"]) {
        [segue.destinationViewController helpTextInfo:ACCOUNTS_HELPTEXT];
    }
}

#pragma PagingView

- (void)doneLoadingTableViewData
{
    [self removeUnusedAccount];
    [_pagingView pagingScrollViewDataSourceDidFinishedLoading:self.tableView];
    _reloadingState = NO;
    [self syncEntityObjects:YES];
    
    
    if ([appDelegate isSessionLinked]) {
        
        [appDelegate confirm:@"Sync to dropbox now ?" result:^(bool result) {
            
            if (result) {

                NSArray *accounts = [persistenceManager entityFetchObjects:ENTITY_ACCOUNT field_name:@"uuid" ascending:NO];
                if (accounts.count > 0) {
                    [appDelegate syncFile:NO];
                    
                } else {
                    MetaFile *metaFile = (MetaFile*)[persistenceManager entityObject:ENTITY_METAFILE];
                    if (metaFile.rev) {
                        [appDelegate syncFile:NO];
                    } else {
                        if (![appDelegate hasInternetConnection]) {
                            [appDelegate alert:@"No internet connection and no local copy available"];
                        }
                    }
                }

            }
            
        }];

        
    }
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



@end
