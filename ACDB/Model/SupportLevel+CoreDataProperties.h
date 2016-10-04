//
//  SupportLevel+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SupportLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SupportLevel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSNumber *priority;
@property (nullable, nonatomic, retain) NSString *supportlevel_name;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<Contact *> *relationship;

@end

@interface SupportLevel (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(Contact *)value;
- (void)removeRelationshipObject:(Contact *)value;
- (void)addRelationship:(NSSet<Contact *> *)values;
- (void)removeRelationship:(NSSet<Contact *> *)values;

@end

NS_ASSUME_NONNULL_END
