#import "EmptyViewController.h"
#import "UIView+AutoLayout.h"

@implementation EmptyViewController {
	UILabel *_label;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	
	_label = (UILabel *)[self.view addConstrainedSubview:[UILabel new]];
	_label.text = @"No Evidence Selected";
	_label.font = [UIFont systemFontOfSize:24.0];
	_label.textColor = [UIColor grayColor];

	[self.view addManyConstraints:@[

		[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0.0],
		[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0.0]

	]];

}

@end