#import <Foundation/Foundation.h>

@class Action;

@interface ActionSheetController : NSObject

- (id)initWithTitle:(NSString *)title cancelAction:(Action *)cancelAction destructiveAction:(Action *)destructiveAction otherActions:(NSArray *)otherActions;

- (UIActionSheet *)actionSheet;
@end