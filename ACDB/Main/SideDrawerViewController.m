//
//  SideDrawerViewController.m
//  ACDB
//
//  Created by Rommel Sumpo on 8/10/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//



#import "SideDrawerViewController.h"

@interface SideDrawerViewController ()
@property NSInteger currentMenu;
@property NSInteger selectedMenu;
@end

@implementation SideDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.navigationBar];
    
     for (NSInteger section = 0; section < [self.tableView numberOfSections]; ++section){
        for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:section]; ++row){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            [cell.contentView setBackgroundColor:[UIColor darkGrayColor]];
            cell.backgroundColor = cell.contentView.backgroundColor;
        }
    }
    _currentMenu = 0;
    _selectedMenu = _currentMenu;
    
    [self.mm_drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         UIViewController * sideDrawerViewController;
         if(drawerSide == MMDrawerSideLeft){
             sideDrawerViewController = drawerController.leftDrawerViewController;
         }
         else if(drawerSide == MMDrawerSideRight){
             sideDrawerViewController = drawerController.rightDrawerViewController;
         }
         [sideDrawerViewController.view setAlpha:percentVisible];
     }];
    
    [self dropboxConnectionStatus];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self layoutNavigationBar];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notificationForeground:)
     name:@"notificationForeground"
     object:nil];
    
    
    [self dropboxConnectionStatus];

}


-(void)layoutNavigationBar{
    self.navigationBar.frame = CGRectMake(0, self.tableView.contentOffset.y, self.tableView.frame.size.width, self.topLayoutGuide.length + 44);
    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutNavigationBar];
}

#pragma mark - Notification
-(void)notificationForeground:(NSNotification*)notification {
    [self dropboxConnectionStatus];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        if ([self.dropboxConnection.text rangeOfString:@"Login"].location != NSNotFound) {
            [self configMenu:indexPath.row];
            [appDelegate delay:0.5 callbackBlock:^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }];
            return;
        }
    }
   
    if ([[DBSession sharedSession] isLinked]) {
        if (_currentMenu == indexPath.row) {
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
            
        } else {
            [self configMenu:indexPath.row];
        }

    } else {
        [appDelegate alert:@"No dropbox connection available"];
    }
    
    [appDelegate delay:0.5 callbackBlock:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];

}


- (void) configMenu:(NSInteger)menu {
    UIViewController *centerViewController;
    
    switch (menu) {
        case 0:
             if ([[DBSession sharedSession] isLinked]) {
                 centerViewController = [appDelegate getStoryboardView:@"AccountsDataViewController"];
             } else {
                  [appDelegate alert:@"No dropbox connection available"];
             }
            
            break;
        case 1:
            
            if ([[DBSession sharedSession] isLinked]) {
                
                [appDelegate confirm:@"Sync to dropbox now ?" result:^(bool result) {
                    
                    if (result) {
                        
                        NSArray *accounts = [persistenceManager entityFetchObjects:ENTITY_ACCOUNT field_name:@"uuid" ascending:NO];
                        if (accounts.count > 0) {
                            [appDelegate syncFile:NO runBackup:YES];
                            
                        } else {
                            MetaFile *metaFile = (MetaFile*)[persistenceManager entityObject:ENTITY_METAFILE];
                            if (metaFile.rev) {
                                [appDelegate syncFile:NO runBackup:YES];
                                
                                
                                
                            } else {
                                if (![appDelegate hasInternetConnection]) {
                                    [appDelegate alert:@"No internet connection and no local copy available"];
                                }
                            }
                        }
                        
                    }
                    
                }];
            } else {
                [appDelegate alert:@"No dropbox connection available"];
            }
            break;
            
        case 2:
            if ([self.dropboxConnection.text rangeOfString:@"Login"].location != NSNotFound) {
                [[DBSession sharedSession] linkFromController:[appDelegate controller]];
                
            } else {
                
                if ([[DBSession sharedSession] isLinked]) {
                     [appDelegate confirm:@"Make sure you have synced the local copy into dropbox before logging out. Logging out now ?" result:^(bool result) {
                        
                        if (result) {
                            [appDelegate logout];
                            [appDelegate delay:1.0 callbackBlock:^{
                                [self dropboxConnectionStatus];
                            }];
                            
                        }
                    }];
                }
            }
            break;
    }
    
    if (centerViewController) {
        _currentMenu = menu;
        _selectedMenu = _currentMenu;
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
    }
    
}

- (void) dropboxConnectionStatus
{
    [appDelegate delay:0.5 callbackBlock:^{
        self.dropboxConnection.text = @"Logout (Dropbox)";
        if (![[DBSession sharedSession] isLinked]) {
            self.dropboxConnection.text = @"Login (Dropbox)";
        }
    }];
    
}

@end
