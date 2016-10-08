//
//  PageController.m
//  ACDB
//
//  Created by Rommel Sumpo on 8/10/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self performSegueWithIdentifier:@"DrawerViewSegue" sender:self];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DrawerViewSegue"]) {
        
        NSString *storyboardName = @"Main_iPhone";
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            storyboardName = @"Main_iPad";
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName
                                                             bundle: nil];
        
        MMDrawerController *destinationViewController = (MMDrawerController *) segue.destinationViewController;
        
        [appDelegate setController:destinationViewController];
        
        
        
        

        // Instantitate the center content
        UIViewController *centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"AccountsDataViewController"];
        [destinationViewController setCenterViewController:centerViewController];
        
        // Instantiate the left content
        UIViewController *leftDrawerViewController = [storyboard instantiateViewControllerWithIdentifier:@"SideDrawerViewController"];
        [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
        
        [destinationViewController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
        
        
    }
}


@end
