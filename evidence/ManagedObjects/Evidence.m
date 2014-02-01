#import "Evidence.h"
#import "CalendarDate.h"
#import "NSString+UUID.h"
#import "NSString+DirectoryPaths.h"

@interface Evidence ()

// Private interface goes here.

@end

@implementation Evidence

// Custom logic goes here.


- (void)awakeFromInsert {
    [super awakeFromInsert];

    CalendarDate *date = [[CalendarDate alloc] init];
    self.createdOnDateTime = date.date;
    self.createdOnDate = date.calendarDateFromYearMonthDayComponents.date;
}

- (NSData *)data {
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:self.dataFilePath options:0 error:&error];
    ZAssert(data, @"error loading data from '%@': %@, %@", self.dataFilePath, error.localizedDescription, error.userInfo);
    return data;
}

- (void)setData:(NSData *)data {
    NSString *documentsDirectoryPath = [NSString documentsDirectoryPath];
    NSString *uuid = [NSString UUIDString];
    NSString *filename = [NSString stringWithFormat:@"%@.mp4", uuid];
    NSString *path = [documentsDirectoryPath stringByAppendingPathComponent:filename];
    if ([data writeToFile:path atomically:YES]) {
        self.dataFilePath = path;
    }
}

@end
