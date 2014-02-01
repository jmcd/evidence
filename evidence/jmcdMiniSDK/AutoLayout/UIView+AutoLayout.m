#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

- (void)addManyConstraints:(NSArray *)constraintsAndArraysOfConstraints {
	for(id obj in constraintsAndArraysOfConstraints){

		if ([obj isKindOfClass:[NSLayoutConstraint class]]){
			[self addConstraint:obj];
		} else {
			[self addConstraints:obj];
		}

	}
}

- (id)addConstrainedSubview:(UIView *)view {
	[self addSubview:view];
	view.translatesAutoresizingMaskIntoConstraints = NO;
	return view;
}
@end