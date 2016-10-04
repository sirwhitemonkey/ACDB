//
//  ACDBAccount+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ACDBAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDBAccount (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *account_accountnames_data;
@property (nullable, nonatomic, retain) NSString *account_accuserdef1_data;
@property (nullable, nonatomic, retain) NSString *account_accuserdef2_data;
@property (nullable, nonatomic, retain) NSString *account_accuserdef3_data;
@property (nullable, nonatomic, retain) NSString *account_accuserdef4_data;
@property (nullable, nonatomic, retain) NSString *account_contactmainphone;
@property (nullable, nonatomic, retain) NSString *account_employees;
@property (nullable, nonatomic, retain) NSString *account_name;
@property (nullable, nonatomic, retain) NSString *account_notes;
@property (nullable, nonatomic, retain) NSString *account_postaladdr1;
@property (nullable, nonatomic, retain) NSString *account_postaladdr2;
@property (nullable, nonatomic, retain) NSString *account_postaladdr3;
@property (nullable, nonatomic, retain) NSString *account_postaladdr4;
@property (nullable, nonatomic, retain) NSString *account_streetaddr1;
@property (nullable, nonatomic, retain) NSString *account_streetaddr2;
@property (nullable, nonatomic, retain) NSString *account_streetaddr3;
@property (nullable, nonatomic, retain) NSString *account_streetaddr4;
@property (nullable, nonatomic, retain) NSString *account_warning;
@property (nullable, nonatomic, retain) NSString *account_website;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) Contact *account_accounts;
@property (nullable, nonatomic, retain) Contact *account_billing;
@property (nullable, nonatomic, retain) NSSet<Contact *> *account_contacts;
@property (nullable, nonatomic, retain) Country *account_country;
@property (nullable, nonatomic, retain) NSSet<Discussion *> *account_discussions;
@property (nullable, nonatomic, retain) Country *account_postalcountry;
@property (nullable, nonatomic, retain) Contact *account_primarycontact;
@property (nullable, nonatomic, retain) Relationship *account_relationship;
@property (nullable, nonatomic, retain) Contact *account_secondarycontact;
@property (nullable, nonatomic, retain) StdInClass *account_stdinclass;

@end

@interface ACDBAccount (CoreDataGeneratedAccessors)

- (void)addAccount_contactsObject:(Contact *)value;
- (void)removeAccount_contactsObject:(Contact *)value;
- (void)addAccount_contacts:(NSSet<Contact *> *)values;
- (void)removeAccount_contacts:(NSSet<Contact *> *)values;

- (void)addAccount_discussionsObject:(Discussion *)value;
- (void)removeAccount_discussionsObject:(Discussion *)value;
- (void)addAccount_discussions:(NSSet<Discussion *> *)values;
- (void)removeAccount_discussions:(NSSet<Discussion *> *)values;

@end

NS_ASSUME_NONNULL_END
