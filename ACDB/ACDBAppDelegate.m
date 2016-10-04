//
//  ACDBAppDelegate.m
//  ACDB
//
//  Created by Rommel on 8/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "ACDBAppDelegate.h"

@interface ACDBAppDelegate()<DBRestClientDelegate,SyncServiceDelegate>
@property (nonatomic,strong) Reachability *reachability;
@property (nonatomic,strong) DBRestClient *restClient;
@property (nonatomic,strong) SyncService *syncService;
@property (nonatomic,assign) ManagedContextFile managedContextFile;
@property (nonatomic,strong) ProcessingViewController *processingViewController;
@property (nonatomic,strong) NSNumber *hoursSsyncInterval;

@property BOOL hasDropboxConnection;

@end

@implementation ACDBAppDelegate
@synthesize pageController;
@synthesize pageRequest;
@synthesize pageObject;
@synthesize acdbAccount;
@synthesize hasInternetConnection;
@synthesize hasDropboxLogout;
@synthesize hasSyncStarted;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
    NSDictionary *infoList = [[NSBundle mainBundle]infoDictionary];
    NSDictionary *urlScheme=[[infoList valueForKey:@"CFBundleURLTypes"] objectAtIndex:0];
    NSArray *schemes = [NSArray arrayWithObjects:[NSString stringWithFormat:@"db-%@",DROPBOX_APP_KEY_VALUE],
                        @"comgooglemaps",
                        @"comgooglemaps-x-callback",
                        @"com.googleusercontent.apps.27458423899-bpk9j70rtod4cv087jcn7kao18jqq0ul",
                        @"nz.co.jasjca.ACDB",
                        nil];
    
    [urlScheme setValue:schemes forKey:@"CFBundleURLSchemes"];
    
    DebugLog(@"*****************urlScheme:%@",urlScheme);
    */
    
    [self  testInternetConnection];
    
    // TODO
    [persistenceManager setKeyChain:DROPBOX_APP_KEY value:DROPBOX_APP_KEY_VALUE];
    [persistenceManager setKeyChain:DROPBOX_APP_SECRET value:DROPBOX_APP_KEY_SECRET_VALUE];
    
    
    
    NSString *appKey = [persistenceManager getKeyChain:DROPBOX_APP_KEY];
    NSString *appSecret = [persistenceManager getKeyChain:DROPBOX_APP_SECRET];
    if (appKey && appSecret) {
        DBSession *dbSession = [[DBSession alloc]
                                initWithAppKey:appKey
                                appSecret:appSecret
                                root:kDBRootAppFolder]; // kDBRootAppFolder / kDBRootDropbox
        [DBSession setSharedSession:dbSession];
    }
    
    //default pagecontroller
    pageController = PageAccounts;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    _syncService = [SyncService sharedInstance];
    
    // Sync every 30 minutes
    [_syncService startTimerForSender:self withTimeInterval:60*30];
    
    if ([self isSessionLinked]) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
        
        MetaFile *metaFile = (MetaFile*)[persistenceManager entityObject:ENTITY_METAFILE];
        if (!metaFile.rev) {
            
            [self delay:1.0 callbackBlock:^{
                 [self downloadFile];
            }];
        }
 
    }

    // Google maps api key
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY_VALUE];
  
    if (![persistenceManager getKeyChain:@"LastDateSync"]) {
        [persistenceManager setKeyChain:@"LastDateSync" value:[self getSyncDate]];
    }
    
    [self updateSettingsBundle];
    
   return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [persistenceManager saveContext];
    if ([[DBSession sharedSession] isLinked]) {
        _hasDropboxConnection = YES;
        [self setHasDropboxLogout:NO];
    } else {
        _hasDropboxConnection = NO;
        [self setHasDropboxLogout:YES];
    }
    [self updateSettingsBundle];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self initialiseSettings];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [persistenceManager  saveContext];
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    return YES;
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([self isSessionLinked]) {
            DebugLog(@"App linked successfully!");
            _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            _restClient.delegate = self;
            [self downloadFile];
            
            _hasDropboxConnection = YES;
            [self setHasDropboxLogout:NO];
            [self updateSettingsBundle];
            
             return YES;

        } else {
            return NO;
        }
       
    }
    return NO;
}

#pragma Custom Functions
-(void)alert:(NSString*)message {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"ACDB"
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* closeAction = [UIAlertAction
                                actionWithTitle:@"Close"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:closeAction];
    
    UINavigationController *nav = (UINavigationController *)appDelegate.window.rootViewController;
    UIViewController *rootController = (UIViewController *)[nav.viewControllers objectAtIndex:0];
    [rootController presentViewController:alert animated:YES completion:nil];
}

-(void)confirm:(NSString*)message result:(void (^)(bool))result {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"ACDB"
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction
                                  actionWithTitle:@"Yes"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      result(YES);
                                  }];

    UIAlertAction *noAction = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    result(NO);
                                }];

    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    UINavigationController *nav = (UINavigationController *)appDelegate.window.rootViewController;
    UIViewController *rootController = (UIViewController *)[nav.viewControllers objectAtIndex:0];
    [rootController presentViewController:alert animated:YES completion:nil];
}

-(BOOL)isEmptyString:(NSString *)input
{
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (input ==nil || [input isEqualToString:@""] || [input isEqualToString:@" "])
        return YES;
    
    return NO;
    
}

-(NSString*)trim:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 
}

-(NSString*)capitalizeAllWords:(NSString *)data
{
    NSMutableString *result = [data mutableCopy];
    [result enumerateSubstringsInRange:NSMakeRange(0, [result length])
                               options:NSStringEnumerationByWords
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                [result replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                            }];
    return result;
}

-(BOOL) emailValid:(NSString *)email
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
}

- (BOOL) urlValid: (NSString *) url {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:url];
}

#pragma mark - Reachability
// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    _reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    
    // Internet is reachable
    _reachability.reachableBlock = ^(Reachability*reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            [appDelegate setHasInternetConnection:YES];
            if (![[DBSession sharedSession] isLinked] && _hasDropboxConnection) {
                _hasDropboxConnection = NO;
                [appDelegate alert:@"Please Enable the dropbox connection again in the Settings->ACDB->Dropbox connection"];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
      });
    };
    
    // Internet is not reachable
    _reachability.unreachableBlock = ^(Reachability*reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            [appDelegate setHasInternetConnection:NO];
        });
    };
    [_reachability startNotifier];
}

#pragma mark - Sync

- (void)startTimerAction:(id)userInfo {
    DebugLog(@"startTimerAction");
    if (!hasInternetConnection) {
        return;
    }

    if ([self isSessionLinked]) {
        NSDate* date = [self getSyncDate:[persistenceManager getKeyChain:@"LastDateSync"]];
        NSTimeInterval date_current_sync = [[NSDate date] timeIntervalSinceDate:date];
        
        int hours = date_current_sync / (60 * 60);
      
        if (_hoursSsyncInterval <= hours) {
            [self syncFile:NO];
            //back up the file
            [self delay:15 callbackBlock:^{
                _managedContextFile = ManagedContextFile_Backup;
                NSString *backupCopy = [NSString stringWithFormat:@"backup%@",ACDB_DB];
                [_restClient loadMetadata:[NSString stringWithFormat:@"/%@", backupCopy]];
            }];
            [persistenceManager setKeyChain:@"LastDateSync" value:[self getSyncDate]];
        }
    }
}


#pragma mark - DBRestclient (Delegate)

- (void) downloadFile {
    if (!hasInternetConnection) {
        [self alert:@"No internet connection. Download from dropbox failed"];
        [[DBSession sharedSession] unlinkAll];
        return;
    }
    
    if (![self isSessionLinked]) {
        return;
        
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self showProcessingView:@"Downloading the file from dropbox..."];
    
     _managedContextFile = ManagedContextFile_Download;
 
    [_restClient loadMetadata:[NSString stringWithFormat:@"/%@", ACDB_DB]];
    
}

- (void) syncFile:(BOOL)forceLoadFile {
    
    if (![self isSessionLinked]) {
        return;
        
    }
    
    if (!hasInternetConnection) {
        [self alert:@"No internet connection. Sync to dropbox failed"];
        return;
    }
    
    [self showProcessingView:@"Dropbox synchronisation started ..."];
    
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
 
    _managedContextFile = ManagedContextFile_Upload;
    if (!forceLoadFile) {
        [_restClient loadMetadata:[NSString stringWithFormat:@"/%@", ACDB_DB]];
    } else {
         [_restClient uploadFile:ACDB_DB toPath:@"/" withParentRev:nil fromPath:persistenceManager.localPath];
    }
    
 }


- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    DebugLog(@"File uploaded successfully to path: %@", metadata.path);
 
   
    if (_managedContextFile != ManagedContextFile_Backup) {
        [persistenceManager setMetaFile:metadata.rev];
     }
    
    if ([self hasDropboxLogout]) {
        [[DBSession sharedSession] unlinkAll];
        _hasDropboxConnection = NO;
        [self setHasDropboxLogout:YES];
        [persistenceManager destroyCache];
        
         UINavigationController *nav = (UINavigationController *)appDelegate.window.rootViewController;
        [nav popToRootViewControllerAnimated:YES];
        [self updateFileNotifier];
        [self delay:3.0 callbackBlock:^{
             [self stopProcessingView];
            [self alert:@"Dropbox session has been logout"];
           
        }];
        
    } else {
        
        [self delay:3.0 callbackBlock:^{
            [self stopProcessingView];
            [self alert:@"Dropbox synchronisation completed"];
            
        }];
        
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    DebugLog(@"File upload failed with error: %@", error);
    [self stopProcessingView];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
     DebugLog(@"File loadedMetadata successfully to path: %@", metadata.path);
    
    //[persistenceManager setMetaFile:metadata.rev];
    
    if (_managedContextFile == ManagedContextFile_Download) {
        [_restClient loadFile:[NSString stringWithFormat:@"/%@",ACDB_DB] intoPath:persistenceManager.localPath];
        
    } else if (_managedContextFile == ManagedContextFile_Upload) {
        [persistenceManager setMetaFile:metadata.rev];
        [_restClient uploadFile:ACDB_DB toPath:@"/" withParentRev:metadata.rev fromPath:persistenceManager.localPath];
        
    } else if (_managedContextFile == ManagedContextFile_Backup) {
        [self showProcessingView:@"Creating backup copy in dropbox.."];
        NSString *backupCopy = [NSString stringWithFormat:@"backup%@",ACDB_DB];
        [_restClient uploadFile:backupCopy toPath:@"/" withParentRev:metadata.rev fromPath:persistenceManager.localPath];
    }
    
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath
       contentType:(NSString*)contentType metadata:(DBMetadata*)metadata {
      DebugLog(@"File loadedFile successfully to path: %@", metadata.path);
    
    [self updateFileNotifier];
    
    [self delay:3.0 callbackBlock:^{
        [self alert:@"Local synchronisation completed"];
        [self stopProcessingView];
    }];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
     DebugLog(@"File loaded with error: %@", error);
    [self stopProcessingView];
    
    [persistenceManager resetCache];
    [persistenceManager destroyCache];
    [persistenceManager  createSampleData];
    [self syncFile:YES];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    DebugLog(@"Error loading metadata: %@", error);
    [self stopProcessingView];
    
    if (_managedContextFile == ManagedContextFile_Backup) {
        [self showProcessingView:@"Creating backup copy in dropbox.."];
        NSString *backupCopy = [NSString stringWithFormat:@"backup%@",ACDB_DB];
        [_restClient uploadFile:backupCopy toPath:@"/" withParentRev:nil fromPath:persistenceManager.localPath];

        
    } else {
     
        [persistenceManager resetCache];
        [persistenceManager destroyCache];
        [persistenceManager  createSampleData];
        [self syncFile:YES];
    }
}

#pragma mark - Methods

- (void) dropboxConnection {
    UIViewController *rootController = [self getRootController];
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:rootController];
    }
}

- (BOOL) isSessionLinked {
    if (![[DBSession sharedSession] isLinked]) {
        if (!_hasDropboxConnection) {
            [self alert:@"No dropbox session has been linked. \nEnable the Dropbox connection in Settings>ACDB->Dropbox connection"];

        } else {
            [self alert:@"No dropbox session has been linked."];
        }
        return NO;
    }
    _hasDropboxConnection = YES;
    
    return YES;

}

- (void) updateFileNotifier {
    [persistenceManager resetCache];
    
    if (acdbAccount) {
        acdbAccount = (ACDBAccount*)[persistenceManager entityObject:ENTITY_ACCOUNT uuid:acdbAccount.uuid];
    }
    
    [self delay:2.0 callbackBlock:^{
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"notificationLoadedFile"
         object:nil];
        
       
    }];
    
}


- (void) updateSettingsBundle {
    
    if (![persistenceManager getKeyChain:@"SyncHourInterval"]) {
        _hoursSsyncInterval = [NSNumber numberWithLong:1];
        [persistenceManager setKeyChain:@"SyncHourInterval" value:[_hoursSsyncInterval stringValue]];
    } else {
        _hoursSsyncInterval = [NSNumber numberWithLong:[[persistenceManager getKeyChain:@"SyncHourInterval"] longLongValue]];
    }

    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        DebugLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            id value = [prefSpecification objectForKey:@"DefaultValue"];
            
            if ([key isEqualToString:@"versionBuild"]) {
                value = [NSString stringWithFormat:@"%@ %@", version, build];
            } else if ([key isEqualToString:@"dropboxConnection"]) {
                value = [NSNumber numberWithBool:_hasDropboxConnection];
            } else if ([key isEqualToString:@"dropboxLogout"]) {
                value = [NSNumber numberWithBool:[self hasDropboxLogout]];
            } else if ([key isEqualToString:@"syncInterval"]) {
                value = _hoursSsyncInterval;
            }
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        }
    }
}

- (void) initialiseSettings {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
     _hasDropboxConnection = [settings boolForKey:@"dropboxConnection"];
    [self setHasDropboxLogout:[settings boolForKey:@"dropboxLogout"]];
    NSString *syncInterval = [settings objectForKey:@"syncInterval"];
    _hoursSsyncInterval = [NSNumber numberWithLong:[syncInterval longLongValue]];
    if ([_hoursSsyncInterval longLongValue] == 0) {
        _hoursSsyncInterval = [NSNumber numberWithLong:1];
    }
    [persistenceManager setKeyChain:@"SyncHourInterval" value:[_hoursSsyncInterval stringValue]];
  
    
    // Dropbox connection
    if (_hasDropboxConnection) {
        [self dropboxConnection];
    }
    
    // Dropbox logout
    if ([[DBSession sharedSession] isLinked]) {
        
        if ([self hasDropboxLogout]) {
            if (!hasInternetConnection) {
                [self alert:@"No internet connection. Dropbox session logout failed"];
            } else {
                [self syncFile:NO];

            }
        }
     }
}

#pragma mark - Processing view
-(void)showProcessingView:(NSString*)message
{
    
    UIViewController *rootController = [self getRootController];
    
    NSString *storyboardName = @"Main_iPhone";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        storyboardName = @"Main_iPad";
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName
                                                         bundle: nil];
    dispatch_async(dispatch_get_main_queue(), ^() {
        _processingViewController =[storyboard instantiateViewControllerWithIdentifier:@"ProcessingViewController"];
        
        _processingViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [_processingViewController initialise:message];
        
        [_processingViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [rootController presentViewController:_processingViewController animated:NO completion: ^ {
        }];
        
    });
}

- (void)stopProcessingView {
    if (_processingViewController) {
        [_processingViewController dismissViewControllerAnimated:YES completion:^{
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    }
}

- (void) delay:(double) delayInSeconds callbackBlock:(void (^)(void))callbackBlock {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        callbackBlock();
    });

}

-(NSString*) getSyncDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

- (NSDate*) getSyncDate:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (UIViewController*) getRootController
{
    UINavigationController *nav = (UINavigationController *)appDelegate.window.rootViewController;
    UIViewController *rootController = (UIViewController *)[nav.viewControllers objectAtIndex:0];
    return rootController;
}

@end
