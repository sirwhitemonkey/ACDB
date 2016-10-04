//
//  SoftLabels+CoreDataProperties.h
//  ACDB
//
//  Created by Rommel Sumpo on 15/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SoftLabels.h"

NS_ASSUME_NONNULL_BEGIN

@interface SoftLabels (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *disposal;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *sync_modifier;
@property (nullable, nonatomic, retain) AccountNames *accountnames;
@property (nullable, nonatomic, retain) AccUserDef1 *accuserdef1;
@property (nullable, nonatomic, retain) AccUserDef2 *accuserdef2;
@property (nullable, nonatomic, retain) AccUserDef3 *accuserdef3;
@property (nullable, nonatomic, retain) AccUserDef4 *accuserdef4;
@property (nullable, nonatomic, retain) ConUserDef1 *conuserdef1;
@property (nullable, nonatomic, retain) ConUserDef2 *conuserdef2;
@property (nullable, nonatomic, retain) ConUserDef3 *conuserdef3;
@property (nullable, nonatomic, retain) ConUserDef4 *conuserdef4;

@end

NS_ASSUME_NONNULL_END
