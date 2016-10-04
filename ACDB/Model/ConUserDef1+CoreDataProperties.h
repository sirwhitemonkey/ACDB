//
//  ConUserDef1+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ConUserDef1.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConUserDef1 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *conuserdef_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *conuserdef1;

@end

@interface ConUserDef1 (CoreDataGeneratedAccessors)

- (void)addConuserdef1Object:(SoftLabels *)value;
- (void)removeConuserdef1Object:(SoftLabels *)value;
- (void)addConuserdef1:(NSSet<SoftLabels *> *)values;
- (void)removeConuserdef1:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END