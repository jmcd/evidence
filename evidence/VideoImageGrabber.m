#import <AVFoundation/AVFoundation.h>
#import "VideoImageGrabber.h"

@implementation VideoImageGrabber {
}
+ (UIImage *)imageFromMovieAtURL:(NSURL *)url {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;

    CMTime thumbTime = CMTimeMakeWithSeconds(1, 1);

    CMTime actualTime;
    NSError *error;

    CGImageRef imageRef = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
    ZAssert(error == nil, @"error generating video thumbnail: %@, %@", error.localizedDescription, error.userInfo);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    return image;
}
@end