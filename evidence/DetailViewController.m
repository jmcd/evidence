#import <MobileCoreServices/MobileCoreServices.h>
#import "DetailViewController.h"
#import "Evidence.h"
#import "ConventionalDateFormatter.h"
#import "ImageViewController.h"
#import "VideoViewController.h"
#import "EmptyViewController.h"
#import "UIView+AutoLayout.h"
#import "NSLayoutConstraint+AutoLayout.h"

@implementation DetailViewController {
	ConventionalDateFormatter *_conventionalDateFormatter;
	Evidence *_evidence;
}

- (instancetype)initWithEvidence:(Evidence *)evidence {
	self = [super init];
	if (self) {
		_conventionalDateFormatter = [[ConventionalDateFormatter alloc] init];
		_evidence = evidence;
	}

	return self;
}

- (void)viewDidLoad {

	self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	self.navigationItem.leftItemsSupplementBackButton = YES;

	self.title = [self titleForEvidence:_evidence];

	UIViewController *childViewController = [self controllerForEvidence:_evidence];
	[self addChildViewController:childViewController];
	[self.view addConstrainedSubview:childViewController.view];

	self.automaticallyAdjustsScrollViewInsets = NO;

	UIView *childView = childViewController.view;
	id <UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
	id <UILayoutSupport> bottomLayoutGuide = self.bottomLayoutGuide;
	NSDictionary *views = NSDictionaryOfVariableBindings(topLayoutGuide, bottomLayoutGuide, childView);

	[self.view addManyConstraints:@[
		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:|[topLayoutGuide][childView][bottomLayoutGuide]|",
			@"H:|[childView]|",
		] options:0 metrics:nil views:views]
	]];
}

- (NSString *)titleForEvidence:(Evidence *)evidence {
	NSString *title;
	if (evidence) {

		if (evidence.type.length > 0) {
			title = [NSString stringWithFormat:@"%@, %@", evidence.type, [_conventionalDateFormatter longStringFromDate:evidence.createdOnDateTime]];
		} else {

			title = [NSString stringWithFormat:@"%@", [_conventionalDateFormatter longStringFromDate:evidence.createdOnDateTime]];
		}
	} else {
		title = @"";
	}
	return title;
}

- (UIViewController *)controllerForEvidence:(Evidence *)evidence {
	UIViewController *controller;
	if ([evidence.mediaType isEqualToString:(NSString *) kUTTypeMovie]) {
		controller = [[VideoViewController alloc] initWithDataFilePath:evidence.fixedDataFilePath];
	} else if ([evidence.mediaType isEqualToString:(NSString *) kUTTypeImage]) {
		UIImage *image = [UIImage imageWithData:evidence.data];
		controller = [[ImageViewController alloc] initWithImage:image];
	} else {
		controller = [EmptyViewController new];
	}
	return controller;
}

- (Evidence *)evidence {
	return _evidence;
}
@end