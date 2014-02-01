#import "ActionSheetController.h"
#import "Action.h"

@interface ActionSheetController () <UIActionSheetDelegate>
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) Action *cancelAction;
@property(nonatomic, strong) Action *destructiveAction;
@property(nonatomic, strong) NSArray *otherActions;
@property(nonatomic, strong) NSMutableArray *allActions;
@end

@implementation ActionSheetController {
	UIActionSheet *_actionSheet;
}
- (id)initWithTitle:(NSString *)title cancelAction:(Action *)cancelAction destructiveAction:(Action *)destructiveAction otherActions:(NSArray *)otherActions {
	self = [super init];
	if (self) {
		self.title = title;
		self.cancelAction = cancelAction;
		self.destructiveAction = destructiveAction;
		self.otherActions = otherActions;
		self.allActions = [otherActions mutableCopy];
		if (cancelAction) {
			[self.allActions addObject:cancelAction];
		}
		if (destructiveAction) {
			[self.allActions insertObject:destructiveAction atIndex:0];
		}
	}

	return self;
}

- (UIActionSheet *)actionSheet {
	if (!_actionSheet) {

//		_actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:self.cancelAction.title destructiveButtonTitle:self.destructiveAction.title otherButtonTitles:nil];
//		//_actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//		for (Action *action in self.otherActions) {
//			[_actionSheet addButtonWithTitle:action.title];
//		}
//		if (_cancelAction) {
//			NSUInteger buttonIndex = [self.allActions indexOfObject:_cancelAction];
//			[_actionSheet setCancelButtonIndex:buttonIndex];
//		}

		_actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		for (Action *action in self.allActions) {
			[_actionSheet addButtonWithTitle:action.title];
		}
		if (_cancelAction) {
			NSUInteger buttonIndex = [self.allActions indexOfObject:_cancelAction];
			[_actionSheet setCancelButtonIndex:buttonIndex];
		}
		if (_destructiveAction) {
			NSUInteger buttonIndex = [self.allActions indexOfObject:_destructiveAction];
			[_actionSheet setDestructiveButtonIndex:buttonIndex];
		}
	}
	return _actionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	Action *action = self.allActions[buttonIndex];
	DLog(@"%@", action.title);
	void (^pFunction)() = action.block;
	pFunction();
}
@end