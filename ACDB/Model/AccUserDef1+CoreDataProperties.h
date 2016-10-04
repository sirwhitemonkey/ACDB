//
//  AccUserDef1+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AccUserDef1.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccUserDef1 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accuserdef_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *accuserdef1;

@end

@interface AccUserDef1 (CoreDataGeneratedAccessors)

- (void)addAccuserdef1Object:(SoftLabels *)value;
- (void)removeAccuserdef1Object:(SoftLabels *)value;
- (void)addAccuserdef1:(NSSet<SoftLabels *> *)values;
- (void)removeAccuserdef1:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END
