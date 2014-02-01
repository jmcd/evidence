#import <Foundation/Foundation.h>

@interface EvidenceFactory : NSObject
+ (Evidence *)constructEvidenceWithMediaType:(NSString *)mediaType mediaUrl:(NSURL *)mediaUrl editedImage:(UIImage *)editedImage originalImage:(UIImage *)originalImage evidenceType:(NSString *)type;
@end