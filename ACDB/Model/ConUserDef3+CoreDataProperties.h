//
//  ConUserDef3+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ConUserDef3.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConUserDef3 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *conuserdef_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *conuserdef3;

@end

@interface ConUserDef3 (CoreDataGeneratedAccessors)

- (void)addConuserdef3Object:(SoftLabels *)value;
- (void)removeConuserdef3Object:(SoftLabels *)value;
- (void)addConuserdef3:(NSSet<SoftLabels *> *)values;
- (void)removeConuserdef3:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END
