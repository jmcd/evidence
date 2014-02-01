#import "NSString+DirectoryPaths.h"

@implementation NSString (DirectoryPaths)

+ (NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    ZAssert(paths.count > 0, @"expected to get at least one documents directory");
    return paths[0];
}

@end