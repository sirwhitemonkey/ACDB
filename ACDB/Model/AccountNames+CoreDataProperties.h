//
//  AccountNames+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AccountNames.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountNames (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountnames_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<SoftLabels *> *accountnames;

@end

@interface AccountNames (CoreDataGeneratedAccessors)

- (void)addAccountnamesObject:(SoftLabels *)value;
- (void)removeAccountnamesObject:(SoftLabels *)value;
- (void)addAccountnames:(NSSet<SoftLabels *> *)values;
- (void)removeAccountnames:(NSSet<SoftLabels *> *)values;

@end

NS_ASSUME_NONNULL_END
