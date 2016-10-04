//
//  ACDBAccount.h
//  ACDB
//
//  Created by Rommel Sumpo on 12/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact, Country, Discussion, Relationship, StdInClass;

NS_ASSUME_NONNULL_BEGIN

@interface ACDBAccount : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "ACDBAccount+CoreDataProperties.h"
