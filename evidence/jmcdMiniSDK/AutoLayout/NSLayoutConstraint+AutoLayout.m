#import "NSLayoutConstraint+AutoLayout.h"

@implementation NSLayoutConstraint (AutoLayout)

+ (id)constraintsWithVisualFormats:(NSArray *)visualFormats options:(NSLayoutFormatOptions)options metrics:(NSDictionary *)metrics views:(NSDictionary *)views {
	NSMutableArray *result = [NSMutableArray array];
	for (NSString *visualFormat in visualFormats) {
		NSArray *array = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:options metrics:metrics views:views];
		[result addObjectsFromArray:array];
	}
	return result;
}
@end