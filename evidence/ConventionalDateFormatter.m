#import "ConventionalDateFormatter.h"
#import "CalendarDate.h"

static NSTimeInterval NSTimeIntervalDay = 60 * 60 * 24;

@implementation ConventionalDateFormatter {
    NSDateFormatter *_dayFormatter;
	NSDateFormatter *_dateFormatter;
	NSDateFormatter *_timeFormatter;
}

- (id)init {
    self = [super init];
    if (self) {

        _dayFormatter = [[NSDateFormatter alloc] init];
        _dayFormatter.dateFormat = @"EEEE";

        _dateFormatter = [[NSDateFormatter alloc] init];
       	_dateFormatter.dateStyle = NSDateFormatterLongStyle;
       	_dateFormatter.timeStyle = NSDateFormatterNoStyle;

       	_timeFormatter = [[NSDateFormatter alloc] init];
       	_timeFormatter.timeStyle = NSDateFormatterShortStyle;
    }

    return self;
}

- (NSString *)timeStringFromDate:(NSDate *)date {
    return [_timeFormatter stringFromDate:date];
}

- (NSObject *)dateStringFromDate:(NSDate *)date {
    return [_dateFormatter stringFromDate:date];
}

- (NSObject *)dayStringFromDate:(NSDate *)date {
    return [_dayFormatter stringFromDate:date];
}

- (NSObject *)longStringFromDate:(NSDate *)date {
    return [NSString stringWithFormat:@"%@, %@ %@", [self timeStringFromDate:date], [self dayStringFromDate:date], [self dateStringFromDate:date]];
}

- (NSString *)dayDescriptionStringFromDate:(NSDate *)date releativeToToday:(NSDate*)today {
    NSTimeInterval d = [today timeIntervalSinceDate:date];
	int dayDiff = (int) d / NSTimeIntervalDay;
	NSString *dayDescription;
	switch (dayDiff) {
		case 0:
			dayDescription = @"Today";
			break;
		case 1:
			dayDescription = @"Yesterday";
			break;
		default:
			dayDescription = [NSString stringWithFormat:@"%d days ago", dayDiff];
			break;
	}

	return [NSString stringWithFormat:@"%@ (%@)", dayDescription, [self dateStringFromDate:date]];
}
@end