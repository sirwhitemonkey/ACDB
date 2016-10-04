//
//  Contact+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *contact_birthday;
@property (nullable, nonatomic, retain) NSString *contact_chn_b_days;
@property (nullable, nonatomic, retain) NSString *contact_conuserdef1_data;
@property (nullable, nonatomic, retain) NSString *contact_conuserdef2_data;
@property (nullable, nonatomic, retain) NSString *contact_conuserdef3_data;
@property (nullable, nonatomic, retain) NSString *contact_conuserdef4_data;
@property (nullable, nonatomic, retain) NSNumber *contact_currentemployee;
@property (nullable, nonatomic, retain) NSString *contact_email1;
@property (nullable, nonatomic, retain) NSString *contact_email2;
@property (nullable, nonatomic, retain) NSString *contact_firstname;
@property (nullable, nonatomic, retain) NSString *contact_hobbies;
@property (nullable, nonatomic, retain) NSString *contact_homephone;
@property (nullable, nonatomic, retain) NSString *contact_jobtitle;
@property (nullable, nonatomic, retain) NSString *contact_lastname;
@property (nullable, nonatomic, retain) NSString *contact_mobilephone;
@property (nullable, nonatomic, retain) NSString *contact_name;
@property (nullable, nonatomic, retain) NSString *contact_nickname;
@property (nullable, nonatomic, retain) NSString *contact_notes;
@property (nullable, nonatomic, retain) NSString *contact_partner;
@property (nullable, nonatomic, retain) NSString *contact_salutation;
@property (nullable, nonatomic, retain) NSString *contact_workphone1;
@property (nullable, nonatomic, retain) NSString *contact_workphone2;
@property (nullable, nonatomic, retain) NSString *contact_workphoneextension1;
@property (nullable, nonatomic, retain) NSString *contact_workphoneextension2;
@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) ACDBAccount *contact_accountcontacts;
@property (nullable, nonatomic, retain) ACDBAccount *contact_accounts;
@property (nullable, nonatomic, retain) ACDBAccount *contact_billing;
@property (nullable, nonatomic, retain) BuyingPower *contact_buyingpower;
@property (nullable, nonatomic, retain) NSSet<Discussion *> *contact_discussioncontactperson;
@property (nullable, nonatomic, retain) ACDBAccount *contact_primary;
@property (nullable, nonatomic, retain) ACDBAccount *contact_secondary;
@property (nullable, nonatomic, retain) SupportLevel *contact_supportlevel;

@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addContact_discussioncontactpersonObject:(Discussion *)value;
- (void)removeContact_discussioncontactpersonObject:(Discussion *)value;
- (void)addContact_discussioncontactperson:(NSSet<Discussion *> *)values;
- (void)removeContact_discussioncontactperson:(NSSet<Discussion *> *)values;

@end

NS_ASSUME_NONNULL_END
