//
//  PersistenceManager.h
//  ACDB
//
//  Created by Rommel on 13/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Relationship.h"
#import "StdInClass.h"
#import "SupportLevel.h"
#import "Country.h"
#import "ContactType.h"
#import "BuyingPower.h"
#import "AccountNames.h"
#import "AccUserDef1.h"
#import "AccUserDef2.h"
#import "AccUserDef3.h"
#import "AccUserDef4.h"
#import "ConUserDef1.h"
#import "ConUserDef2.h"
#import "ConUserDef3.h"
#import "ConUserDef4.h"
#import "SoftLabels.h"
#import "Contact.h"
#import "KeychainWrapper.h"
#import "MetaFile.h"
#import "NSManagedObject+DeepCopy.h"

#define local_NSManagedObjectContext @"local_NSManagedObjectContext"
#define local_NSManagedObjectModel @"local_NSManagedObjectModel"
#define local_NSPersistentStoreCoordinator @"local_NSPersistentStoreCoordinator"

#define dropBox_NSManagedObjectContext @"dropBox_NSManagedObjectContext"
#define dropBox_NSManagedObjectModel @"dropBox_NSManagedObjectModel"
#define dropBox_NSPersistentStoreCoordinator @"dropBox_NSPersistentStoreCoordinator"

#define cache_NSManagedObjectContext @"cached_NSManagedObjectContext"
#define cache_NSManagedObjectModel @"cached_NSManagedObjectModel"
#define cache_NSPersistentStoreCoordinator @"cache_NSPersistentStoreCoordinator"

@interface PersistenceManager : NSObject
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *dropBoxPath;
@property (nonatomic, strong) NSString *cachedPath;

+(PersistenceManager*)sharedInstance;

-(NSString*)newUUID;

- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectContext *)managedObjectContext:(ManagedObjectContextType)managedObjectContextType;
- (void)saveContext:(ManagedObjectContextType)managedObjectContextType;
- (void)saveContext;


-(void)createSampleData;
-(NSArray*)entityFetchObjects:(NSString*)source field_name:(NSString*)field_name ascending:(BOOL)ascending;
-(NSArray*)entityFetchObjects:(ManagedObjectContextType)managedObjectContextType source:(NSString*)source field_name:(NSString*)field_name ascending:(BOOL)ascending;

-(BOOL)entitySearchObject:(NSString*)source field_name:(NSString*)field_name param:(NSString*)param;
-(NSManagedObject*)entityObject:(NSString*)source uuid:(NSString*)uuid;
-(NSManagedObject*)entityObject:(ManagedObjectContextType)managedObjectContextType source:(NSString*)source uuid:(NSString*)uuid;
-(NSManagedObject*)entityObject:(NSString*)source field:(NSString*)field text:(NSString*)text;
-(NSManagedObject*)entityObject:(NSString*)source;
-(void)setMetaFile:(NSString*)revision;

- (void) setKeyChain:(NSString*)key value:(NSString*)value;
- (NSString*) getKeyChain:(NSString*)key;
- (void)removeFromKeyChain:(NSString*)key;
- (void) syncFile:(void (^)(void))callbackBlock;
- (void) destroyCache;
- (void) destroyCache:(NSString*)source;
- (void) resetCache;

@end
