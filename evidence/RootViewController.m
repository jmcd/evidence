#import "RootViewController.h"

@implementation RootViewController {
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
	NSLog(@"presenting");
	[super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)showDetailViewController:(UIViewController *)vc sender:(id)sender {
	NSLog(@"showDetailViewController");
	[super showDetailViewController:vc sender:sender];
}

@end