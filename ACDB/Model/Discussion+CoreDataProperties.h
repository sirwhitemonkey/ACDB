//
//  Discussion+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Discussion.h"

NS_ASSUME_NONNULL_BEGIN

@interface Discussion (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSDate *discussion_bringupdate;
@property (nullable, nonatomic, retain) NSDate *discussion_contactdate;
@property (nullable, nonatomic, retain) NSString *discussion_contactheader;
@property (nullable, nonatomic, retain) NSString *discussion_notes;
@property (nullable, nonatomic, retain) NSNumber *discussion_status;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) ACDBAccount *discussion;
@property (nullable, nonatomic, retain) Contact *discussion_contactperson;
@property (nullable, nonatomic, retain) ContactType *discussion_contacttype;

@end

NS_ASSUME_NONNULL_END
