//
//  ConUserDef2+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ConUserDef2.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConUserDef2 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *conuserdef_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *conuserdef2;

@end

@interface ConUserDef2 (CoreDataGeneratedAccessors)

- (void)addConuserdef2Object:(SoftLabels *)value;
- (void)removeConuserdef2Object:(SoftLabels *)value;
- (void)addConuserdef2:(NSSet<SoftLabels *> *)values;
- (void)removeConuserdef2:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END
