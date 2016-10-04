//
//  AccUserDef2+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AccUserDef2.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccUserDef2 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accuserdef_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *accuserdef2;

@end

@interface AccUserDef2 (CoreDataGeneratedAccessors)

- (void)addAccuserdef2Object:(SoftLabels *)value;
- (void)removeAccuserdef2Object:(SoftLabels *)value;
- (void)addAccuserdef2:(NSSet<SoftLabels *> *)values;
- (void)removeAccuserdef2:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END
