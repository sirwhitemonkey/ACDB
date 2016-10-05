//
//  DatePicker.m
//  ACDB
//
//  Created by Rommel on 17/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import "DatePicker.h"
#import <EventKit/EventKit.h>

@interface DatePicker()

@property (nonatomic,strong) UIDatePicker* datePicker;
@property (nonatomic,strong) UIToolbar* toolbar;
@property (nonatomic,strong) UIView* inView;
@property (nonatomic,strong) NSString *value;
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) id source;
@property (nonatomic,strong)UIPopoverController *popoverController;
@property (nonatomic,strong) NSString *field;
@end

@implementation DatePicker
@synthesize delegate,value=_value,date=_date,source=_source;


-(void) presentDatePickerInView:(UIView*)view date:(NSString*)initDate value:(NSString*)value source:(id)source
 {
    _value=value;
    [self presentDatePickerInView:view date:initDate source:source];
}

-(void) presentDatePickerInView:(UIView*)view date:(NSString *)initDate source:(id)source
{
    _source=source;
    
    if ([_source isKindOfClass:[UITextField class]]) {
        _field = [((UITextField*)_source) accessibilityIdentifier];
    }
    NSDate *date = [NSDate date];
   
    if (![appDelegate isEmptyString:initDate]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:[self getDateFormat]];
        date = [dateFormat dateFromString:initDate];
    }
    
    _date = date;
    _inView = view;
    
    float pickerHeight = 216;
    float frameHeight = view.frame.size.height;
    CGRect pickerFrame = CGRectMake(0,frameHeight-216,0,0);
    UIDatePicker *myPicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    
    myPicker.datePickerMode = UIDatePickerModeDate;
    myPicker.date = date;
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, frameHeight-pickerHeight-44, 0, 50)];
    
    UIBarButtonItem *leftSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSeparator.width = 12;
    
    UIBarButtonItem *rightSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSeparator.width = 12;

    
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects: leftSeparator,
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)],
                           rightSeparator,
                           nil];
    [numberToolbar sizeToFit];
    myPicker.tag=DATEPICKER;
    numberToolbar.tag= DATETOOLBAR;
    myPicker.alpha=0;
    numberToolbar.alpha=0;
    myPicker.alpha=1;
    numberToolbar.alpha=1;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [view addSubview:numberToolbar];
        [view addSubview:myPicker];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.20];
        [UIView commitAnimations];
        
    } else {
        UIViewController* popoverContent = [[UIViewController alloc] init];
        UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 344)];
        popoverView.backgroundColor = [UIColor whiteColor];
        
        numberToolbar.frame=CGRectMake(0,0,320,50);
        myPicker.frame = CGRectMake(0, 44, 320, 300);
        
        [popoverView addSubview:numberToolbar];
        [popoverView addSubview:myPicker];
        popoverContent.view = popoverView;
        
        //resize the popover view shown
        //in the current view to the view's size
        popoverContent.preferredContentSize = CGSizeMake(320, 244);
        
        //create a popover controller
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        
        [_popoverController presentPopoverFromRect:((UITextField*)_source).bounds inView:((UITextField*)_source)
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];
    }
    myPicker.backgroundColor=[UIColor groupTableViewBackgroundColor];
    
    _datePicker=myPicker;
    _toolbar=numberToolbar;
    [_datePicker addTarget:self action:@selector(pickerChanged:)forControlEvents:UIControlEventValueChanged];
   [self.delegate initializedDatePicker];
    
 }


-(void) donePressed{
    [self dismissDatePicker];
    [self onDateSelectedDone];
    
    if (![appDelegate isEmptyString:_value] && [_field isEqualToString:@"contact_birthday"]) {
        EKEventStore *eventDB=[[EKEventStore alloc]init];
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self.delegate eventDatePickerStart];
                dispatch_async(dispatch_get_main_queue() ,^{
                    [self createEvent:eventDB];
                });
            }
        }];
    }
    
    
}

-(void)createEvent:(EKEventStore *)eventDB
{
    EKEvent *myEvent =[EKEvent eventWithEventStore:eventDB];
    myEvent.title=[NSString stringWithFormat:@"%@'s Birthday",_value];
    
    myEvent.allDay=true;
    
    NSCalendar *gCalendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components=[gCalendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:_datePicker.date];
    
    //NSInteger year=components.year;
    NSInteger month=components.month;
    NSInteger day=components.day;
    
    components=[gCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSInteger thisYear=components.year;
    components.year=thisYear;
    components.month=month;
    components.day=day;
    components.hour=0;
    components.minute=0;
    components.second=0;
    
    
    NSString *thisYearBirthDayString=[NSString stringWithFormat:@"%ld%ld%ld",(long)thisYear,(long)month,(long)day];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSDate *thisYearBirthDay=[dateFormat dateFromString:thisYearBirthDayString];
    
    myEvent.startDate=thisYearBirthDay;
    myEvent.endDate=thisYearBirthDay;
    
    
    NSString *yearString=[NSString stringWithFormat:@"%ld",(long)thisYear];
    NSString *monthString=[NSString stringWithFormat:@"%ld",(long)month];
    NSString *dayString=[NSString stringWithFormat:@"%ld",(long)day];
    
    if(monthString.length==1)
        monthString=[NSString stringWithFormat:@"0%@",monthString];
    
    if(dayString.length==1)
        dayString=[NSString stringWithFormat:@"0%@",dayString];
    
    
    NSString *thisYearBirthString=[NSString stringWithFormat:@"%@%@%@",yearString,monthString,dayString];
    
    thisYearBirthDay=[dateFormat dateFromString:thisYearBirthString];
    
    if([[NSDate date]timeIntervalSinceDate:thisYearBirthDay]>0){
        thisYear++;
        yearString=[NSString stringWithFormat:@"%ld",(long)thisYear];
        thisYearBirthDayString=[NSString stringWithFormat:@"%@%@%@",yearString,monthString,dayString];
        thisYearBirthDay=[dateFormat dateFromString:thisYearBirthDayString];
    }
    
    myEvent.startDate=thisYearBirthDay;
    myEvent.endDate=thisYearBirthDay;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *birthdate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate: myEvent.startDate];
    [components setHour:8];
    myEvent.startDate = [calendar dateFromComponents:birthdate];
    myEvent.endDate=myEvent.startDate;
    
    [myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];
    myEvent.alarms=[NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:myEvent.startDate]];

    NSError *err;
    [eventDB saveEvent:myEvent span:EKSpanThisEvent commit:YES error:&err];
    
    
    [self.delegate eventDatePickerEnd:(!err ? EVENT_CREATED: [err description])];
  
}

-(void) onDateSelectedDone{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:[self getDateFormat]];
    if ([_field isEqualToString:@"discussion_contactdate"]) {
        if ([appDelegate isEmptyString:_value]) {
            [self.delegate selectedDatePicker:_datePicker.date bringups:[_datePicker.date dateByAddingTimeInterval:(60*60*24*2)]];
        } else {
            [self.delegate selectedDatePicker:_datePicker.date];
        }
    } else  {
        [self.delegate selectedDatePicker:_datePicker.date];
    }
    [self.delegate completedDatePicker];
}

-(void)cancelPressed{
    [self dismissDatePicker];
    [self.delegate completedDatePicker];
}

-(void) pickerChanged:(id)sender{
    NSDateFormatter* dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:[self getDateFormat]];
    
    if ([_field isEqualToString:@"discussion_bringupdate"]) {
        if (![appDelegate isEmptyString:_value]) {
            NSDate *dateContact=[dateFormat dateFromString:_value];
            NSDate *date=_datePicker.date;
            if ([date compare:dateContact] == NSOrderedAscending) {
                _datePicker.date=_date;
                [self.delegate error:ERROR_BRINGUPDATE];
            }
        }
    } else if ([_field isEqualToString:@"discussion_contactdate"]) {
        if (![appDelegate isEmptyString:_value]) {
            NSDate *dateBringup=[dateFormat dateFromString:_value];
            NSDate *date=_datePicker.date;
            if ([dateBringup compare:date] == NSOrderedAscending) {
                _datePicker.date=_date;
                [self.delegate error:ERROR_CONTACTDATE];
            }
        }
    }

}

-(void)dismissDatePicker{
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    } else {
        
        while ([_inView viewWithTag:DATEPICKER]) {
            [[_inView viewWithTag:DATEPICKER]removeFromSuperview];
        }
        while ([_inView viewWithTag:DATETOOLBAR]) {
            [[_inView viewWithTag:DATETOOLBAR]removeFromSuperview];
        }
    }
}

- (NSString *) getDateFormat
{
    NSString *format;
    if ([_field isEqualToString:@"discussion_bringupdate"] ||
        [_field isEqualToString:@"discussion_contactdate"]) {
        format = @"EEE dd MMM yyyy";
        
    } else {
        format = @"dd/MM/yyyy";
    }
    return format;

}
@end
