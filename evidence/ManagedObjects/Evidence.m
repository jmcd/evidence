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
	NSData *data = [NSData dataWithContentsOfFile:[self fixedDataFilePath] options:0 error:&error];
	ZAssert(data, @"error loading data from '%@': %@, %@", self.dataFilePath, error.localizedDescription, error.userInfo);
	return data;
}

// BUG: dataFilePath points to full path of file, which contains the application container id, which varies from install to install
// WORKAROUND: ignore the path, assume file in document directory
- (NSString *)fixedDataFilePath {
	return [[NSString documentsDirectoryPath] stringByAppendingPathComponent:self.dataFilePath.lastPathComponent];
}

- (void)setDataWithImageData:(NSData *)data {
	NSString *path = [self generateUniqueDataFilePathWithExtension:@"jpeg"];
	NSError *error;
	ZAssert([data writeToFile:path options:NSDataWritingAtomic error:&error], @"error writing to path %@: %@, %@", path, error.localizedDescription, error.userInfo);
	self.dataFilePath = path;
}

- (void)setDataWithCopyOfContentsOfVideoURL:(NSURL *)url {
	NSError *error;
	NSString *path = [self generateUniqueDataFilePathWithExtension:@"mp4"];
	NSURL *dstUrl = [NSURL fileURLWithPath:path];
	ZAssert([[NSFileManager defaultManager] copyItemAtURL:url toURL:dstUrl error:&error], @"error copying data from %@ to %@: %@, %@", url, dstUrl, error.localizedDescription, error.userInfo);
	self.dataFilePath = path;
}

- (NSString *)generateUniqueDataFilePathWithExtension:(NSString *)extension {
	NSString *documentsDirectoryPath = [NSString documentsDirectoryPath];
	NSString *uuid = [NSString UUIDString];
	NSString *filename = [NSString stringWithFormat:@"%@.%@", uuid, extension];
	NSString *path = [documentsDirectoryPath stringByAppendingPathComponent:filename];
	return path;
}
@end
