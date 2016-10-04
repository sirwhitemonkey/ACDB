
//
//  PersistenceManager.m
//  ACDB
//
//  Created by Rommel on 13/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "PersistenceManager.h"

@interface PersistenceManager()
@property (nonatomic, strong) NSMutableDictionary *dictManagedObjectContext;

- (NSURL *)applicationDocumentsDirectory;
-(BOOL) isDisposal:(NSManagedObject*)managedObject;

@end

@implementation PersistenceManager
@synthesize dictManagedObjectContext = _dictManagedObjectContext;
@synthesize localPath, dropBoxPath;

+(PersistenceManager*)sharedInstance
{
    static dispatch_once_t oncePredicate;
    static PersistenceManager *_sharedInstance;
    dispatch_once(&oncePredicate,^{
        _sharedInstance=[[PersistenceManager alloc]init];
     });
    return _sharedInstance;
}

-(id)init {
    self = [super init];
    if (self) {
        _dictManagedObjectContext = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma public methods
-(NSString*)newUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    
    NSString *result = [((__bridge NSString *)string) stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    CFRelease(theUUID);
    CFRelease(string);
    
    return result;
}

- (void)saveContext
{
    [self saveContext:ManagedObjectContextType_Local];
}


- (void)saveContext:(ManagedObjectContextType)managedObjectContextType
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext:managedObjectContextType];
    if (managedObjectContext != nil) {
        
        if (![[DBSession sharedSession] isLinked]) {
            if ([managedObjectContext hasChanges]) {
                [managedObjectContext rollback];
            }
        } else {
            if (![appDelegate hasDropboxLogout]) {
                if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                    DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        }
    }
}


-(NSArray*)entityFetchObjects:(NSString*)source field_name:(NSString*)field_name ascending:(BOOL)ascending
{
    return [self entityFetchObjects:ManagedObjectContextType_Local source:source field_name:field_name ascending:YES];
}

-(NSArray*)entityFetchObjects:(ManagedObjectContextType)managedObjectContextType source:(NSString*)source field_name:(NSString*)field_name ascending:(BOOL)ascending {
    
    NSManagedObjectContext *context = [self managedObjectContext:managedObjectContextType];
    
    NSFetchRequest *fectchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:source
                                                         inManagedObjectContext:context];
    [fectchRequest setEntity: entityDescription];
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:field_name ascending:ascending selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *data = [context executeFetchRequest:fectchRequest error:&error];
    if (!data){
        DebugLog(@"Error : %@", [error localizedDescription]);
    }
    return data;

    
}

-(BOOL)entitySearchObject:(NSString *)source field_name:(NSString *)field_name param:(NSString *)param
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    param=[param stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 
    NSEntityDescription *entity = [NSEntityDescription entityForName:source inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.resultType = NSDictionaryResultType;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ =[cd] \"%@\"",field_name,param]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return YES;
    
    return NO;
    
}

-(NSManagedObject*)entityObject:(NSString *)source uuid:(NSString *)uuid
{
    return [self entityObject:ManagedObjectContextType_Local source:source uuid:uuid];
}

-(NSManagedObject*)entityObject:(ManagedObjectContextType)managedObjectContextType source:(NSString*)source uuid:(NSString*)uuid {
    
    NSManagedObjectContext *context = [self managedObjectContext:managedObjectContextType];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:source inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    //request.resultType = NSDictionaryResultType;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ =[cd] \"%@\"",@"uuid",uuid]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return [results objectAtIndex:0];
    
    return nil;

}


-(NSManagedObject*)entityObject:(NSString*)source field:(NSString*)field text:(NSString*)text
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:source inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    //request.resultType = NSDictionaryResultType;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ =[cd] \"%@\"",field,text]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return [results objectAtIndex:0];
    
    return nil;

}

-(NSManagedObject*) entityObject:(NSString *)source
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:source
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0 )
        return [fetchedObjects objectAtIndex:0];
    
    return nil;
}

-(void)setMetaFile:(NSString*)revision {
    NSManagedObject *managedObject = [self entityObject:ENTITY_METAFILE];
    if (!managedObject) {
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_METAFILE inManagedObjectContext:[self managedObjectContext]];
    }
    [managedObject setValue:revision forKey:@"rev"];
    [managedObject setValue:[self newUUID] forKey:@"uuid"];
    [self saveContext];
}

#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return url;
    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    return [self managedObjectContext:ManagedObjectContextType_Local];
}


- (NSManagedObjectContext *)managedObjectContext:(ManagedObjectContextType)managedObjectContextType
{
    NSManagedObjectContext *managedObjectContext = nil;
    if (managedObjectContextType == ManagedObjectContextType_Local) {
        managedObjectContext = [_dictManagedObjectContext objectForKey:local_NSManagedObjectContext];
        if (managedObjectContext) {
            return managedObjectContext;
        }
    } else if (managedObjectContextType == ManagedObjectContextType_DropBox) {
        managedObjectContext = [_dictManagedObjectContext objectForKey:dropBox_NSManagedObjectContext];
        if (managedObjectContext) {
            return managedObjectContext;
        }
    } else if (managedObjectContextType == ManagedObjectContextType_Cache) {
        managedObjectContext = [_dictManagedObjectContext objectForKey:cache_NSManagedObjectContext];
        if (managedObjectContext) {
            return managedObjectContext;
        }
    }

   
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator: managedObjectContextType];
    if (coordinator != nil) {
        NSString *key = nil;
         if (managedObjectContextType == ManagedObjectContextType_Local) {
             key = local_NSManagedObjectContext;
         } else if (managedObjectContextType == ManagedObjectContextType_DropBox) {
             key = dropBox_NSManagedObjectContext;
         } else if (managedObjectContextType == ManagedObjectContextType_Cache) {
             key = cache_NSManagedObjectContext;
         }
        
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_dictManagedObjectContext setObject:managedObjectContext forKey:key];
    }
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel:(ManagedObjectContextType)managedObjectContextType
{
    NSManagedObjectModel *managedObjectModel = nil;
    if (managedObjectContextType == ManagedObjectContextType_Local) {
        managedObjectModel = [_dictManagedObjectContext objectForKey:local_NSManagedObjectModel];
        if (managedObjectModel) {
            return managedObjectModel;
        }
    } else if (managedObjectContextType == ManagedObjectContextType_DropBox) {
        managedObjectModel = [_dictManagedObjectContext objectForKey:dropBox_NSManagedObjectModel];
        if (managedObjectModel) {
            return managedObjectModel;
        }
    
    } else if (managedObjectContextType == ManagedObjectContextType_Cache) {
        managedObjectModel = [_dictManagedObjectContext objectForKey:cache_NSManagedObjectModel];
        if (managedObjectModel) {
            return managedObjectModel;
        }
        
    }

    
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ACBD" withExtension:@"xcdatamodeld"];
    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSString *key = nil;
     if (managedObjectContextType == ManagedObjectContextType_Local) {
         key = local_NSManagedObjectModel;
     } else if (managedObjectContextType == ManagedObjectContextType_DropBox) {
         key = dropBox_NSManagedObjectModel;
     } else if (managedObjectContextType == ManagedObjectContextType_Cache) {
         key = cache_NSManagedObjectModel;
     }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    [_dictManagedObjectContext setObject:managedObjectModel forKey:key];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator:(ManagedObjectContextType)managedObjectContextType
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    NSString *key = nil;
    if (managedObjectContextType == ManagedObjectContextType_Local) {
        persistentStoreCoordinator = [_dictManagedObjectContext objectForKey:local_NSPersistentStoreCoordinator];
        if (persistentStoreCoordinator) {
            return persistentStoreCoordinator;
        }
    } else if (managedObjectContextType == ManagedObjectContextType_DropBox) {
        persistentStoreCoordinator = [_dictManagedObjectContext objectForKey:dropBox_NSPersistentStoreCoordinator];
        if (persistentStoreCoordinator) {
            return persistentStoreCoordinator;
        }
    }  else if (managedObjectContextType == ManagedObjectContextType_Cache) {
        persistentStoreCoordinator = [_dictManagedObjectContext objectForKey:cache_NSPersistentStoreCoordinator];
        if (persistentStoreCoordinator) {
            return persistentStoreCoordinator;
        }
    }

    
    NSURL *url = [self applicationDocumentsDirectory];
    NSString *source =  nil;
    
    if (managedObjectContextType == ManagedObjectContextType_Local) {
        source = ACDB_DB;
        
    } else if (managedObjectContextType == ManagedObjectContextType_DropBox) {
        source = [NSString stringWithFormat:@"dropBox/%@",ACDB_DB];
    
    } else if (managedObjectContextType == ManagedObjectContextType_Cache) {
        source = [NSString stringWithFormat:@"cache/%@",ACDB_DB];
    }
    
    [[NSFileManager defaultManager]
     createDirectoryAtPath: [[url URLByAppendingPathComponent:@"/dropBox"] path]
     withIntermediateDirectories:YES
     attributes:nil
     error:nil];

    [[NSFileManager defaultManager]
     createDirectoryAtPath: [[url URLByAppendingPathComponent:@"/cache"] path]
     withIntermediateDirectories:YES
     attributes:nil
     error:nil];

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:source];
    self.localPath = [[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",ACDB_DB]] path];
    self.dropBoxPath = [[url URLByAppendingPathComponent:[NSString stringWithFormat:@"dropBox/%@",ACDB_DB]] path];
     self.cachedPath = [[url URLByAppendingPathComponent:[NSString stringWithFormat:@"cache/%@",ACDB_DB]] path];
  
    DebugLog(@"localPath:%@", self.localPath);
    DebugLog(@"dropBoxPath:%@", self.dropBoxPath);
    DebugLog(@"cachedPath:%@", self.cachedPath);
    
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             @{@"journal_mode": @"DELETE"},NSSQLitePragmasOption,nil];
    
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel:managedObjectContextType]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
        @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    key = nil;
    if (managedObjectContextType == ManagedObjectContextType_Local) {
        key = local_NSPersistentStoreCoordinator;
    } else if (managedObjectContextType == ManagedObjectContextType_DropBox) {
        key = dropBox_NSPersistentStoreCoordinator;
    } else if (managedObjectContextType == ManagedObjectContextType_Cache) {
        key = cache_NSPersistentStoreCoordinator;
    }
    [_dictManagedObjectContext setValue:persistentStoreCoordinator forKey:key];
    
    return persistentStoreCoordinator;
}



#pragma Defined sample data

-(BOOL) isSampleDataLoaded:(NSString*)reference
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:reference
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] ==0 )
        return NO;
    
    return YES;
}


-(void) createSampleData
{
    NSManagedObjectContext *managedObjectContext = [ self managedObjectContext];
    
    //Relationship
    NSUInteger priority=0;
    if (![self isSampleDataLoaded:ENTITY_RELATIONSHIP]) {
        for(NSString *data in SAMPLE_RELATIONSHIP_DATA) {
            Relationship *relationship = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_RELATIONSHIP inManagedObjectContext:managedObjectContext];
            relationship.relationship_name=data;
            relationship.uuid=[self newUUID];
            relationship.sync_modifier = [self newUUID];
            relationship.priority=[NSNumber numberWithInteger:priority];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"Relationship sample data saved!");
            } else {
                DebugLog(@"Relationship error: %@", [error userInfo]);
            }
            priority++;
        }
    }
    
    //StdInClass
    if (![self isSampleDataLoaded:ENTITY_STDINCLASS]) {
        for(NSString *data in SAMPLE_STDINCLASS_DATA) {
            StdInClass *stdinclass = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_STDINCLASS inManagedObjectContext:managedObjectContext];
            stdinclass.stdinclass_name=data;
            stdinclass.uuid=[self newUUID];
            stdinclass.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"StdInClass sample data saved!");
            } else {
                DebugLog(@"StdInClass error: %@", [error userInfo]);
            }
        }
    }
    
    //SupportLevel
    priority=0;
    if (![self isSampleDataLoaded:ENTITY_SUPPORTLEVEL]) {
        for(NSString *data in SAMPLE_SUPPORTLEVEL_DATA) {
            SupportLevel *supportlevel = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_SUPPORTLEVEL inManagedObjectContext:managedObjectContext];
            supportlevel.supportlevel_name=data;
            supportlevel.uuid=[self newUUID];
            supportlevel.sync_modifier = [self newUUID];
            supportlevel.priority=[NSNumber numberWithInteger:priority];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"SupportLevel sample data saved!");
            } else {
                DebugLog(@"SupportLevel error: %@", [error userInfo]);
            }
            priority++;
        }
    }
    
    //BuyingPower
    priority=0;
    if (![self isSampleDataLoaded:ENTITY_BUYINGPOWER]) {
        for(NSString *data in SAMPLE_BUYINGPOWER_DATA) {
            BuyingPower *buyingpower = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_BUYINGPOWER inManagedObjectContext:managedObjectContext];
            buyingpower.buyingpower_name=data;
            buyingpower.uuid=[self newUUID];
            buyingpower.priority=[NSNumber numberWithInteger:priority];
            buyingpower.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"BuyingPower sample data saved!");
            } else {
                DebugLog(@"BuyingPower error: %@", [error userInfo]);
            }
            priority++;
        }
    }
    
    //ContactType
    if (![self isSampleDataLoaded:ENTITY_CONTACTTYPE]) {
        for(NSString *data in SAMPLE_CONTACTTYPE_DATA) {
            ContactType *contacttype = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_CONTACTTYPE inManagedObjectContext:managedObjectContext];
            contacttype.contacttype_name=data;
            contacttype.uuid=[self newUUID];
            contacttype.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"ContactType sample data saved!");
            } else {
                DebugLog(@"ContactType error: %@", [error userInfo]);
            }
        }
    }
    
    //Country
    if (![self isSampleDataLoaded:ENTITY_COUNTRY]) {
        for(NSString *data in SAMPLE_COUNTRY_DATA) {
            Country *country = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_COUNTRY inManagedObjectContext:managedObjectContext];
            country.country_name=[data uppercaseString];
            country.uuid=[self newUUID];
            country.sync_modifier = [self newUUID];
            //raw data
            if ([country.country_name isEqualToString:@"NEW ZEALAND"]) {
                country.country_mailingpostal1=@"Suburb";
                country.country_mailingpostal2=@"City | Postcode";
                
            } else if([country.country_name isEqualToString:@"AUSTRALIA"]) {
                country.country_mailingpostal1=@"City";
                country.country_mailingpostal2=@"State | Postcode";
                
            }else if([country.country_name isEqualToString:@"UNITED STATES"]) {
                country.country_mailingpostal1=@"City";
                country.country_mailingpostal2=@"State | Zip";
                
            }else if([country.country_name isEqualToString:@"UNITED KINGDOM"]) {
                country.country_mailingpostal1=@"City";
                country.country_mailingpostal2=@"County | Postcode";
            }
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"Country sample data saved!");
            } else {
                DebugLog(@"Country error: %@", [error userInfo]);
            }
        }
    }
    
    SoftLabels *softlabels;
    if (![self isSampleDataLoaded:ENTITY_SOFTLABELS]) {
        softlabels = [NSEntityDescription insertNewObjectForEntityForName:
                                  ENTITY_SOFTLABELS inManagedObjectContext:managedObjectContext];
        softlabels.uuid=[self newUUID];
        softlabels.sync_modifier = [self newUUID];
    }
    
    //Account Names
    if (![self isSampleDataLoaded:ENTITY_ACCOUNTNAMES]) {
        for(NSString *data in SAMPLE_ACCOUNTNAMES_DATA) {
            AccountNames *accountnames = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_ACCOUNTNAMES inManagedObjectContext:managedObjectContext];
            accountnames.accountnames_name=data;
            accountnames.uuid=[self newUUID];
            accountnames.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"AccountNames sample data saved!");
                if ([data isEqualToString:@"Legal Name"]) {
                    softlabels.accountnames=accountnames;
                    [accountnames addAccountnamesObject:softlabels];
                }
            } else {
                DebugLog(@"AccountNames error: %@", [error userInfo]);
            }
        }
    }
    //AccUserDef1
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@1", ENTITY_ACCUSERDEF]]) {
        for(NSString *data in SAMPLE_ACCUSERDEF1_DATA) {
            AccUserDef1 *accusedef1 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@1", ENTITY_ACCUSERDEF] inManagedObjectContext:managedObjectContext];
            accusedef1.accuserdef_name=data;
            accusedef1.uuid=[self newUUID];
            accusedef1.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"AccUserDef1 sample data saved!");
                softlabels.accuserdef1=accusedef1;
                [accusedef1 addAccuserdef1Object:softlabels];
            } else {
                DebugLog(@"AccUserDef1 error: %@", [error userInfo]);
            }
        }
    }

    //AccUserDef2
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@2", ENTITY_ACCUSERDEF]]) {
        for(NSString *data in SAMPLE_ACCUSERDEF2_DATA) {
            AccUserDef2 *accusedef2 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@2", ENTITY_ACCUSERDEF] inManagedObjectContext:managedObjectContext];
            accusedef2.accuserdef_name=data;
            accusedef2.uuid=[self newUUID];
            accusedef2.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"AccUserDef2 sample data saved!");
                softlabels.accuserdef2=accusedef2;
                [accusedef2 addAccuserdef2Object:softlabels];
            } else {
                DebugLog(@"AccUserDef2 error: %@", [error userInfo]);
            }
        }
    }

    //AccUserDef3
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@3", ENTITY_ACCUSERDEF]]) {
        for(NSString *data in SAMPLE_ACCUSERDEF3_DATA) {
            AccUserDef3 *accusedef3 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@3", ENTITY_ACCUSERDEF] inManagedObjectContext:managedObjectContext];
            accusedef3.accuserdef_name=data;
            accusedef3.uuid=[self newUUID];
            accusedef3.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"AccUserDef3 sample data saved!");
                softlabels.accuserdef3=accusedef3;
                [accusedef3 addAccuserdef3Object:softlabels];
            } else {
                DebugLog(@"AccUserDef3 error: %@", [error userInfo]);
            }
        }
    }
    //AccUserDef4
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@4", ENTITY_ACCUSERDEF]]) {
        for(NSString *data in SAMPLE_ACCUSERDEF4_DATA) {
            AccUserDef4 *accusedef4 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@4", ENTITY_ACCUSERDEF] inManagedObjectContext:managedObjectContext];
            accusedef4.accuserdef_name=data;
            accusedef4.uuid=[self newUUID];
            accusedef4.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"AccUserDef4 sample data saved!");
                softlabels.accuserdef4=accusedef4;
                [accusedef4 addAccuserdef4Object:softlabels];
            } else {
                DebugLog(@"AccUserDef4 error: %@", [error userInfo]);
            }
        }
    }

    //ConUserDef1
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@1", ENTITY_CONUSERDEF]]) {
        for(NSString *data in SAMPLE_CONUSERDEF1_DATA) {
            ConUserDef1 *conuserdef1 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@1", ENTITY_CONUSERDEF] inManagedObjectContext:managedObjectContext];
            conuserdef1.conuserdef_name=data;
            conuserdef1.uuid=[self newUUID];
            conuserdef1.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"ConUserDef1 sample data saved!");
                softlabels.conuserdef1=conuserdef1;
                [conuserdef1 addConuserdef1Object:softlabels];
            } else {
                DebugLog(@"ConUserDef1 error: %@", [error userInfo]);
            }
        }
    }

    //ConUserDef2
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@2", ENTITY_CONUSERDEF]]) {
        for(NSString *data in SAMPLE_CONUSERDEF2_DATA) {
            ConUserDef2 *conuserdef2 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@2", ENTITY_CONUSERDEF] inManagedObjectContext:managedObjectContext];
            conuserdef2.conuserdef_name=data;
            conuserdef2.uuid=[self newUUID];
            conuserdef2.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"ConUserDef2 sample data saved!");
                softlabels.conuserdef2=conuserdef2;
                [conuserdef2 addConuserdef2Object:softlabels];
            } else {
                DebugLog(@"ConUserDef2 error: %@", [error userInfo]);
            }
        }
    }

    //ConUserDef3
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@3", ENTITY_CONUSERDEF]]) {
        for(NSString *data in SAMPLE_CONUSERDEF3_DATA) {
            ConUserDef3 *conuserdef3 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@3", ENTITY_CONUSERDEF] inManagedObjectContext:managedObjectContext];
            conuserdef3.conuserdef_name=data;
            conuserdef3.uuid=[self newUUID];
            conuserdef3.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"ConUserDef3 sample data saved!");
                softlabels.conuserdef3=conuserdef3;
                [conuserdef3 addConuserdef3Object:softlabels];
            } else {
                DebugLog(@"ConUserDef3 error: %@", [error userInfo]);
            }
        }
    }

    //ConUserDef4
    if (![self isSampleDataLoaded:[NSString stringWithFormat:@"%@4", ENTITY_CONUSERDEF]]) {
        for(NSString *data in SAMPLE_CONUSERDEF4_DATA) {
            ConUserDef4 *conuserdef4 = [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithFormat:@"%@4", ENTITY_CONUSERDEF] inManagedObjectContext:managedObjectContext];
            conuserdef4.conuserdef_name=data;
            conuserdef4.uuid=[self newUUID];
            conuserdef4.sync_modifier = [self newUUID];
            NSError *error = nil;
            if ([managedObjectContext save:&error]) {
                DebugLog(@"ConUserDef4 sample data saved!");
                softlabels.conuserdef4=conuserdef4;
                [conuserdef4 addConuserdef4Object:softlabels];
            } else {
                DebugLog(@"ConUserDef4 error: %@", [error userInfo]);
            }
        }
    }
    
    DebugLog(@"Done createSampleData");

     
}

-(BOOL)isEmptyString:(NSString *)input
{
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (input ==nil || [input isEqualToString:@""] || [input isEqualToString:@" "])
        return YES;
    
    return NO;
    
}

#pragma mark - Keychain
- (void) setKeyChain:(NSString *)key value:(NSString *)value {
    [KeychainWrapper createKeychainValue:value forIdentifier:key];
}

- (NSString*) getKeyChain:(NSString *)key {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:key];
}

- (void)removeFromKeyChain:(NSString *)key {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:key];
}

#pragma mark - Sync
- (void)syncFile:(void (^)(void))callbackBlock {
    
    if (![appDelegate hasInternetConnection]) {
        callbackBlock();
        return;
    }
    DebugLog(@"syncFile");
    [self destroyCache];
    
    
    [self syncEntity:ENTITY_ACCOUNT];
    [self syncEntity:ENTITY_ACCOUNTNAMES];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,1]];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,2]];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,3]];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,4]];
    [self syncEntity:ENTITY_BUYINGPOWER];
    [self syncEntity:ENTITY_CONTACT];
    [self syncEntity:ENTITY_CONTACTTYPE];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,1]];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,2]];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,3]];
    [self syncEntity:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,4]];
    [self syncEntity:ENTITY_COUNTRY];
    [self syncEntity:ENTITY_DISCUSSION];
    [self syncEntity:ENTITY_RELATIONSHIP];
    [self syncEntity:ENTITY_SOFTLABELS];
    [self syncEntity:ENTITY_STDINCLASS];
    [self syncEntity:ENTITY_SUPPORTLEVEL];
    [self syncEntity:ENTITY_METAFILE];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.localPath error:&error];
    if (!error) {
        [[NSFileManager defaultManager] copyItemAtPath:self.cachedPath toPath: self.localPath error:&error];
        if (error) {
            DebugLog(@"Error:%@",error);
        }
        [appDelegate syncFile:NO];
        [_dictManagedObjectContext removeAllObjects];
    }
    
    callbackBlock();
    
}

- (void) syncEntity:(NSString*)entity {
    
    NSString *uuid;
    NSString *localSyncModifier;
    NSString *dropBoxSyncModifier;
    
    NSManagedObject *localManagedObject;
    NSManagedObject *dropBoxManagedObject;
    
    // Local
    NSArray *localResults = [self entityFetchObjects:entity field_name:@"uuid" ascending:YES];
    if (localResults.count > 0 ) {
        
        for (localManagedObject in localResults) {
             uuid = [localManagedObject valueForKey:@"uuid"];
            localSyncModifier = [localManagedObject valueForKey:@"sync_modifier"];
            
            dropBoxManagedObject = [self entityObject:ManagedObjectContextType_DropBox source:entity uuid:uuid];
            
            // Dropbox not available
            if (!dropBoxManagedObject) {
                if (![self isDisposal:localManagedObject]) {
                    [localManagedObject cloneInContext:[self managedObjectContext:ManagedObjectContextType_Cache]];
                    [self saveContext:ManagedObjectContextType_Cache];
                }
            }
            
            // Dropbox is available
            else {
            
                // If not disposed
                if (!([self isDisposal:dropBoxManagedObject] || [self isDisposal:localManagedObject])) {
                    
                    dropBoxSyncModifier = [dropBoxManagedObject valueForKey:@"sync_modifier"];
                   
                    // If  changes on sync modifier, Copy all changes from dropbox to local
                    if (![localSyncModifier isEqualToString:dropBoxSyncModifier]) {
                   
                        [dropBoxManagedObject cloneInContext:[self managedObjectContext:ManagedObjectContextType_Cache]];
                    
                    } else {
                        [localManagedObject cloneInContext:[self managedObjectContext:ManagedObjectContextType_Cache]];
                    }
                    [self saveContext:ManagedObjectContextType_Cache];
                }
                [[self managedObjectContext:ManagedObjectContextType_DropBox] deleteObject:dropBoxManagedObject];
                [self saveContext:ManagedObjectContextType_DropBox];
            }
            
        }
    }
   
    
    //DropBox
    NSArray *dropBoxResults = [self entityFetchObjects:NO source:entity field_name:@"uuid" ascending:YES];
    if (dropBoxResults.count > 0 ) {
        for (dropBoxManagedObject in dropBoxResults) {
            uuid = [dropBoxManagedObject valueForKey:@"uuid"];
            dropBoxSyncModifier = [dropBoxManagedObject valueForKey:@"sync_modifier"];
            
            localManagedObject = [self entityObject:entity uuid:uuid];
          
            // Local not available
            if (!localManagedObject) {
                
                if (![self isDisposal:dropBoxManagedObject]) {
                    [dropBoxManagedObject cloneInContext:[self managedObjectContext:ManagedObjectContextType_Cache]];
                    [self saveContext:ManagedObjectContextType_Cache];
                }
            }
        }
    }
    
    
 }


-(BOOL) isDisposal:(NSManagedObject*)managedObject {
    id value = [managedObject valueForKey:@"disposal"];
    return [value boolValue];
}

- (void) destroyCache:(NSString*)source {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext:ManagedObjectContextType_Local];
    NSArray *results = [self entityFetchObjects:ManagedObjectContextType_Local source:source field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:YES];
     [managedObjectContext save:nil];
}

- (void) destroyCache {
    
    ManagedObjectContextType managedObjectContextType = ManagedObjectContextType_Local;
    BOOL disposal = NO;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext:managedObjectContextType];
    NSArray *results = [self entityFetchObjects:managedObjectContextType source:ENTITY_DISCUSSION field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_COUNTRY field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_BUYINGPOWER field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];
    
    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_SUPPORTLEVEL field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_CONTACTTYPE field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_CONTACT field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_STDINCLASS field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_ACCOUNT field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_RELATIONSHIP field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_ACCOUNTNAMES field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_SOFTLABELS field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:ENTITY_METAFILE field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,1] field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,2]  field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,3]  field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_ACCUSERDEF,4]  field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];

    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,1] field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];
    
    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,2]  field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];
    
    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,3]  field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];
    
    results = [self entityFetchObjects:managedObjectContextType source:[NSString stringWithFormat:@"%@%d",ENTITY_CONUSERDEF,4]  field_name:@"uuid" ascending:YES];
    [self delete:managedObjectContext  managedObjects:results disposal:disposal];
    
    [managedObjectContext save:nil];

}

- (void) delete:(NSManagedObjectContext*)managedObjectContext managedObjects:(NSArray*)managedObjects disposal:(BOOL) disposal{
    if (managedObjects.count > 0) {
        for (NSManagedObject *managedObject in managedObjects) {
            if (disposal) {
                NSNumber *currentDisposal = [managedObject valueForKey:@"disposal"];
                if ([currentDisposal boolValue]) {
                    [managedObjectContext deleteObject:managedObject];
                }
            } else {
                [managedObjectContext deleteObject:managedObject];
            }
            
        }
    }
}

- (void) resetCache {
    [_dictManagedObjectContext removeAllObjects];
}
@end
