#import "CalendarDate.h"

@implementation CalendarDate {
    NSDate *_date;
    id _calendar;
}

- (NSDate *)date {
    return _date;
}

- (NSCalendar *)calendar {
    return _calendar;
}

- (id)init {
    self = [super init];
    if (self) {
        [self boot:[NSCalendar currentCalendar] date:[NSDate date]];
    }
    return self;
}

- (id)initWithDate:(NSDate *)date {
    self = [super init];
    if (self) {
        [self boot:[NSCalendar currentCalendar] date:date];
    }
    return self;
}

- (id)initWithCalendar:(NSCalendar *)calendar date:(NSDate *)date {
    self = [super init];
    if (self) {
        [self boot:calendar date:date];
    }
    return self;
}

- (void)boot:(NSCalendar *)calendar date:(NSDate *)date {
    _date = date;
    _calendar = calendar;
}

+ (CalendarDate *)today {
    CalendarDate *calendarDate = [[CalendarDate alloc] init];
    return [calendarDate calendarDateFromYearMonthDayComponents];
}

- (CalendarDate *)calendarDateFromYearMonthDayComponents {
    return [self calendarDateUsingUnitFlags:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay];
}

- (CalendarDate *)calendarDateUsingUnitFlags:(enum NSCalendarUnit)calendarUnitFlags {
    NSDateComponents *sourceComponents = [_calendar components:calendarUnitFlags fromDate:_date];
    NSDate *newDate = [_calendar dateFromComponents:sourceComponents];
    return [[CalendarDate alloc] initWithCalendar:_calendar date:newDate];
}

- (CalendarDate *)addComponents:(NSDateComponents *)additionComponents {
    NSDate *newDate = [_calendar dateByAddingComponents:additionComponents toDate:_date options:0];
    return [[CalendarDate alloc] initWithCalendar:_calendar date:newDate];
}

- (CalendarDate *)addDays:(NSInteger)v {
    return [self addMutatedComponents:^(NSDateComponents *c) {c.day = v;}];
}

- (CalendarDate *)addMonths:(NSInteger)v {
    return [self addMutatedComponents:^(NSDateComponents *c) {c.month = v;}];
}

- (CalendarDate *)addWeeks:(int)v {
    return [self addMutatedComponents:^(NSDateComponents *c) {c.weekOfYear = v;}];
}

- (CalendarDate *)addHours:(int)v {
    return [self addMutatedComponents:^(NSDateComponents *c) {c.hour = v;}];
}

- (CalendarDate *)addMinutes:(int)v {
    return [self addMutatedComponents:^(NSDateComponents *c) {c.minute = v;}];
}

- (CalendarDate *)addSeconds:(int)v {
    return [self addMutatedComponents:^(NSDateComponents *c) {c.second = v;}];
}

- (CalendarDate *)addMutatedComponents:(void (^)(NSDateComponents *))mutator {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    mutator(components);
    return [self addComponents:components];
}

- (BOOL)isBefore:(CalendarDate *)date {
    NSTimeInterval d = [self timeIntervalSinceDate:date];
    return d < 0;
}

- (BOOL)isAfter:(CalendarDate *)date {
    NSTimeInterval d = [self timeIntervalSinceDate:date];
    return d > 0;
}

- (BOOL)isOnOrBefore:(CalendarDate *)date {
    NSTimeInterval d = [self timeIntervalSinceDate:date];
    return d <= 0;
}

- (BOOL)isOnOrAfter:(CalendarDate *)date {
    NSTimeInterval d = [self timeIntervalSinceDate:date];
    return d >= 0;
}

- (NSTimeInterval)timeIntervalSinceDate:(CalendarDate *)date {
    return [self.date timeIntervalSinceDate:date.date];
}

@end