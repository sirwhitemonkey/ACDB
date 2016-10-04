//
//  DataViewController.m
//  ACDB
//
//  Created by Rommel on 12/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UIAlertViewDelegate>
@property BOOL sort;
@property(nonatomic,strong) NSMutableArray *entityObjects;
@property(nonatomic,strong) NSMutableDictionary *accessories;
@property (nonatomic, strong) UISearchDisplayController	*searchDisplayController;
@property(nonatomic,strong)NSMutableArray *filteredListItems;

 -(void)syncEntityObjects;
-(IBAction)deleteEntity:(id)sender;
@end

@implementation DataViewController

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
    _accessories=[[NSMutableDictionary alloc]init];
   
  
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
    
   [self syncEntityObjects];
    if (_entityObjects.count == 0) {
        [appDelegate setPageObject:nil];
        [self navigationItemTitle];
        [self performSegueWithIdentifier:@"MasterViewSegue" sender:self];
    }
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationItemTitle];
    self.navigationController.navigationBar.translucent=NO;
    [self syncEntityObjects];
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

-(void) navigationItemTitle
{
    switch((int)[appDelegate pageController]) {
        case PageRelationship:
            self.navigationItem.title=@"Relationship";
            break;
        case PageStdInClass:
            self.navigationItem.title=@"Std Ind Class";
            break;
        case PageCountry:
            self.navigationItem.title=@"Country";
            break;
        case PageSupportLevel:
            self.navigationItem.title=@"Support Level";
            break;
        case PageBuyingPower:
            self.navigationItem.title=@"Buying Power";
            break;
        case PageContactType:
            self.navigationItem.title=@"Contact Type";
            break;
        case PageAccountNames:
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
            self.navigationItem.title=@"Soft Label";
            break;

    }
}

-(void)syncEntityObjects
{
     _entityObjects=[[NSMutableArray alloc]init];
    switch((int)[appDelegate pageController]) {
        case PageAccounts:
            break;
        case PageRelationship:
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:ENTITY_RELATIONSHIP field_name:@"priority" ascending:YES]];
            break;
        case PageStdInClass:
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:ENTITY_STDINCLASS field_name:@"stdinclass_name" ascending:YES]];
            break;
        case PageCountry:
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:ENTITY_COUNTRY field_name:@"country_name" ascending:YES]];
            break;
        case PageBuyingPower:
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:ENTITY_BUYINGPOWER field_name:@"priority" ascending:YES]];
            break;
        case PageSupportLevel:
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:ENTITY_SUPPORTLEVEL field_name:@"priority" ascending:YES]];
            break;
        case PageContactType:
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:ENTITY_CONTACTTYPE field_name:@"contacttype_name" ascending:YES]];
            break;
        case PageAccountNames:
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:ENTITY_ACCOUNTNAMES field_name:@"accountnames_name" ascending:YES]];
            break;
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
        {
            NSString *entity;
            if ([appDelegate pageController] == PageAccUserDef1) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,1];
            }else if ([appDelegate pageController] == PageAccUserDef2) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,2];
            }else if ([appDelegate pageController] == PageAccUserDef3) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,3];
            }else if ([appDelegate pageController] == PageAccUserDef4) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,4];
            }
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:entity field_name:@"accuserdef_name" ascending:YES]];
        }
            break;
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
        {
            NSString *entity;
            if ([appDelegate pageController] == PageConUserDef1) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,1];
            }else if ([appDelegate pageController] == PageConUserDef2) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,2];
            }else if ([appDelegate pageController] == PageConUserDef3) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,3];
            }else if ([appDelegate pageController] == PageConUserDef4) {
                entity =[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,4];
            }
            [_entityObjects addObjectsFromArray:[persistenceManager  entityFetchObjects:entity field_name:@"conuserdef_name" ascending:YES]];
        }
            break;

    
            
    }
    if (_entityObjects.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"disposal == %@",[NSNumber numberWithBool:NO]];
        [_entityObjects filterUsingPredicate:predicate];
        
    }
   
    
    [self.tableView reloadData];
}

-(NSInteger) indexOfEntityObjectStartsWith:(UITableView*)tableView startsWith:(NSString*) startswith
{
    NSString *field_name;
    switch((int)[appDelegate pageController]) {
        case PageAccounts:
            break;
        case PageRelationship:
            field_name=@"relationship_name";
            break;
        case PageStdInClass:
            field_name=@"stdinclass_name";
            break;
        case PageCountry:
            field_name=@"country_name";
            break;
        case PageBuyingPower:
            field_name=@"buyingpower_name";
            break;
        case PageSupportLevel:
            field_name=@"supportlevel_name";
            break;
        case PageContactType:
            field_name=@"contacttype_name";
            break;
        case PageAccountNames:
            field_name=@"accountnames_name";
            break;
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
            field_name=@"accuserdef_name";
            break;
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
            field_name=@"conuserdef_name";
            break;
    
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ beginswith[c] %@", field_name,startswith];
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
    item.tag= ManagedSections_Edit;
    self.toggleItem=item;
    [self accessoryView:YES];
    if ([appDelegate pageController] == PageRelationship ||
        [appDelegate pageController] == PageBuyingPower ||
        [appDelegate pageController] == PageSupportLevel)
        [self.tableView setEditing:NO animated:YES];
    
    if (_sort) {
        _sort=false;
        [self syncEntityObjects];
        _searchDisplayController.searchBar.hidden=NO;
    }
 }

-(void) done
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self action:@selector(toggle:)];
    done.tag= ManagedSections_Done;
    self.toggleItem=done;
    
    
    if ([appDelegate pageController] == PageRelationship ||
        [appDelegate pageController] == PageBuyingPower ||
        [appDelegate pageController] == PageSupportLevel) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:Nil delegate:self cancelButtonTitle:@"Modify" otherButtonTitles:@"_sort",nil];
        [alert show];
    } else {
        [self accessoryView:NO];
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        [self accessoryView:NO];
    } else if (buttonIndex == 1){
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem=self.toggleItem;
        _sort=true;
        [self syncEntityObjects];
        _searchDisplayController.searchBar.hidden=YES;
    }
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



-(IBAction)deleteEntity:(id)sender
{
    NSManagedObject *managedObject = ((SegmentedControl*)sender).managedObject;
    //[managedObject setValue:[NSNumber numberWithInteger:YES] forKey:@"disposal"];
    [[persistenceManager managedObjectContext] deleteObject:managedObject];
    [persistenceManager saveContext];
    [appDelegate setPageObject:nil];
  
    [self syncEntityObjects];
    [_searchDisplayController setActive:NO];

}

-(NSInteger)sections
{
    NSInteger section=0;
    if (_sort) {
        section= 1;
    } else {
        switch ((int)[appDelegate pageController]) {
            case PageAccounts:
            case PageRelationship:
            case PageStdInClass:
            case PageCountry:
            case PageSupportLevel:
            case PageBuyingPower:
            case PageContactType:
            case PageAccountNames:
            case PageAccUserDef1:
            case PageAccUserDef2:
            case PageAccUserDef3:
            case PageAccUserDef4:
            case PageConUserDef1:
            case PageConUserDef2:
            case PageConUserDef3:
            case PageConUserDef4:
                section=ManagedSections_Sections;
                break;
            default:
                break;
        }
    }
    return section;
}

-(UITableViewCell*) fetchObject:(UITableView*)tableView cell:(UITableViewCell*)cell section:(NSInteger)section row:(NSInteger)row
{
    if (cell == nil)
        return nil;
    
    if (section == ManagedSections_Data) { //SectionData
        NSString *uuid=@"";
        
        switch ((int)[appDelegate pageController]) {
            case PageAccounts:
                break;
                
            case PageRelationship:
            {
                Relationship *relationship;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    relationship=[_filteredListItems objectAtIndex:row];
                } else {
                    relationship=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=relationship.relationship_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=relationship.uuid;
            }
                break;
                
            case PageStdInClass:
            {
                StdInClass *stdinclass;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    stdinclass=[_filteredListItems objectAtIndex:row];
                } else {
                    stdinclass=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=stdinclass.stdinclass_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=stdinclass.uuid;

            }
                break;
                
            case PageCountry:
            {
                Country *country;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    country=[_filteredListItems objectAtIndex:row];
                } else {
                    country=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=country.country_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=country.uuid;
            }
                break;
                
            case PageBuyingPower:
            {
                BuyingPower *buyingpower;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    buyingpower=[_filteredListItems objectAtIndex:row];
                } else {
                    buyingpower=[_entityObjects objectAtIndex:row];
                }

                ((CellTemplate2View*)cell).template_info.text=buyingpower.buyingpower_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=buyingpower.uuid;
            }
                break;
                
            case PageSupportLevel:
            {
                SupportLevel *supportlevel;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    supportlevel=[_filteredListItems objectAtIndex:row];
                } else {
                    supportlevel=[_entityObjects objectAtIndex:row];
                }

                ((CellTemplate2View*)cell).template_info.text=supportlevel.supportlevel_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=supportlevel.uuid;
            }
                break;

            case PageContactType:
            {
                ContactType *contacttype;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    contacttype=[_filteredListItems objectAtIndex:row];
                } else {
                    contacttype=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=contacttype.contacttype_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=contacttype.uuid;
            }
                break;
            case PageAccountNames:
            {
                AccountNames *accountnames;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    accountnames=[_filteredListItems objectAtIndex:row];
                } else {
                    accountnames=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=accountnames.accountnames_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=accountnames.uuid;
            }
                break;
            case PageAccUserDef1:
            {
                AccUserDef1 *accuserdef1;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    accuserdef1=[_filteredListItems objectAtIndex:row];
                } else {
                    accuserdef1=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=accuserdef1.accuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=accuserdef1.uuid;
            }
                break;
            case PageAccUserDef2:
            {
                AccUserDef2 *accuserdef2;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    accuserdef2=[_filteredListItems objectAtIndex:row];
                } else {
                    accuserdef2=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=accuserdef2.accuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=accuserdef2.uuid;
            }
                break;
            case PageAccUserDef3:
            {
                AccUserDef3 *accuserdef3;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    accuserdef3=[_filteredListItems objectAtIndex:row];
                } else {
                    accuserdef3=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=accuserdef3.accuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=accuserdef3.uuid;
            }
                break;
            case PageAccUserDef4:
            {
                AccUserDef4 *accuserdef4;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    accuserdef4=[_filteredListItems objectAtIndex:row];
                } else {
                    accuserdef4=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=accuserdef4.accuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=accuserdef4.uuid;
            }
                break;
            case PageConUserDef1:
            {
                ConUserDef1 *conuserdef1;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    conuserdef1=[_filteredListItems objectAtIndex:row];
                } else {
                    conuserdef1=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=conuserdef1.conuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=conuserdef1.uuid;
            }
                break;
            case PageConUserDef2:
            {
                ConUserDef2 *conuserdef2;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    conuserdef2=[_filteredListItems objectAtIndex:row];
                } else {
                    conuserdef2=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=conuserdef2.conuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=conuserdef2.uuid;
            }
                break;
            case PageConUserDef3:
            {
                ConUserDef3 *conuserdef3;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    conuserdef3=[_filteredListItems objectAtIndex:row];
                } else {
                    conuserdef3=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=conuserdef3.conuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=conuserdef3.uuid;
            }
                break;
            case PageConUserDef4:
            {
                ConUserDef4 *conuserdef4;
                if (tableView == _searchDisplayController.searchResultsTableView){
                    conuserdef4=[_filteredListItems objectAtIndex:row];
                } else {
                    conuserdef4=[_entityObjects objectAtIndex:row];
                }
                ((CellTemplate2View*)cell).template_info.text=conuserdef4.conuserdef_name;
                ((CellTemplate2View*)cell).template_info.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                uuid=conuserdef4.uuid;
            }
                break;


            default:
                break;
        }
        
        NSString *group;
        if (tableView == _searchDisplayController.searchResultsTableView) {
            group=GROUP_FILTERED;
        } else {
            group=GROUP_NORMAL;
        }
        uuid=[NSString stringWithFormat:@"%@_%@",group,uuid];
        
        if ([_accessories objectForKey:uuid]!=nil) {
            ((CellTemplate2View*)cell).accessoryView=[_accessories objectForKey:uuid];
        } else {
            SegmentedControl *delete = [[SegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Delete", nil]];
            delete.momentary = YES;
            delete.tintColor = UIColorFromRGB(0xC84131);
            delete.managedObject =[_entityObjects objectAtIndex:row];
            [delete addTarget:self action:@selector(deleteEntity:) forControlEvents:UIControlEventValueChanged];
            
            ((CellTemplate2View*)cell).accessoryView=delete;
            
            if (self.toggleItem.tag == 0)
                ((CellTemplate2View*)cell).accessoryView.hidden=YES;
            
            UIView *view = ((CellTemplate2View*)cell).accessoryView;
            [_accessories setObject:view forKey:uuid];
            
        }
      }
    return cell;
    
}




-(CGFloat)heightSectionRow:(NSInteger)section
{
    CGFloat height=0;
    switch ((int)[appDelegate pageController]) {
        case PageRelationship:
        case PageStdInClass:
        case PageCountry:
        case PageSupportLevel:
        case PageBuyingPower:
        case PageContactType:
        case PageAccountNames:
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
            if (section == ManagedSections_Data)//Template2
                height=30;
            break;
    }
    if (section == ManagedSections_AddEdit)
        height=26;
    
    return height;
}


-(UITableViewCell*)cell:(UITableView *)tableView section:(NSInteger)section
{
    UITableViewCell *cell;
    NSString *cellType;
    switch((int)[appDelegate pageController]) {
        case PageAccounts:
            if (section == ManagedSections_Data) { //Template1
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellTemplate1"];
                if (cell == nil) {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        cellType=@"CellTemplate1View-iphone";
                    } else {
                        cellType=@"CellTemplate1View-ipad";
                    }
                    [[NSBundle mainBundle] loadNibNamed:cellType owner:self options:nil];
                    cell=self.cellTemplate2;
                }
            }
            break;
        case PageRelationship:
        case PageStdInClass:
        case PageCountry:
        case PageBuyingPower:
        case PageSupportLevel:
        case PageContactType:
        case PageAccountNames:
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
            if (section == ManagedSections_Data) { //Template2
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellTemplate2"];
                if (cell == nil) {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        cellType=@"CellTemplate2View-iphone";
                    } else {
                        cellType=@"CellTemplate2View-ipad";
                    }
                    [[NSBundle mainBundle] loadNibNamed:cellType owner:self options:nil];
                    cell=self.cellTemplate2;
                }
            }
            break;
    }
    if (section == ManagedSections_AddEdit) {
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
    if (tableView == _searchDisplayController.searchResultsTableView)
        return 1;
    
    return [self sections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row=0;
    if (tableView == _searchDisplayController.searchResultsTableView) {
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
     return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightSectionRow:indexPath.section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch((int)[appDelegate pageController]) {
        case PageAccounts:
            if (indexPath.section == ManagedSections_AddEdit) {
                self.navigationItem.title=@"Accounts";
                [self performSegueWithIdentifier:@"AccountsViewSegue" sender:self];
            }
            break;
        case PageRelationship:
        case PageStdInClass:
        case PageCountry:
        case PageSupportLevel:
        case PageBuyingPower:
        case PageContactType:
        case PageAccountNames:
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
            if (indexPath.section == ManagedSections_Data) {
                if (self.toggleItem.tag == ManagedSections_Done) {
                    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                            target:self action:@selector(toggle:)];
                    item.tag= ManagedSections_Edit;
                    if(tableView == _searchDisplayController.searchResultsTableView) {
                        [appDelegate setPageObject:[_filteredListItems objectAtIndex:indexPath.row]];
                    } else {
                        [appDelegate setPageObject:[_entityObjects objectAtIndex:indexPath.row]];
                    }
                    self.toggleItem=item;
                    self.navigationItem.rightBarButtonItem=self.toggleItem;
                    [self accessoryView:YES];
                    [self navigationItemTitle];
                    [self performSegueWithIdentifier:@"MasterViewSegue" sender:self];
                } else {
                    self.navigationItem.title=@"Accounts";
                    [appDelegate setPageObject:[_entityObjects objectAtIndex:indexPath.row]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }else if (indexPath.section == ManagedSections_AddEdit) {
                [appDelegate setPageObject:nil];
                [self navigationItemTitle];
                [self performSegueWithIdentifier:@"MasterViewSegue" sender:self];
            }
           
            break;

    }
    [self edit];

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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([appDelegate pageController] == PageRelationship ||
        [appDelegate pageController] == PageBuyingPower ||
        [appDelegate pageController] == PageSupportLevel)
        return nil;
    
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


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ManagedSections_AddEdit)
        return NO;
    
    if ([appDelegate pageController] == PageRelationship ||
        [appDelegate pageController] == PageBuyingPower ||
        [appDelegate pageController] == PageSupportLevel)
        return YES;
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (destinationIndexPath.section == ManagedSections_Data) {
        NSManagedObject *objectToMove = [_entityObjects objectAtIndex:sourceIndexPath.row];
        [_entityObjects  removeObjectAtIndex:sourceIndexPath.row];
        [_entityObjects insertObject:objectToMove atIndex:destinationIndexPath.row];
        
        dispatch_async(dispatch_get_main_queue(),^ {
           
            NSInteger priority=0;
            for (NSManagedObject *managedObject in _entityObjects) {
                [managedObject setValue:[NSNumber numberWithInteger:priority] forKey:@"priority"];
                priority++;
            }
            [persistenceManager  saveContext];
        });
    }
 }

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

/*
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
 */

#pragma Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DebugLog(@"prepareForSegue: %@", segue.identifier);
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
    
    NSString *field_name;
    switch((int)[appDelegate pageController]) {
        case PageRelationship:
            field_name=@"relationship_name";
            break;
        case PageStdInClass:
            field_name=@"stdinclass_name";
            break;
        case PageBuyingPower:
            field_name=@"buyingpower_name";
            break;
        case PageSupportLevel:
            field_name=@"supportlevel_name";
            break;
        case PageContactType:
            field_name=@"contacttype_name";
            break;
        case PageCountry:
            field_name=@"country_name";
            break;
        case PageAccountNames:
            field_name=@"accountnames_name";
            break;
        case PageAccUserDef1:
        case PageAccUserDef2:
        case PageAccUserDef3:
        case PageAccUserDef4:
            field_name=@"accuserdef_name";
            break;
        case PageConUserDef1:
        case PageConUserDef2:
        case PageConUserDef3:
        case PageConUserDef4:
            field_name=@"conuserdef_name";
            break;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ beginswith[c] %@", field_name, searchText];
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
