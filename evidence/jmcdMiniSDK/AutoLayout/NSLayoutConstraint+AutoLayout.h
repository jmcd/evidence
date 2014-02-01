#import <Foundation/Foundation.h>

@interface NSLayoutConstraint (AutoLayout)

+ (id)constraintsWithVisualFormats:(NSArray *)visualFormats options:(NSLayoutFormatOptions)options metrics:(NSDictionary *)metrics views:(NSDictionary *)views;
@end