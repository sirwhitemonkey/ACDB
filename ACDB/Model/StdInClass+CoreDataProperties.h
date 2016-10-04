//
//  StdInClass+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StdInClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface StdInClass (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *stdinclass_name;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<ACDBAccount *> *stdinclass;

@end

@interface StdInClass (CoreDataGeneratedAccessors)

- (void)addStdinclassObject:(ACDBAccount *)value;
- (void)removeStdinclassObject:(ACDBAccount *)value;
- (void)addStdinclass:(NSSet<ACDBAccount *> *)values;
- (void)removeStdinclass:(NSSet<ACDBAccount *> *)values;

@end

NS_ASSUME_NONNULL_END
