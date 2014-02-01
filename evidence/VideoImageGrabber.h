#import <Foundation/Foundation.h>

@interface VideoImageGrabber : NSObject
+ (UIImage *)imageFromMovieAtURL:(NSURL *)url;
@end