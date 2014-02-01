#import <Foundation/Foundation.h>

@class Action;

@interface AlertViewController : NSObject
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(Action *)cancelAction otherActions:(NSArray *)otherActions;

- (UIAlertView *)alertView;
@end