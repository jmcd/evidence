#import "_Evidence.h"

@interface Evidence : _Evidence {}
// Custom logic goes here.
    - (NSData *)data;

- (NSString *)fixedDataFilePath;

- (void)setDataWithImageData:(NSData *)data;

- (void)setDataWithCopyOfContentsOfVideoURL:(NSURL *)url;
@end
