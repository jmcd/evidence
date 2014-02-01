#import <Foundation/Foundation.h>

@class FetchedResultsControllerTableViewDelegate;

@protocol FetchedResultsControllerTableViewDelegateDelegate <NSObject>  // OOF

- (UITableView *)tableViewForFetchedResultsControllerTableViewDelegate:(FetchedResultsControllerTableViewDelegate *)fetchedResultsControllerTableViewDelegate;

- (void)fetchedResultsControllerTableViewDelegate:(FetchedResultsControllerTableViewDelegate *)fetchedResultsControllerTableViewDelegate configureCellAtIndexPath:(NSIndexPath *)indexPath;
@end