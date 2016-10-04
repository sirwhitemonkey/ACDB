//
//  Country+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Country.h"

NS_ASSUME_NONNULL_BEGIN

@interface Country (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *country_mailingpostal1;
@property (nullable, nonatomic, retain) NSString *country_mailingpostal2;
@property (nullable, nonatomic, retain) NSString *country_name;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSSet<ACDBAccount *> *account_country;
@property (nullable, nonatomic, retain) NSSet<ACDBAccount *> *account_postalcountry;

@end

@interface Country (CoreDataGeneratedAccessors)

- (void)addAccount_countryObject:(ACDBAccount *)value;
- (void)removeAccount_countryObject:(ACDBAccount *)value;
- (void)addAccount_country:(NSSet<ACDBAccount *> *)values;
- (void)removeAccount_country:(NSSet<ACDBAccount *> *)values;

- (void)addAccount_postalcountryObject:(ACDBAccount *)value;
- (void)removeAccount_postalcountryObject:(ACDBAccount *)value;
- (void)addAccount_postalcountry:(NSSet<ACDBAccount *> *)values;
- (void)removeAccount_postalcountry:(NSSet<ACDBAccount *> *)values;

@end

NS_ASSUME_NONNULL_END
