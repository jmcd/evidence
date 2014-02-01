#import <Foundation/Foundation.h>

@interface ConventionalDateFormatter : NSObject
- (NSString *)timeStringFromDate:(NSDate *)date;

- (NSObject *)dateStringFromDate:(NSDate *)date;

- (NSObject *)longStringFromDate:(NSDate *)date;

- (NSString *)dayDescriptionStringFromDate:(NSDate *)date releativeToToday:(NSDate *)today;
@end