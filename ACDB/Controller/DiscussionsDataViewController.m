//
//  DataViewController.m
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "DiscussionsDataViewController.h"

@interface DiscussionsDataViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>


@property(nonatomic,strong) NSArray *entityObjects;
@property(nonatomic,strong)NSMutableDictionary *accessories;
@property(nonatomic,strong)NSMutableArray *filteredListItems;
@property(nonatomic,strong)NSMutableSet *discussionSets;
@property (nonatomic, strong) UISearchDisplayController	*searchDisplayController;
-(void)syncEntityObjects;

@end

@implementation DiscussionsDataViewController

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
    _accessories = [[NSMutableDictionary alloc]init];
    
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
    
    if (IS_IOS_7)
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationItem.title isEqualToString:@"Bringups"]) {
        [appDelegate setPageRequest:PageRequest_Bringups_Discussions];
    }
    
    [super viewWillAppear:animated];
    [self syncEntityObjects];
    if ([appDelegate pageRequest] == PageRequest_Account_Discussions) {
        self.navigationItem.title=@"Discussions";
        
        if (_entityObjects.count > 0) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_entityObjects.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }
     } else if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
        self.navigationItem.title=@"Bringups";
    }
    
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
    [self syncEntityObjects];
}

-(IBAction)helpText:(id)sender
{
    [self performSegueWithIdentifier:@"HelpTextViewSegue" sender:self];
}


-(void)syncEntityObjects
{
    NSSortDescriptor *contactdate = [[NSSortDescriptor alloc] initWithKey:@"discussion_contactdate" ascending:YES];
    NSSortDescriptor *bringupdate = [[NSSortDescriptor alloc] initWithKey:@"discussion_bringupdate" ascending:YES];
    
    if ( [appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
        
        NSArray *acbds = [persistenceManager  entityFetchObjects:ENTITY_ACCOUNT field_name:@"account_name" ascending:YES];
      
        _discussionSets = [[NSMutableSet alloc]init];
        for (ACDBAccount *account in acbds) {
            NSSet *discussions=account.account_discussions;
            //check if bringupdate is less than today + 2
            NSDate *date=[ [NSDate date] dateByAddingTimeInterval:(60*60*24*2)];
            for (Discussion *discussion in discussions) {
                if ([discussion.discussion_bringupdate compare:date] !=NSOrderedDescending) {
                    [_discussionSets addObject:discussion];
                }
            }
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"discussion_status != %d AND disposal == %@", 1,[NSNumber numberWithBool:NO]]; //Complete
        _entityObjects = [[_discussionSets filteredSetUsingPredicate:predicate] allObjects];
        _entityObjects = [_entityObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:bringupdate, nil]];
        
    } else {
        if ([appDelegate acdbAccount].account_discussions.count <=0) {
            _entityObjects=nil;
            [self.tableView reloadData];
            return;
        }
        
       
        
        _entityObjects = [[appDelegate acdbAccount].account_discussions sortedArrayUsingDescriptors:[NSArray arrayWithObjects:contactdate, nil]];
    }
    
    [self.tableView reloadData];
}

/*
-(NSInteger) indexOf_entityObjectstartsWith:(UITableView*)tableView startsWith:(NSString*) startswith
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.discussion_contactperson.contact_nickname beginswith[c] %@ OR SELF.discussion_contactperson.contact_firstname beginswith[c] %@ OR SELF.discussion_contactperson.contact_lastname beginswith[c] %@", startswith, startswith,startswith];
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
 */

-(IBAction)controlsEntity:(id)sender
{
    Discussion *discussion=(Discussion*)((SegmentedControl*)sender).managedObject;
    
    if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
        [appDelegate setAcdbAccount:discussion.discussion];
    }
    
    if (self.toggleItem.tag == ManagedSections_Edit) { //Pre-edit
        [[appDelegate acdbAccount] removeAccount_discussionsObject:discussion];
        
        if([discussion.discussion_status intValue] == 1) { //YES
            [discussion setValue:[NSNumber numberWithBool:NO] forKey:@"discussion_status"];
        } else {
            [discussion setValue:[NSNumber numberWithBool:YES] forKey:@"discussion_status"];
        }
        [[appDelegate acdbAccount] addAccount_discussionsObject:discussion];
    } else {
        [[appDelegate acdbAccount] removeAccount_discussionsObject:discussion];
        
    }
    
    [persistenceManager saveContext];
    [appDelegate setPageObject:nil];
    [self syncEntityObjects];
    
    [_searchDisplayController setActive:NO];
    
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
    item.tag= ManagedSections_Edit;
    self.toggleItem=item;
    self.navigationItem.rightBarButtonItem=self.toggleItem;
    [_accessories removeAllObjects];
    [self syncEntityObjects];
  
    
    //[self accessoryView:YES];
    /*
    for(id key in _accessories) {
        SegmentedControl *control=(SegmentedControl*)[_accessories objectForKey:key];
        control.hidden=YES;
        Discussion *discussion = (Discussion*)control.managedObject;
        [control setWidth: (IS_IOS_7 ? 80.0f : 65.0f) forSegmentAtIndex:0];
        control.tintColor= self.navigationController.navigationBar.tintColor;
        
        CGRect frame= control.frame;
        [control setFrame:CGRectMake(frame.origin.x,frame.origin.y, frame.size.width, 15.0f)];
        
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    IS_IOS_7 ? control.tintColor : [UIColor whiteColor], UITextAttributeTextColor,
                                    nil];
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];

        if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
            control.hidden=NO;
            
            
            [control setTitle:[dateFormat stringFromDate:discussion.discussion_bringupdate] forSegmentAtIndex:0];
        } else {
            control.hidden=NO;
            if ([discussion.discussion_status intValue] ==1 ) { //Complete
                attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIColor greenColor], UITextAttributeTextColor,
                               nil];
                [control setTitle:@"Complete" forSegmentAtIndex:0];
            } else {
                [control setTitle:[dateFormat stringFromDate:discussion.discussion_bringupdate] forSegmentAtIndex:0];
            }
        }
        [control setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        
    }
    self.navigationItem.rightBarButtonItem=self.toggleItem;
     */
}

-(void) done
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self action:@selector(toggle:)];
    done.tag= ManagedSections_Done;
    self.toggleItem=done;
     self.navigationItem.rightBarButtonItem=self.toggleItem;
    /*
    for(id key in _accessories) {
        SegmentedControl *control=(SegmentedControl*)[_accessories objectForKey:key];
        control.hidden=NO;
        control.tintColor=UIColorFromRGB(0xC84131);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    IS_IOS_7 ? control.tintColor : [UIColor whiteColor], UITextAttributeTextColor,
                                    nil];

        [control setWidth:55.0f forSegmentAtIndex:0];
        [control setTitle:@"Delete" forSegmentAtIndex:0];
        [control setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem=self.toggleItem;
     */
    //[self accessoryView:NO];
    [_accessories removeAllObjects];
    [self syncEntityObjects];
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
    if ([appDelegate pageRequest] == PageRequest_Account_Discussions) {
        return ManagedSections_Sections;
    } else {
        return 1;
    }
}

-(UITableViewCell*) fetchObject:(UITableView*)tableView cell:(UITableViewCell*)cell section:(NSInteger)section row:(NSInteger)row
{
    
    if (cell == nil)
        return nil;
    
    if (section == ManagedSections_Data) { //SectionData
        NSString *uuid=@"";
        Discussion *discussion;
        NSString *group;
        if(tableView == _searchDisplayController.searchResultsTableView) {
            discussion=[_filteredListItems objectAtIndex:row];
            group=GROUP_FILTERED;
        } else {
            discussion=[_entityObjects objectAtIndex:row];
            group=GROUP_NORMAL;
        }
        /*
        if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
            [appDelegate setAcdbAccount:discussion.discussion];
        }*/
        uuid=discussion.uuid;
        uuid=[NSString stringWithFormat:@"%@_%@",group,uuid];
        NSString *contactType=@"";
        NSString *contactHeader=@"";
        
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];

        ((CellBringupsView*)cell).bringups_contactdate.text=[dateFormat stringFromDate:discussion.discussion_contactdate];
        
        ((CellBringupsView*)cell).bringups_header.text=@"";
        if (discussion.discussion_contactperson) {
            NSString *firstname=@"";
            NSString *lastname=@"";
            if (![appDelegate isEmptyString:discussion.discussion_contactperson.contact_nickname]) {
                firstname=discussion.discussion_contactperson.contact_nickname;
            } else {
                if (![appDelegate isEmptyString:discussion.discussion_contactperson.contact_firstname]) {
                    firstname=discussion.discussion_contactperson.contact_firstname;
                }
            }
            if (![appDelegate isEmptyString:discussion.discussion_contactperson.contact_lastname]) {
                lastname=discussion.discussion_contactperson.contact_lastname;
            }
            ((CellBringupsView*)cell).bringups_header.text=[NSString stringWithFormat:@"%@ %@",firstname , lastname];
        }
        
        if (discussion.discussion_contacttype) {
            contactType = discussion.discussion_contacttype.contacttype_name;
        }
        if (![appDelegate isEmptyString:discussion.discussion_contactheader]) {
            contactHeader=discussion.discussion_contactheader;
        }
        
        ((CellBringupsView*)cell).bringups_subheader.text=@"";
        if ([appDelegate pageRequest] == PageRequest_Account_Discussions) {
            ((CellBringupsView*)cell).bringups_subheader.text=[NSString stringWithFormat:@"%@ - %@", contactType, contactHeader];
        } else if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
            
            NSString *account_name=@"";
            if (![appDelegate isEmptyString:discussion.discussion.account_name])
                account_name=discussion.discussion.account_name;
            
            ((CellBringupsView*)cell).bringups_subheader.text=[NSString stringWithFormat:@"%@ - %@ - %@", account_name,
                                                               contactType, contactHeader];
        }
        
        if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
            ((CellBringupsView*)cell).bringups_bringupdate.text=[dateFormat stringFromDate:discussion.discussion_bringupdate];
        } else {
            if ([discussion.discussion_status intValue] ==1 ) { //Complete
                ((CellBringupsView*)cell).bringups_bringupdate.text=@"Complete";
                ((CellBringupsView*)cell).bringups_bringupdate.textColor=[UIColor greenColor];
                
            } else {
                ((CellBringupsView*)cell).bringups_bringupdate.text=[dateFormat stringFromDate:discussion.discussion_bringupdate];
                ((CellBringupsView*)cell).bringups_bringupdate.textColor=[UIColor blackColor];
            }
        }
        ((CellBringupsView*)cell).bringups_bringupdate.layer.borderWidth = 1.0f;
        ((CellBringupsView*)cell).bringups_bringupdate.layer.borderColor = [UIColor lightGrayColor].CGColor;
        ((CellBringupsView*)cell).bringups_bringupdate.layer.cornerRadius = 3.0f;
        ((CellBringupsView*)cell).bringups_bringupdate.topInset=3;
       
        
        ((CellBringupsView*)cell).bringups_bringupdateEnControl.managedObject=discussion;
        [((CellBringupsView*)cell).bringups_bringupdateEnControl removeTarget:self action:@selector(controlsEntity:)
                                                          forControlEvents:UIControlEventTouchUpInside];
        [((CellBringupsView*)cell).bringups_bringupdateEnControl addTarget:self action:@selector(controlsEntity:)
                                                          forControlEvents:UIControlEventTouchUpInside];
        
        ((CellBringupsView*)cell).accessoryView=nil;
        ((CellBringupsView*)cell).bringups_bringupdate.hidden=NO;
        ((CellBringupsView*)cell).bringups_bringupdateEnControl.hidden=NO;
        
         if ([_accessories objectForKey:uuid]!=nil) {
             if (self.toggleItem.tag == ManagedSections_Done) {
                 ((CellBringupsView*)cell).accessoryView=[_accessories objectForKey:uuid];
                 ((CellBringupsView*)cell).bringups_bringupdate.hidden=YES;
                 ((CellBringupsView*)cell).bringups_bringupdateEnControl.hidden=YES;
             }
        } else {
            if (self.toggleItem.tag == ManagedSections_Done) {
                SegmentedControl *controls = [[SegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Delete", nil]];
                controls.momentary = YES;
                controls.tintColor = UIColorFromRGB(0xC84131);
                controls.managedObject =discussion;
                [controls addTarget:self action:@selector(controlsEntity:) forControlEvents:UIControlEventValueChanged];
                
                ((CellBringupsView*)cell).accessoryView=controls;
                
                UIView *view = ((CellBringupsView*)cell).accessoryView;
                [_accessories setObject:view forKey:uuid];
                ((CellBringupsView*)cell).bringups_bringupdate.hidden=YES;
                ((CellBringupsView*)cell).bringups_bringupdateEnControl.hidden=YES;
            }
        }
        
    } 
    return cell;
    
}



-(CGFloat)heightSectionRow:(NSInteger)section
{
    CGFloat height=0;
    if (section == ManagedSections_Data) {
        height=38;
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellBringups"];
        if (cell == nil) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                cellType=@"CellBringupsView-iphone";
             } else {
                cellType=@"CellBringupsView-ipad";
            }
            [[NSBundle mainBundle] loadNibNamed:cellType owner:self options:nil];
            
            cell=self.cellBringups;
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

#pragma mark - Table view 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _searchDisplayController.searchResultsTableView)
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
    cell=[self fetchObject:tableView  cell:cell section:indexPath.section row:indexPath.row];
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
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *tempView =(UIButton *)[self.navigationController.navigationBar viewWithTag:HELPTEXT];
    [tempView removeFromSuperview];
    
    
    [appDelegate setPageObject:nil];
    if ([appDelegate pageRequest] == PageRequest_Account_Discussions) {
        self.navigationItem.title=@"Discussions";
    } else if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
        self.navigationItem.title=@"Bringups";
    }
    
    if (indexPath.section == ManagedSections_Data) {
        if (tableView == _searchDisplayController.searchResultsTableView) {
            [appDelegate setPageObject:[_filteredListItems objectAtIndex:[indexPath row]]];
        } else {
            [appDelegate setPageObject:[_entityObjects objectAtIndex:[indexPath row]]];
        }
        Discussion *discussion=(Discussion*)[appDelegate pageObject];
        if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
            [appDelegate setAcdbAccount:discussion.discussion];
        }

    }
    [self performSegueWithIdentifier:@"DiscussionsViewSegue" sender:self];
    [self edit];

    
    

   
}

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
   
    return[NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E",@"F", @"G", @"H", @"I", @"J",@"K", @"L", @"M", @"N", @"O",
           @"P", @"Q", @"R", @"S", @"T",@"U", @"V", @"W", @"X", @"Y",@"Z",nil];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    NSInteger idx=[self indexOf_entityObjectstartsWith:tableView startsWith:title];
    if (idx != -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:SECTION_DATA];
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
 */


#pragma Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DebugLog(@"prepareForSegue: %@", segue.identifier);
   if ([segue.identifier isEqualToString:@"HelpTextViewSegue"]) {
       if ([appDelegate pageRequest] == PageRequest_Bringups_Discussions) {
           [segue.destinationViewController helpTextInfo:BRINGUPS_HELPTEXT];
       } else {
           [segue.destinationViewController helpTextInfo:DISCUSSIONS_HELPTEXT];
       }
       
   }
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
    
    [self edit];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText {
 
    [_filteredListItems removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.discussion_contactperson.contact_nickname beginswith[c] %@ OR SELF.discussion_contactperson.contact_firstname beginswith[c] %@ OR SELF.discussion_contactperson.contact_lastname beginswith[c] %@ OR SELF.discussion_contacttype.contacttype_name beginswith[c] %@ OR SELF.discussion_contactheader beginswith[c] %@",
                              searchText,searchText,searchText,searchText,searchText];
    _filteredListItems = [NSMutableArray arrayWithArray:[_entityObjects filteredArrayUsingPredicate:predicate]];
   
   /*
    NSSortDescriptor *contactdate = [[NSSortDescriptor alloc] initWithKey:@"discussion_contactdate" ascending:NO];
    NSSortDescriptor *bringupdate = [[NSSortDescriptor alloc] initWithKey:@"discussion_bringupdate" ascending:NO];

    _filteredListItems=[NSMutableArray arrayWithArray:[_filteredListItems sortedArrayUsingDescriptors:[NSArray arrayWithObjects:contactdate, bringupdate, nil]]];
    */
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
