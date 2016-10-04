//
//  AccUserDef3+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AccUserDef3.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccUserDef3 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accuserdef_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *accuserdef3;

@end

@interface AccUserDef3 (CoreDataGeneratedAccessors)

- (void)addAccuserdef3Object:(SoftLabels *)value;
- (void)removeAccuserdef3Object:(SoftLabels *)value;
- (void)addAccuserdef3:(NSSet<SoftLabels *> *)values;
- (void)removeAccuserdef3:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END
