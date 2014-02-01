#import <Foundation/Foundation.h>

@interface Action : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) void (^block)();

- (id)initWithTitle:(NSString *)title block:(void (^)())block;

+ (Action *)actionWithTitle:(NSString *)title block:(void (^)())block;

+ (Action *)actionWithTitle:(NSString *)title;
@end