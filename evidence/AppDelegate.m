#import "AppDelegate.h"
#import "EvidenceTableViewController.h"
#import "DetailViewController.h"
#import "Evidence.h"

@interface AppDelegate () <UISplitViewControllerDelegate>
@end

@implementation AppDelegate {UINavigationController *_navigationController1;}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	EvidenceTableViewController *evidenceTableViewController = [[EvidenceTableViewController alloc] init];

	DetailViewController *rootViewController = [DetailViewController new];

	UINavigationController *navigationController0 = [[UINavigationController alloc] initWithRootViewController:evidenceTableViewController];
	_navigationController1 = [[UINavigationController alloc] initWithRootViewController:rootViewController];

	UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
	splitViewController.viewControllers = @[navigationController0, _navigationController1];

	splitViewController.delegate = self;

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = splitViewController;
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];

	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"type_0_preference"]) {

		NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *settingsPropertyListPath = [mainBundlePath stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];

		NSDictionary *settingsPropertyList = [NSDictionary dictionaryWithContentsOfFile:settingsPropertyListPath];

		NSMutableArray *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
		NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];

		for (int i = 0; i < [preferenceArray count]; i++) {
			NSString *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];

			if (key) {
				id value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
				[registerableDictionary setObject:value forKey:key];
			}
		}

		[[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	return YES;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {

	if ([secondaryViewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *navigationController = (UINavigationController *) secondaryViewController;
		if ([navigationController.topViewController isKindOfClass:[DetailViewController class]]) {
			DetailViewController *detailViewController = (DetailViewController *) navigationController.topViewController;
			Evidence *evidence = detailViewController.evidence;
			if (evidence) {
				return NO;
			}
		}
	}

	return YES;
}

@end