#import <Foundation/Foundation.h>

@interface CalendarDate : NSObject

- (id)initWithDate:(NSDate *)date;

- (id)initWithCalendar:(NSCalendar *)calendar date:(NSDate *)date;

- (CalendarDate *)addComponents:(NSDateComponents *)additionComponents;

+ (CalendarDate *)today;

- (CalendarDate *)calendarDateFromYearMonthDayComponents;

- (CalendarDate *)addDays:(NSInteger)v;

- (NSDate *)date;

- (NSCalendar *)calendar;

- (CalendarDate *)addMonths:(NSInteger)v;

- (BOOL)isBefore:(CalendarDate *)date;

- (BOOL)isOnOrBefore:(CalendarDate *)date;

- (BOOL)isOnOrAfter:(CalendarDate *)date;

- (BOOL)isAfter:(CalendarDate *)date;

- (CalendarDate *)addWeeks:(int)v;
@end