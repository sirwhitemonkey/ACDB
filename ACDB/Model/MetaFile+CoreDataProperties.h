//
//  MetaFile+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 18/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MetaFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetaFile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *rev;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) NSNumber *disposal;

@end

NS_ASSUME_NONNULL_END
