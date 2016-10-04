//
//  DatePicker.h
//  ACDB
//
//  Created by Rommel on 17/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATEPICKER  999
#define DATETOOLBAR 998


@protocol DatePickerDelegate

@required
-(void)selectedDatePicker:(NSDate*)date;

@optional
-(void)selectedDatePicker:(NSDate*)date bringups:(NSDate*)bringupsDate;
-(void)initializedDatePicker;
-(void)completedDatePicker;
-(void)eventDatePickerStart;
-(void)eventDatePickerEnd:(NSString*)result;
-(void)error:(NSString*)error;
@end

@interface DatePicker : NSObject

@property(nonatomic,weak)id <DatePickerDelegate>delegate;
-(void) presentDatePickerInView:(UIView*)view date:(NSString*)initDate source:(id)source;
-(void) presentDatePickerInView:(UIView*)view date:(NSString*)initDate value:(NSString*)value  source: (id)source;

-(void)dismissDatePicker;

@end
