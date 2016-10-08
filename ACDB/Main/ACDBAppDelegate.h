//
//  ACDBAppDelegate.h
//  ACDB
//
//  Created by Rommel on 8/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "ACDBAccount.h"
#import "Contact.h"
#import "Discussion.h"
#import "Reachability.h"
#import "SyncService.h"
#import "ProcessingViewController.h"


@import GoogleMaps;

@interface ACDBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign) PageController pageController;
@property (nonatomic,assign) PageRequest pageRequest;
@property (nonatomic,strong) NSManagedObject *pageObject;
@property (nonatomic,strong) ACDBAccount *acdbAccount;
@property (nonatomic,strong) UIViewController *controller;
@property BOOL hasInternetConnection;
@property BOOL hasDropboxLogout;

@property BOOL hasSyncStarted;



-(void)alert:(NSString*)message;
-(void)confirm:(NSString*)message result:(void (^)(bool))result;

-(BOOL)isEmptyString:(NSString*)input;
-(NSString*)capitalizeAllWords:(NSString*)data;
-(NSString*)trim:(NSString*)input;
-(BOOL) emailValid:(NSString*)email;
-(BOOL)urlValid:(NSString*)url;
- (void) syncFile:(BOOL)forceLoadFile runBackup:(BOOL) runBackup;
- (void) downloadFile;
-(void)showProcessingView:(NSString*)message;
-(void)stopProcessingView;
-(UIViewController*) getStoryboardView:(NSString*)name;
- (void) delay:(double) delayInSeconds callbackBlock:(void (^)(void))callbackBlock;
- (void) logout;


@end
