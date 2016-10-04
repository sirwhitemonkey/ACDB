//
//  NSManagedObject+DeepCopy.h
//  ACDB
//
//  Created by Rommel Sumpo on 17/08/16.
//  Copyright © 2016 RLBZR. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DeepCopy)
- (NSManagedObject *)clone;
- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)differentContext;
@end
