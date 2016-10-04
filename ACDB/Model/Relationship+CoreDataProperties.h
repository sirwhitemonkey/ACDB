//
//  Relationship+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Relationship.h"

NS_ASSUME_NONNULL_BEGIN

@interface Relationship (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSNumber *priority;
@property (nullable, nonatomic, retain) NSString *relationship_name;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<ACDBAccount *> *relationship;

@end

@interface Relationship (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(ACDBAccount *)value;
- (void)removeRelationshipObject:(ACDBAccount *)value;
- (void)addRelationship:(NSSet<ACDBAccount *> *)values;
- (void)removeRelationship:(NSSet<ACDBAccount *> *)values;

@end

NS_ASSUME_NONNULL_END
