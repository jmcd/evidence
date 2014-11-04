#import <Foundation/Foundation.h>

@class Evidence;

@interface DetailViewController : UIViewController

- (instancetype)initWithEvidence:(Evidence *)evidence;

- (Evidence *)evidence;
@end