#import <Foundation/Foundation.h>

@interface UIImage (Util)
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;
@end