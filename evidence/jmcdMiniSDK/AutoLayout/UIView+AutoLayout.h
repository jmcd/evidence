#import <Foundation/Foundation.h>

@interface UIView (AutoLayout)
- (void)addManyConstraints:(NSArray *)array;

- (id)addConstrainedSubview:(UIView *)view;
@end