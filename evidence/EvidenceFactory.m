#import "VideoImageGrabber.h"
#import "UIImage+Util.h"
#import "Evidence.h"
#import "CoreDataHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "EvidenceFactory.h"

@implementation EvidenceFactory {
}
+ (Evidence *)constructEvidenceWithMediaType:(NSString *)mediaType mediaUrl:(NSURL *)mediaUrl editedImage:(UIImage *)editedImage originalImage:(UIImage *)originalImage evidenceType:(NSString *)type {
    Evidence *evidence = [Evidence insertInManagedObjectContext:[CoreDataHelper instance].mainQueueContext];
    evidence.mediaType = mediaType;
    evidence.type = type;

    UIImage *image;
    // Set the data of the evidence, and determine an image to be converted into a thumbnail
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage]) {
        image = editedImage;
        if (!image) {
            image = originalImage;
        }
        [evidence setDataWithImageData:UIImageJPEGRepresentation(image, 1)];
    } else if ([mediaType isEqualToString:(NSString *) kUTTypeMovie]) {
        image = [VideoImageGrabber imageFromMovieAtURL:mediaUrl];
        [evidence setDataWithCopyOfContentsOfVideoURL:mediaUrl];
    } else {
        ZAssert(NO, @"");
    }

    CGSize thumbnailSize = CGSizeMake(100, 100);
    UIImage *thumbnailImage = [UIImage imageWithImage:image scaledToFillSize:thumbnailSize];
    evidence.thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1);

    [[CoreDataHelper instance] saveMainQueueContext];
    return evidence;
}
@end