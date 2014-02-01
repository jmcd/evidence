#import "EvidenceTableViewCell.h"

@implementation EvidenceTableViewCell {
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	if (self) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	return self;
}

@end