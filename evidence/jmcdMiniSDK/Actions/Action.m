#import "Action.h"

@implementation Action {
}
- (id)initWithTitle:(NSString *)title block:(void (^)())block {
	self = [super init];
	if (self) {
		self.title = title;
		self.block = block;
	}

	return self;
}

+ (Action *)actionWithTitle:(NSString *)title block:(void (^)())block {
	return [[Action alloc] initWithTitle:title block:block];
}

+ (Action *)actionWithTitle:(NSString *)title {
	return [[Action alloc] initWithTitle:title block:^(){}];
}

@end