#import <Foundation/Foundation.h>

@protocol FetchedResultsControllerTableViewDelegateDelegate;

@interface FetchedResultsControllerTableViewDelegate : NSObject<NSFetchedResultsControllerDelegate>
- (id)initWithDelegate:(id <FetchedResultsControllerTableViewDelegateDelegate>)delegate;
@end