//
//  SideDrawerViewController.h
//  ACDB
//
//  Created by Rommel Sumpo on 8/10/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface SideDrawerViewController : UITableViewController
@property (nonatomic,strong) IBOutlet UINavigationBar *navigationBar;
@property(nonatomic,strong) IBOutlet UILabel *dropboxConnection;


@end
