//
//  BuyingPower+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BuyingPower.h"

NS_ASSUME_NONNULL_BEGIN

@interface BuyingPower (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *buyingpower_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSNumber *priority;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<Contact *> *buyingpower;

@end

@interface BuyingPower (CoreDataGeneratedAccessors)

- (void)addBuyingpowerObject:(Contact *)value;
- (void)removeBuyingpowerObject:(Contact *)value;
- (void)addBuyingpower:(NSSet<Contact *> *)values;
- (void)removeBuyingpower:(NSSet<Contact *> *)values;

@end

NS_ASSUME_NONNULL_END
