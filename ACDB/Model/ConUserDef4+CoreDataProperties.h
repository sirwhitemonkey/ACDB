//
//  ConUserDef4+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ConUserDef4.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConUserDef4 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *conuserdef_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *conuserdef4;

@end

@interface ConUserDef4 (CoreDataGeneratedAccessors)

- (void)addConuserdef4Object:(SoftLabels *)value;
- (void)removeConuserdef4Object:(SoftLabels *)value;
- (void)addConuserdef4:(NSSet<SoftLabels *> *)values;
- (void)removeConuserdef4:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END
