#import "AppDelegate.h"
#import "EvidenceTableViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	EvidenceTableViewController *evidenceTableViewController = [[EvidenceTableViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:evidenceTableViewController];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = navigationController;
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

@end