//
//  ProcessingViewController.h
//  ACDB
//
//  Created by Rommel Sumpo on 13/09/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcessingViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) IBOutlet UILabel *label;

- (void)initialise:(NSString*)message;

@end
